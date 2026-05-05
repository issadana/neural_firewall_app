package com.example.neural_firewall_app.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.nio.ByteBuffer
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

class NeuralVpnService : VpnService() {

    companion object {
        private var eventSink: ((Any) -> Unit)? = null
        private const val BUFFER_SIZE = 32767
        private const val NOTIF_CHANNEL_ID = "neural_fw_vpn"
        private const val NOTIF_ID = 1
        @JvmStatic @Volatile var isRunning = false

        fun setEventSink(sink: ((Any) -> Unit)?) { eventSink = sink }
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val flowTracker = FlowTracker()

    // ── TCP connection tracking ────────────────────────────────────────────────
    private data class TcpState(
        val socket: Socket,
        val relayJob: Job,
        val serverSeq: AtomicLong,  // seq we send to the device (internet→device direction)
        val clientSeq: AtomicLong   // seq we ack from the device (device→internet direction)
    )
    private val tcpConnections = ConcurrentHashMap<String, TcpState>()

    private fun tcpKey(srcIp: String, srcPort: Int, dstIp: String, dstPort: Int) =
        "$srcIp:$srcPort->$dstIp:$dstPort"

    // ──────────────────────────────────────────────────────────────────────────

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true
        startForegroundNotification()
        scope.launch { startCapture() }
        return START_STICKY
    }

    private fun startForegroundNotification() {
        val channel = NotificationChannel(
            NOTIF_CHANNEL_ID,
            "Neural Firewall VPN",
            NotificationManager.IMPORTANCE_LOW
        )
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)

        val notification: Notification = Notification.Builder(this, NOTIF_CHANNEL_ID)
            .setContentTitle("Neural Firewall Active")
            .setContentText("Monitoring network traffic")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIF_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE)
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    private suspend fun startCapture() {
        try {
            val builder = Builder()
                .addAddress("10.0.0.2", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("8.8.8.8")
                .setSession("NeuralFirewall")
                .setMtu(1500)

            try { builder.addDisallowedApplication(packageName) } catch (_: Exception) {}

            vpnInterface = builder.establish() ?: return
            readPacketLoop()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private suspend fun readPacketLoop() {
        val fd = vpnInterface?.fileDescriptor ?: return
        val input  = FileInputStream(fd)
        val output = FileOutputStream(fd)
        val buffer = ByteArray(BUFFER_SIZE)

        while (isRunning && !Thread.currentThread().isInterrupted) {
            try {
                val length = input.read(buffer)
                if (length <= 0) { delay(1); continue }

                val rawBytes = buffer.copyOf(length)
                val parsed = PacketParser.parse(rawBytes, System.currentTimeMillis())

                if (parsed != null) {
                    // Send metadata to Flutter for IDS analysis
                    val flowStats = flowTracker.update(parsed)
                    val enriched = mapOf(
                        "id"           to parsed.id,
                        "srcIp"        to parsed.srcIp,
                        "srcPort"      to parsed.srcPort,
                        "dstIp"        to parsed.dstIp,
                        "dstPort"      to parsed.dstPort,
                        "protocol"     to parsed.protocol,
                        "sizeBytes"    to parsed.sizeBytes,
                        "flags"        to parsed.flags,
                        "timestamp"    to parsed.timestamp,
                        "flowIatMean"  to flowStats.iatMean,
                        "flowIatStd"   to flowStats.iatStd,
                        "flowDuration" to flowStats.duration
                    )
                    withContext(Dispatchers.Main) { eventSink?.invoke(enriched) }

                    // Forward packet so internet connectivity is preserved
                    when (parsed.protocol) {
                        6  -> scope.launch { handleTcp(parsed, rawBytes, output) }
                        17 -> scope.launch { handleUdp(parsed, rawBytes, output) }
                        // ICMP: drop (no user-visible impact for IDS monitoring)
                    }
                }
            } catch (e: Exception) {
                if (isRunning) e.printStackTrace()
                delay(5)
            }
        }
    }

    // ── TCP: connection-tracked relay ─────────────────────────────────────────

    private fun handleTcp(parsed: ParsedPacket, rawBytes: ByteArray, tunOut: FileOutputStream) {
        val ipLen    = (rawBytes[0].toInt() and 0x0F) * 4
        val tcpBase  = ipLen
        if (tcpBase + 20 > rawBytes.size) return

        val flags    = rawBytes[tcpBase + 13].toInt() and 0xFF
        val isSyn    = (flags and 0x02) != 0
        val isAck    = (flags and 0x10) != 0
        val isFin    = (flags and 0x01) != 0
        val isRst    = (flags and 0x04) != 0
        val tcpHdrLen = ((rawBytes[tcpBase + 12].toInt() and 0xF0) shr 4) * 4
        val payloadOff = tcpBase + tcpHdrLen
        val payloadLen = rawBytes.size - payloadOff

        val clientSeqFromPkt = readU32(rawBytes, tcpBase + 4)
        val key = tcpKey(parsed.srcIp, parsed.srcPort, parsed.dstIp, parsed.dstPort)

        when {
            // ── New connection ──────────────────────────────────────────────
            isSyn && !isAck -> {
                val clientIsn = clientSeqFromPkt
                // Use nano-time as our initial sequence number (avoids predictable ISN)
                val serverIsn = (System.nanoTime() ushr 16) and 0xFFFFFFFFL

                val sock = Socket()
                try {
                    protect(sock)
                    sock.connect(InetSocketAddress(parsed.dstIp, parsed.dstPort), 5000)

                    // Respond with SYN-ACK so the device's TCP stack believes the
                    // connection was accepted
                    tunOut.writeSynced(buildTcpControl(
                        srcIp  = parsed.dstIp,  srcPort = parsed.dstPort,
                        dstIp  = parsed.srcIp,  dstPort = parsed.srcPort,
                        seq    = serverIsn,
                        ackNum = clientIsn + 1,
                        flags  = 0x12  // SYN + ACK
                    ))

                    val srvSeq  = AtomicLong(serverIsn + 1) // SYN counts as 1 byte
                    val cliSeq  = AtomicLong(clientIsn + 1)

                    // Relay: internet socket → TUN (runs until connection closes)
                    val relayJob = scope.launch {
                        val buf = ByteArray(8192)
                        try {
                            while (isActive && !sock.isClosed) {
                                val n = sock.inputStream.read(buf)
                                if (n < 0) break
                                val payload = buf.copyOf(n)
                                tunOut.writeSynced(buildTcpData(
                                    srcIp   = parsed.dstIp,  srcPort = parsed.dstPort,
                                    dstIp   = parsed.srcIp,  dstPort = parsed.srcPort,
                                    seq     = srvSeq.get(),
                                    ackNum  = cliSeq.get(),
                                    payload = payload
                                ))
                                srvSeq.addAndGet(n.toLong())

                                // Emit inbound event to Flutter — srcIp is the remote server
                                // (e.g. YouTube), dstIp is the device. This is what the IDS
                                // table should display: traffic arriving at the device.
                                val inboundEvent = mapOf(
                                    "id"           to "in_${System.nanoTime()}",
                                    "srcIp"        to parsed.dstIp,
                                    "srcPort"      to parsed.dstPort,
                                    "dstIp"        to parsed.srcIp,
                                    "dstPort"      to parsed.srcPort,
                                    "protocol"     to 6,
                                    "sizeBytes"    to n,
                                    "flags"        to 0x18,
                                    "timestamp"    to System.currentTimeMillis(),
                                    "flowIatMean"  to 0.0,
                                    "flowIatStd"   to 0.0,
                                    "flowDuration" to 0L
                                )
                                withContext(Dispatchers.Main) { eventSink?.invoke(inboundEvent) }
                            }
                        } catch (_: Exception) {}
                        tcpConnections.remove(key)
                        runCatching { sock.close() }
                    }

                    tcpConnections[key] = TcpState(sock, relayJob, srvSeq, cliSeq)

                } catch (e: Exception) {
                    runCatching { sock.close() }
                    // Send RST so the device doesn't hang waiting
                    runCatching {
                        tunOut.writeSynced(buildTcpControl(
                            srcIp  = parsed.dstIp, srcPort = parsed.dstPort,
                            dstIp  = parsed.srcIp, dstPort = parsed.srcPort,
                            seq    = 0, ackNum = clientIsn + 1,
                            flags  = 0x04  // RST
                        ))
                    }
                }
            }

            // ── Connection teardown ─────────────────────────────────────────
            isFin || isRst -> {
                val state = tcpConnections.remove(key)
                state?.relayJob?.cancel()
                runCatching { state?.socket?.close() }
            }

            // ── Data segment ────────────────────────────────────────────────
            isAck && payloadLen > 0 -> {
                val state = tcpConnections[key] ?: return
                val payload = rawBytes.copyOfRange(payloadOff, rawBytes.size)
                try {
                    state.socket.outputStream.write(payload)
                    state.socket.outputStream.flush()
                    state.clientSeq.addAndGet(payloadLen.toLong())

                    // Pure ACK back to the device so its window doesn't stall
                    tunOut.writeSynced(buildTcpControl(
                        srcIp  = parsed.dstIp, srcPort = parsed.dstPort,
                        dstIp  = parsed.srcIp, dstPort = parsed.srcPort,
                        seq    = state.serverSeq.get(),
                        ackNum = state.clientSeq.get(),
                        flags  = 0x10  // ACK
                    ))
                } catch (_: Exception) {
                    val st = tcpConnections.remove(key)
                    st?.relayJob?.cancel()
                    runCatching { st?.socket?.close() }
                }
            }

            // Pure ACK with no payload (e.g. after SYN-ACK): nothing to forward
        }
    }

    // ── UDP: per-packet protected socket (works for DNS, NTP, etc.) ───────────

    private suspend fun handleUdp(parsed: ParsedPacket, rawBytes: ByteArray, tunOut: FileOutputStream) {
        val ipLen = (rawBytes[0].toInt() and 0x0F) * 4
        val udpPayloadOff = ipLen + 8
        if (udpPayloadOff >= rawBytes.size) return
        val payload = rawBytes.copyOfRange(udpPayloadOff, rawBytes.size)

        val sock = DatagramSocket()
        try {
            protect(sock)
            sock.soTimeout = 3000
            val dst = InetAddress.getByName(parsed.dstIp)
            sock.send(DatagramPacket(payload, payload.size, dst, parsed.dstPort))

            val respBuf = ByteArray(BUFFER_SIZE)
            val resp = DatagramPacket(respBuf, respBuf.size)
            sock.receive(resp)

            tunOut.writeSynced(buildUdpPacket(
                srcIp   = parsed.dstIp, srcPort = parsed.dstPort,
                dstIp   = parsed.srcIp, dstPort = parsed.srcPort,
                payload = resp.data.copyOf(resp.length)
            ))

            // Emit inbound UDP event to Flutter
            val inboundEvent = mapOf(
                "id"           to "in_${System.nanoTime()}",
                "srcIp"        to parsed.dstIp,
                "srcPort"      to parsed.dstPort,
                "dstIp"        to parsed.srcIp,
                "dstPort"      to parsed.srcPort,
                "protocol"     to 17,
                "sizeBytes"    to resp.length,
                "flags"        to 0,
                "timestamp"    to System.currentTimeMillis(),
                "flowIatMean"  to 0.0,
                "flowIatStd"   to 0.0,
                "flowDuration" to 0L
            )
            withContext(Dispatchers.Main) { eventSink?.invoke(inboundEvent) }
        } catch (_: Exception) {
            // Timeout or unreachable — drop silently
        } finally {
            sock.close()
        }
    }

    // ── Packet builders ───────────────────────────────────────────────────────

    /** Builds a TCP control packet (SYN-ACK / ACK / RST) with no payload. */
    private fun buildTcpControl(
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
        seq: Long, ackNum: Long,
        flags: Int
    ): ByteArray {
        val totalLen = 40  // 20 IP + 20 TCP
        val buf = ByteBuffer.allocate(totalLen)
        fillIpHeader(buf, srcIp, dstIp, 6, totalLen)
        buf.putShort(srcPort.toShort())
        buf.putShort(dstPort.toShort())
        buf.putInt((seq and 0xFFFFFFFFL).toInt())
        buf.putInt((ackNum and 0xFFFFFFFFL).toInt())
        buf.put(0x50.toByte())        // data offset = 5 (20 bytes), reserved = 0
        buf.put(flags.toByte())
        buf.putShort(65535.toShort()) // window
        buf.putShort(0)               // checksum placeholder
        buf.putShort(0)               // urgent
        val bytes = buf.array()
        patchIpChecksum(bytes)
        patchTcpChecksum(bytes, srcIp, dstIp, 20)
        return bytes
    }

    /** Builds a TCP data packet (PSH+ACK). */
    private fun buildTcpData(
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
        seq: Long, ackNum: Long,
        payload: ByteArray
    ): ByteArray {
        val totalLen = 40 + payload.size
        val buf = ByteBuffer.allocate(totalLen)
        fillIpHeader(buf, srcIp, dstIp, 6, totalLen)
        buf.putShort(srcPort.toShort())
        buf.putShort(dstPort.toShort())
        buf.putInt((seq and 0xFFFFFFFFL).toInt())
        buf.putInt((ackNum and 0xFFFFFFFFL).toInt())
        buf.put(0x50.toByte())
        buf.put(0x18.toByte())        // PSH + ACK
        buf.putShort(65535.toShort())
        buf.putShort(0)
        buf.putShort(0)
        buf.put(payload)
        val bytes = buf.array()
        patchIpChecksum(bytes)
        patchTcpChecksum(bytes, srcIp, dstIp, 20 + payload.size)
        return bytes
    }

    private fun buildUdpPacket(
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
        payload: ByteArray
    ): ByteArray {
        val udpLen  = 8 + payload.size
        val totalLen = 20 + udpLen
        val buf = ByteBuffer.allocate(totalLen)
        fillIpHeader(buf, srcIp, dstIp, 17, totalLen)
        buf.putShort(srcPort.toShort())
        buf.putShort(dstPort.toShort())
        buf.putShort(udpLen.toShort())
        buf.putShort(0)               // checksum (optional for IPv4)
        buf.put(payload)
        val bytes = buf.array()
        patchIpChecksum(bytes)
        return bytes
    }

    // ── Header helpers ────────────────────────────────────────────────────────

    private fun fillIpHeader(buf: ByteBuffer, srcIp: String, dstIp: String, proto: Int, totalLen: Int) {
        buf.put(0x45.toByte())                      // version=4, IHL=5
        buf.put(0)                                   // DSCP/ECN
        buf.putShort(totalLen.toShort())
        buf.putShort(0)                              // identification
        buf.putShort(0x4000.toShort())               // DF flag
        buf.put(64)                                  // TTL
        buf.put(proto.toByte())
        buf.putShort(0)                              // checksum placeholder
        buf.put(InetAddress.getByName(srcIp).address)
        buf.put(InetAddress.getByName(dstIp).address)
    }

    private fun patchIpChecksum(bytes: ByteArray) {
        val cs = internetChecksum(bytes, 0, 20)
        bytes[10] = (cs shr 8).toByte()
        bytes[11] = (cs and 0xFF).toByte()
    }

    private fun patchTcpChecksum(bytes: ByteArray, srcIp: String, dstIp: String, tcpLen: Int) {
        val tcpOff = 20
        // Pseudo-header: srcIP(4) + dstIP(4) + zero(1) + proto(1) + tcpLen(2)
        val pseudo = ByteArray(12 + tcpLen)
        System.arraycopy(InetAddress.getByName(srcIp).address, 0, pseudo, 0, 4)
        System.arraycopy(InetAddress.getByName(dstIp).address, 0, pseudo, 4, 4)
        pseudo[8]  = 0
        pseudo[9]  = 6  // TCP
        pseudo[10] = (tcpLen shr 8).toByte()
        pseudo[11] = (tcpLen and 0xFF).toByte()
        System.arraycopy(bytes, tcpOff, pseudo, 12, tcpLen)
        // Zero the checksum field inside pseudo before computing
        pseudo[12 + 16] = 0
        pseudo[12 + 17] = 0
        val cs = internetChecksum(pseudo, 0, pseudo.size)
        bytes[tcpOff + 16] = (cs shr 8).toByte()
        bytes[tcpOff + 17] = (cs and 0xFF).toByte()
    }

    private fun internetChecksum(buf: ByteArray, offset: Int, length: Int): Int {
        var sum = 0
        var i = offset
        while (i < offset + length - 1) {
            sum += ((buf[i].toInt() and 0xFF) shl 8) or (buf[i + 1].toInt() and 0xFF)
            i += 2
        }
        if ((length and 1) != 0) sum += (buf[offset + length - 1].toInt() and 0xFF) shl 8
        while (sum shr 16 != 0) sum = (sum and 0xFFFF) + (sum shr 16)
        return sum.inv() and 0xFFFF
    }

    private fun readU32(buf: ByteArray, offset: Int): Long =
        ((buf[offset].toLong() and 0xFF) shl 24) or
        ((buf[offset + 1].toLong() and 0xFF) shl 16) or
        ((buf[offset + 2].toLong() and 0xFF) shl 8) or
         (buf[offset + 3].toLong() and 0xFF)

    private fun FileOutputStream.writeSynced(data: ByteArray) {
        synchronized(this) { write(data); flush() }
    }

    // ──────────────────────────────────────────────────────────────────────────

    override fun onDestroy() {
        isRunning = false
        stopForeground(STOP_FOREGROUND_REMOVE)
        scope.cancel()
        tcpConnections.values.forEach { runCatching { it.socket.close() } }
        tcpConnections.clear()
        vpnInterface?.close()
        vpnInterface = null
        flowTracker.reset()
        super.onDestroy()
    }
}
