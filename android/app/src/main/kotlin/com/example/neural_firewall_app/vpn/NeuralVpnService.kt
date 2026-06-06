// NeuralVpnService.kt
// This is the heart of the app.  It is an Android VPN Service that:
//
//   1. Creates a virtual TUN network interface and routes ALL device traffic through it.
//   2. Reads every packet the device sends, parses it, and forwards the metadata
//      to Flutter so the IDS (Intrusion Detection System) can analyse it.
//   3. Actually forwards the packet to the real internet server so the device
//      stays connected — the user does not lose internet access.
//   4. Injects the server's response back into the TUN interface so the device
//      receives it as if no VPN was involved.
//
// Think of it as a transparent proxy sitting between all your apps and the internet.
package com.example.neural_firewall_app.vpn

// Android notification classes — needed to show the persistent "VPN active" notification
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
// Intent: used to receive the start/stop command from MainActivity
import android.content.Intent
// ServiceInfo: needed to declare the foreground service type on Android 14+
import android.content.pm.ServiceInfo
// VpnService: Android's base class for all VPN implementations
import android.net.VpnService
// Build: lets us check the Android API level at runtime
import android.os.Build
// ParcelFileDescriptor: wraps the file descriptor of the TUN interface
import android.os.ParcelFileDescriptor
// Coroutine support: lets us run blocking I/O (reading packets) on background threads
import kotlinx.coroutines.*
// File streams for reading from / writing to the TUN file descriptor
import java.io.FileInputStream
import java.io.FileOutputStream
// Datagram classes for UDP forwarding
import java.net.DatagramPacket
import java.net.DatagramSocket
// InetAddress: converts IP strings like "8.8.8.8" to byte arrays the network stack understands
import java.net.InetAddress
// InetSocketAddress: combines an IP + port into one object for TCP connections
import java.net.InetSocketAddress
// Socket: a regular TCP connection to the real internet server
import java.net.Socket
// ByteBuffer: used to build raw IP/TCP/UDP packets byte by byte
import java.nio.ByteBuffer
// ConcurrentHashMap: a thread-safe map for tracking open TCP connections
import java.util.concurrent.ConcurrentHashMap
// AtomicLong: a thread-safe 64-bit counter (used for TCP sequence numbers)
import java.util.concurrent.atomic.AtomicLong

// NeuralVpnService extends VpnService, which itself extends Service.
// Android starts this as a background service when the user taps "Start VPN".
class NeuralVpnService : VpnService() {

    // companion object holds static-like state shared across all code that
    // references this class, without needing an instance.
    companion object {

        // eventSink is a function reference that, when called with a Map,
        // pushes that Map to Flutter's EventChannel stream.
        // It is null when Flutter is not listening (e.g. app is in background).
        private var eventSink: ((Any) -> Unit)? = null

        // BUFFER_SIZE: the size of the byte array we use to read packets from TUN.
        // 32767 bytes (~32KB) is just under the typical TUN MTU of 32768.
        private const val BUFFER_SIZE = 32767

        // The notification channel ID string — must match what we create in the channel setup.
        private const val NOTIF_CHANNEL_ID = "neural_fw_vpn"

        // The notification ID — any non-zero integer; used to update or cancel the notification later.
        private const val NOTIF_ID = 1

        // isRunning is the main loop flag.
        // @Volatile ensures that when one thread writes to it (e.g. onDestroy sets it false),
        // other threads (e.g. the read loop) immediately see the updated value.
        // @JvmStatic makes it accessible as NeuralVpnService.isRunning from Java/Kotlin callers.
        @JvmStatic @Volatile var isRunning = false

        // blockedIps holds the set of IP addresses that must be silently dropped.
        // ConcurrentHashMap.newKeySet() gives us a thread-safe Set: the read loop and
        // MainActivity (MethodChannel thread) can both access it simultaneously.
        private val blockedIps = java.util.concurrent.ConcurrentHashMap.newKeySet<String>()

        // setEventSink() is called by MainActivity when Flutter's EventChannel opens or closes.
        // Passing null disconnects the sink (stops sending data to Flutter).
        fun setEventSink(sink: ((Any) -> Unit)?) { eventSink = sink }

        // blockIp() adds an IP to the blocked set.
        // All future packets from this IP will be silently dropped (not forwarded).
        fun blockIp(ip: String) { blockedIps.add(ip) }

        // unblockIp() removes an IP from the blocked set so it can communicate again.
        fun unblockIp(ip: String) { blockedIps.remove(ip) }

        // isIpBlocked() lets other parts of the service check the set.
        fun isIpBlocked(ip: String): Boolean = blockedIps.contains(ip)

        // clearBlockedIps() wipes the entire set (e.g. when VPN stops).
        fun clearBlockedIps() { blockedIps.clear() }
    }

    // vpnInterface holds the file descriptor of the TUN interface.
    // It is nullable because establish() can fail, and we null it out on destroy.
    private var vpnInterface: ParcelFileDescriptor? = null

    // scope is the coroutine scope for this service.
    // Dispatchers.IO: runs coroutines on a pool of threads optimised for blocking I/O.
    // SupervisorJob: if one child coroutine crashes, the others keep running.
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    // flowTracker computes per-connection timing statistics (IAT mean/std dev).
    private val flowTracker = FlowTracker()

    // dnsCache watches DNS responses and builds an IP→hostname lookup table,
    // so we can show "YouTube" instead of "142.250.74.78" in the UI.
    private val dnsCache = DnsCache()

    // ── TCP Connection Tracking ───────────────────────────────────────────────
    //
    // TCP is stateful — each connection needs a persistent socket to the server
    // and sequence number counters that advance correctly across multiple packets.
    // We store this state in TcpState and key it by the connection's 4-tuple.

    // TcpState holds everything needed to relay one TCP connection.
    private data class TcpState(
        val socket: Socket,          // the real TCP socket connected to the internet server
        val relayJob: Job,           // the coroutine that reads from the server and writes to TUN
        val serverSeq: AtomicLong,   // next sequence number WE send to the device (server→device direction)
        val clientSeq: AtomicLong    // next sequence number WE expect from the device (device→server direction)
    )

    // tcpConnections maps a connection key to its TcpState.
    // ConcurrentHashMap is used because handleTcp() and the relay coroutines
    // both read/write this map from different threads simultaneously.
    private val tcpConnections = ConcurrentHashMap<String, TcpState>()

    // tcpKey() builds the string key for a TCP connection.
    // Format: "srcIp:srcPort->dstIp:dstPort"  e.g. "10.0.0.2:49876->142.250.74.78:443"
    private fun tcpKey(srcIp: String, srcPort: Int, dstIp: String, dstPort: Int) =
        "$srcIp:$srcPort->$dstIp:$dstPort"

    // ─────────────────────────────────────────────────────────────────────────

    // onStartCommand() is called by Android when the service receives a start Intent.
    // This is the entry point — MainActivity sends an Intent to start the VPN.
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true                          // signal all threads that the VPN is running
        startForegroundNotification()             // required by Android: show a persistent notification
        scope.launch { startCapture() }           // launch the TUN setup on a background thread
        return START_STICKY                       // if Android kills this service, restart it automatically
    }

    // startForegroundNotification() creates and displays the persistent notification.
    // Android requires foreground services to show a notification so the user always
    // knows a background service is running and consuming resources.
    private fun startForegroundNotification() {
        // NotificationChannel groups notifications by category.
        // We create one channel with LOW importance (no sound/vibration).
        val channel = NotificationChannel(
            NOTIF_CHANNEL_ID,             // unique ID for this channel
            "Neural Firewall VPN",        // name shown in system settings
            NotificationManager.IMPORTANCE_LOW // silent — no sound or heads-up pop-up
        )
        // Register the channel with the system. Safe to call multiple times.
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)

        // Build the actual notification that will appear in the status bar.
        val notification: Notification = Notification.Builder(this, NOTIF_CHANNEL_ID)
            .setContentTitle("Neural Firewall Active")         // bold title line
            .setContentText("Monitoring network traffic")      // subtitle line
            .setSmallIcon(android.R.drawable.ic_lock_lock)     // lock icon in status bar
            .setOngoing(true)                                   // user cannot swipe it away
            .build()

        // Android 14 (API 34, UPSIDE_DOWN_CAKE) requires declaring the foreground
        // service type.  CONNECTED_DEVICE is the correct type for VPN services.
        // Older versions use the simpler two-argument form.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIF_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE)
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    // startCapture() configures and establishes the TUN virtual interface.
    // It is a suspend function because it is launched inside a coroutine scope.
    private suspend fun startCapture() {
        try {
            // Builder is an inner class of VpnService that configures the TUN interface.
            val builder = Builder()

                // Assign the virtual IP address of the TUN interface.
                // 10.0.0.2/32 is a private address that won't conflict with real internet IPs.
                // /32 means it's a single host (point-to-point) — no subnet sharing.
                .addAddress("10.0.0.2", 32)

                // Route ALL traffic through the TUN interface.
                // 0.0.0.0/0 is the "default route" — it matches every possible destination IP.
                // Without this, some traffic would bypass the VPN entirely.
                .addRoute("0.0.0.0", 0)

                // Tell the device to use Google's public DNS server (8.8.8.8).
                // Because we intercepted all traffic (including DNS on port 53),
                // we need a public DNS server that our handleUdp() can forward queries to.
                // Without this, the device would try to use the local router's DNS (e.g. 192.168.1.1)
                // which is now unreachable because we routed everything through TUN.
                .addDnsServer("8.8.8.8")

                // A human-readable label shown in Android's VPN settings screen
                .setSession("NeuralFirewall")

                // MTU = Maximum Transmission Unit: the largest packet size (in bytes)
                // the TUN interface will handle.  1500 is the standard Ethernet MTU.
                .setMtu(1500)

            // Exclude our own app's traffic from the VPN.
            // Without this, when handleTcp() opens a real Socket to youtube.com,
            // that socket's packets would re-enter the TUN interface and be captured
            // again, creating an infinite forwarding loop.
            // protect() on individual sockets is the per-socket version of the same idea.
            try { builder.addDisallowedApplication(packageName) } catch (_: Exception) {}

            // establish() submits the configuration and creates the TUN file descriptor.
            // Returns null if the user hasn't granted VPN permission, or if another
            // VPN is already running and won't yield.
            vpnInterface = builder.establish() ?: return

            // Start reading packets from the TUN interface
            readPacketLoop()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // readPacketLoop() is the main loop of the VPN service.
    // It runs continuously, reading one IP packet at a time from the TUN interface,
    // parsing it, sending metadata to Flutter, and forwarding it to the internet.
    private suspend fun readPacketLoop() {
        val fd = vpnInterface?.fileDescriptor ?: return

        // input: reads raw IP packets that device apps are sending OUT
        val input  = FileInputStream(fd)

        // output: we write raw IP packets INTO TUN — the device receives them as inbound traffic
        val output = FileOutputStream(fd)

        // Reusable read buffer — we copy out the used portion before parsing
        val buffer = ByteArray(BUFFER_SIZE)

        // Loop until the service is stopped or the thread is interrupted
        while (isRunning && !Thread.currentThread().isInterrupted) {
            try {
                // Blocking read: suspends until a packet arrives on the TUN interface.
                // Returns the number of bytes read, or -1 if the descriptor closed.
                val length = input.read(buffer)

                // length <= 0 means no data yet (non-blocking mode) or EOF — try again
                if (length <= 0) { delay(1); continue }

                // Copy exactly 'length' bytes out of the shared buffer into a fresh array.
                // We must copy because we're about to pass it to a coroutine — if we
                // passed the shared buffer, the next read() would overwrite it.
                val rawBytes = buffer.copyOf(length)

                // Parse the raw bytes into a structured ParsedPacket.
                // Returns null if the packet is too short or malformed.
                val parsed = PacketParser.parse(rawBytes, System.currentTimeMillis())

                if (parsed != null) {
                    // ── IP Block check ───────────────────────────────────────────
                    // If Flutter's AI model has flagged this source IP, drop the packet
                    // immediately — don't forward it and don't notify Flutter again.
                    // This is the real network-level block: the packet simply goes nowhere.
                    if (isIpBlocked(parsed.srcIp)) continue

                    // Update the flow tracker with this packet's timestamp.
                    // flowTracker.update() returns fresh IAT statistics for this flow.
                    val flowStats = flowTracker.update(parsed)

                    // Build the enriched map that we send to Flutter.
                    // Flutter receives this as a Map<String, Any> via the EventChannel.
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
                        "flowIatMean"  to flowStats.iatMean,   // ML feature: mean inter-arrival time
                        "flowIatStd"   to flowStats.iatStd,    // ML feature: IAT standard deviation
                        "flowDuration" to flowStats.duration,  // how long this flow has been alive
                        "label"        to dnsCache.serviceLabel(parsed.dstIp), // e.g. "YouTube"
                        "isBlocked"    to false                // not blocked at network level
                    )

                    // eventSink must be called on the MAIN thread (Android UI thread)
                    // because Flutter's event channel is not thread-safe.
                    // withContext(Dispatchers.Main) temporarily switches the coroutine to the main thread.
                    withContext(Dispatchers.Main) { eventSink?.invoke(enriched) }

                    // Forward the packet to the real internet so the device stays online.
                    // We launch each handler as a separate child coroutine so the read
                    // loop is never blocked waiting for a network response.
                    when (parsed.protocol) {
                        6  -> scope.launch { handleTcp(parsed, rawBytes, output) } // TCP
                        17 -> scope.launch { handleUdp(parsed, rawBytes, output) } // UDP
                        // ICMP (ping): we drop it.  The device can't meaningfully ping through
                        // a userspace VPN proxy without raw socket privileges.  Dropping ICMP
                        // has no effect on internet connectivity.
                    }
                }
            } catch (e: Exception) {
                if (isRunning) e.printStackTrace()
                delay(5) // brief pause before retrying to avoid a tight error loop
            }
        }
    }

    // ── TCP: Connection-Tracked Relay ─────────────────────────────────────────
    //
    // TCP is connection-oriented and stateful.  A TCP "connection" is a logical
    // channel with sequence numbers, acknowledgement numbers, and control flags.
    //
    // Our approach:
    //   1. When we see a SYN (connection request from the device), we open a REAL
    //      socket to the destination server ourselves, and send back a fake SYN-ACK
    //      so the device's TCP stack thinks the server accepted the connection.
    //   2. When the device sends data (ACK + payload), we write it to the real socket.
    //   3. A background relay coroutine reads from the real socket and writes the
    //      server's responses back into TUN as properly-sequenced TCP packets.
    //   4. When the device sends FIN or RST, we close the real socket and clean up.

    private fun handleTcp(parsed: ParsedPacket, rawBytes: ByteArray, tunOut: FileOutputStream) {

        // ── Extract IP header length ───────────────────────────────────────────
        // Byte 0 of rawBytes: lower nibble = IHL (IP header length in 32-bit words).
        // Multiply by 4 to get bytes.  Typically 20 bytes (IHL = 5).
        val ipLen   = (rawBytes[0].toInt() and 0x0F) * 4

        // tcpBase is the byte index where the TCP header starts (right after the IP header)
        val tcpBase = ipLen

        // Sanity check: we need at least 20 bytes of TCP header
        if (tcpBase + 20 > rawBytes.size) return

        // ── Extract TCP flags ─────────────────────────────────────────────────
        // Byte 13 of the TCP header contains the control flags:
        //   bit 0 (0x01) = FIN  — no more data from sender
        //   bit 1 (0x02) = SYN  — synchronise sequence numbers (connection request)
        //   bit 2 (0x04) = RST  — reset the connection (abort)
        //   bit 3 (0x08) = PSH  — push data to application immediately
        //   bit 4 (0x10) = ACK  — acknowledgement field is valid
        val flags   = rawBytes[tcpBase + 13].toInt() and 0xFF
        val isSyn   = (flags and 0x02) != 0 // is the SYN bit set?
        val isAck   = (flags and 0x10) != 0 // is the ACK bit set?
        val isFin   = (flags and 0x01) != 0 // is the FIN bit set?
        val isRst   = (flags and 0x04) != 0 // is the RST bit set?

        // ── TCP header length ─────────────────────────────────────────────────
        // Byte 12 of the TCP header: upper nibble = data offset (TCP header length in words).
        // (0xF0 mask isolates the upper nibble, shr 4 divides by 16, ×4 converts to bytes)
        val tcpHdrLen  = ((rawBytes[tcpBase + 12].toInt() and 0xF0) shr 4) * 4

        // payloadOff: the byte index in rawBytes where application data begins
        val payloadOff = tcpBase + tcpHdrLen

        // payloadLen: how many bytes of application data are in this packet
        val payloadLen = rawBytes.size - payloadOff

        // ── Client sequence number ────────────────────────────────────────────
        // Bytes 4–7 of the TCP header: the client's current sequence number.
        // readU32() reads a big-endian 32-bit unsigned integer as a Long.
        val clientSeqFromPkt = readU32(rawBytes, tcpBase + 4)

        // Build the connection key so we can look up (or create) the TcpState
        val key = tcpKey(parsed.srcIp, parsed.srcPort, parsed.dstIp, parsed.dstPort)

        when {
            // ── CASE 1: New connection (SYN only, no ACK) ─────────────────────
            // This is the device saying "I want to open a connection to dstIp:dstPort".
            isSyn && !isAck -> {
                val clientIsn = clientSeqFromPkt // client's Initial Sequence Number

                // Choose our Initial Sequence Number using nanoseconds.
                // Using a time-based value avoids predictable ISNs which are a security risk.
                // ushr 16: shift right 16 bits to get a value that changes slowly.
                // and 0xFFFFFFFFL: mask to 32 bits (TCP sequence numbers are 32-bit).
                val serverIsn = (System.nanoTime() ushr 16) and 0xFFFFFFFFL

                // Open a real TCP socket to the original destination server.
                val sock = Socket()
                try {
                    // protect() marks this socket as "excluded from the VPN".
                    // Without protect(), the OS would send this socket's packets
                    // back through the TUN interface, causing an infinite loop.
                    protect(sock)

                    // Connect to the real server with a 5-second timeout.
                    // InetSocketAddress combines the destination IP string and port.
                    sock.connect(InetSocketAddress(parsed.dstIp, parsed.dstPort), 5000)

                    // Send a SYN-ACK back into TUN to complete the fake 3-way handshake.
                    // The device's TCP stack sees this and believes the server accepted.
                    // Note the swap: srcIp/srcPort use the DESTINATION values because
                    // from the device's perspective, this reply is coming FROM the server.
                    tunOut.writeSynced(buildTcpControl(
                        srcIp  = parsed.dstIp,  srcPort = parsed.dstPort, // "from" the server
                        dstIp  = parsed.srcIp,  dstPort = parsed.srcPort, // "to" the device
                        seq    = serverIsn,          // our starting sequence number
                        ackNum = clientIsn + 1,      // acknowledge the client's SYN (SYN counts as 1 byte)
                        flags  = 0x12                // 0x12 = SYN (0x02) | ACK (0x10)
                    ))

                    // Initialise the two sequence counters.
                    // Each AtomicLong is used from multiple coroutines, so thread-safety matters.
                    val srvSeq = AtomicLong(serverIsn + 1) // our seq starts at ISN+1 (SYN counted as 1)
                    val cliSeq = AtomicLong(clientIsn + 1) // we expect the next client seq to be ISN+1

                    // Launch the RELAY COROUTINE: reads data arriving from the real server
                    // and writes it back into TUN so the device receives it.
                    val relayJob = scope.launch {
                        val buf = ByteArray(8192) // temporary buffer for server data
                        try {
                            // Keep relaying until the coroutine is cancelled or the socket closes
                            while (isActive && !sock.isClosed) {
                                // Blocking read from the real server's socket.
                                // Returns the number of bytes read, or -1 on EOF (server closed).
                                val n = sock.inputStream.read(buf)
                                if (n < 0) break // server closed the connection

                                // Copy exactly n bytes (avoid sending stale data from buf)
                                val payload = buf.copyOf(n)

                                // Build a TCP data packet (PSH+ACK) and inject it into TUN.
                                // The device sees this as data arriving from the server.
                                tunOut.writeSynced(buildTcpData(
                                    srcIp   = parsed.dstIp,  srcPort = parsed.dstPort, // "from" server
                                    dstIp   = parsed.srcIp,  dstPort = parsed.srcPort, // "to" device
                                    seq     = srvSeq.get(),   // our current sequence number
                                    ackNum  = cliSeq.get(),   // acknowledge the client's last byte
                                    payload = payload
                                ))

                                // Advance our sequence number by the number of bytes we just sent.
                                // TCP sequence numbers count bytes, not packets.
                                srvSeq.addAndGet(n.toLong())

                                // Also emit this as an INBOUND event to Flutter.
                                // This lets the UI show traffic flowing from the server TO the device.
                                val inboundEvent = mapOf(
                                    "id"           to "in_${System.nanoTime()}",
                                    "srcIp"        to parsed.dstIp,   // server is the source
                                    "srcPort"      to parsed.dstPort,
                                    "dstIp"        to parsed.srcIp,   // device is the destination
                                    "dstPort"      to parsed.srcPort,
                                    "protocol"     to 6,              // TCP
                                    "sizeBytes"    to n,
                                    "flags"        to 0x18,           // PSH | ACK
                                    "timestamp"    to System.currentTimeMillis(),
                                    "flowIatMean"  to 0.0,
                                    "flowIatStd"   to 0.0,
                                    "flowDuration" to 0L,
                                    "label"        to dnsCache.serviceLabel(parsed.dstIp)
                                )
                                withContext(Dispatchers.Main) { eventSink?.invoke(inboundEvent) }
                            }
                        } catch (_: Exception) {
                            // Socket read error (server closed, network error, etc.) — clean up below
                        }
                        // Connection is done — remove state and close the socket
                        tcpConnections.remove(key)
                        runCatching { sock.close() }
                    }

                    // Store the connection state so future packets for this key can use it
                    tcpConnections[key] = TcpState(sock, relayJob, srvSeq, cliSeq)

                } catch (e: Exception) {
                    // Connection to the real server failed (refused, timeout, etc.)
                    runCatching { sock.close() }

                    // Send RST back to the device so it doesn't hang waiting for a response.
                    // RST tells the device's TCP stack to abort the connection immediately.
                    runCatching {
                        tunOut.writeSynced(buildTcpControl(
                            srcIp  = parsed.dstIp, srcPort = parsed.dstPort,
                            dstIp  = parsed.srcIp, dstPort = parsed.srcPort,
                            seq    = 0, ackNum = clientIsn + 1,
                            flags  = 0x04 // RST
                        ))
                    }
                }
            }

            // ── CASE 2: Connection teardown (FIN or RST from device) ──────────
            // The device wants to close this connection.
            // We cancel the relay coroutine and close the real socket.
            isFin || isRst -> {
                val state = tcpConnections.remove(key) // remove from map and get the state
                state?.relayJob?.cancel()              // stop the relay coroutine
                runCatching { state?.socket?.close() } // close the real socket (ignore errors)
            }

            // ── CASE 3: Data segment (ACK with payload) ───────────────────────
            // The device is sending data to the server (e.g. an HTTP request body).
            isAck && payloadLen > 0 -> {
                // Look up the existing connection state — if we don't have one, drop the packet
                val state = tcpConnections[key] ?: return

                // Extract just the application-layer payload bytes
                val payload = rawBytes.copyOfRange(payloadOff, rawBytes.size)
                try {
                    // Write the payload to the real server socket
                    state.socket.outputStream.write(payload)
                    state.socket.outputStream.flush() // ensure bytes are actually sent

                    // Advance the client-side sequence counter by the payload length.
                    // This tracks what the device has sent so we can ACK it correctly.
                    state.clientSeq.addAndGet(payloadLen.toLong())

                    // Send a pure ACK back to the device.
                    // This tells the device's TCP stack that we received its data,
                    // allowing it to slide its send window forward and send more data.
                    tunOut.writeSynced(buildTcpControl(
                        srcIp  = parsed.dstIp, srcPort = parsed.dstPort,
                        dstIp  = parsed.srcIp, dstPort = parsed.srcPort,
                        seq    = state.serverSeq.get(), // our current sequence position
                        ackNum = state.clientSeq.get(), // acknowledge all bytes received so far
                        flags  = 0x10 // ACK only
                    ))
                } catch (_: Exception) {
                    // Write to the real socket failed — tear down the connection
                    val st = tcpConnections.remove(key)
                    st?.relayJob?.cancel()
                    runCatching { st?.socket?.close() }
                }
            }

            // ── Pure ACK with no payload ───────────────────────────────────────
            // Happens after the device receives our SYN-ACK — it sends back an ACK
            // to complete the 3-way handshake.  Nothing to forward; we ignore it.
        }
    }

    // ── UDP: Per-Packet Protected Socket ─────────────────────────────────────
    //
    // UDP is connectionless — each packet is independent.  We don't need to
    // track state between packets.  For each UDP packet:
    //   1. Create a fresh protected DatagramSocket.
    //   2. Send the payload to the real destination.
    //   3. Wait up to 3 seconds for a response.
    //   4. Inject the response back into TUN.
    //
    // This works for DNS (port 53), NTP (port 123), and most other UDP protocols.

    private suspend fun handleUdp(parsed: ParsedPacket, rawBytes: ByteArray, tunOut: FileOutputStream) {
        // Compute the offset of the UDP payload in rawBytes.
        // UDP header is always exactly 8 bytes, sitting right after the IP header.
        val ipLen        = (rawBytes[0].toInt() and 0x0F) * 4 // IP header length in bytes
        val udpPayloadOff = ipLen + 8                          // skip IP header + 8-byte UDP header

        // Safety check: if the computed offset is past the end of the packet, it's malformed
        if (udpPayloadOff >= rawBytes.size) return

        // Extract just the UDP payload (the actual data, without IP or UDP headers)
        val payload = rawBytes.copyOfRange(udpPayloadOff, rawBytes.size)

        // Create a new UDP socket for this single packet
        val sock = DatagramSocket()
        try {
            // protect() marks this socket as excluded from the VPN tunnel.
            // Without this, the outgoing UDP packet would re-enter TUN and loop forever.
            protect(sock)

            // Set a 3-second receive timeout.
            // If the server doesn't respond in 3 seconds, sock.receive() will throw
            // a SocketTimeoutException which we catch below and drop silently.
            sock.soTimeout = 3000

            // Resolve the destination IP string to an InetAddress object
            val dst = InetAddress.getByName(parsed.dstIp)

            // Send the UDP payload to the real destination server
            sock.send(DatagramPacket(payload, payload.size, dst, parsed.dstPort))

            // Prepare a buffer to receive the server's response
            val respBuf = ByteArray(BUFFER_SIZE)
            val resp    = DatagramPacket(respBuf, respBuf.size)

            // Blocking receive: waits up to soTimeout milliseconds for a response
            sock.receive(resp)

            // respPayload: trim the response to exactly the bytes received
            val respPayload = resp.data.copyOf(resp.length)

            // ── DNS special handling ───────────────────────────────────────────
            // If this was a DNS query (destination port 53), the response is a DNS
            // message containing hostname→IP mappings.  We parse it and cache those
            // mappings so future packets to those IPs can be labelled with service names.
            if (parsed.dstPort == 53) dnsCache.parseAndCache(respPayload)

            // Build a proper UDP IP packet and inject it back into TUN.
            // Swap src and dst so the device sees the response as coming FROM the server.
            tunOut.writeSynced(buildUdpPacket(
                srcIp   = parsed.dstIp,  srcPort = parsed.dstPort, // "from" the server
                dstIp   = parsed.srcIp,  dstPort = parsed.srcPort, // "to" the device
                payload = respPayload
            ))

            // Emit an inbound event to Flutter so the UI shows the server's response
            val inboundEvent = mapOf(
                "id"           to "in_${System.nanoTime()}",
                "srcIp"        to parsed.dstIp,   // server is the source
                "srcPort"      to parsed.dstPort,
                "dstIp"        to parsed.srcIp,   // device is the destination
                "dstPort"      to parsed.srcPort,
                "protocol"     to 17,             // UDP
                "sizeBytes"    to resp.length,
                "flags"        to 0,              // UDP has no flags
                "timestamp"    to System.currentTimeMillis(),
                "flowIatMean"  to 0.0,
                "flowIatStd"   to 0.0,
                "flowDuration" to 0L,
                "label"        to dnsCache.serviceLabel(parsed.dstIp)
            )
            withContext(Dispatchers.Main) { eventSink?.invoke(inboundEvent) }

        } catch (_: Exception) {
            // SocketTimeoutException (no response in 3s), UnknownHostException,
            // or any other network error.  We silently drop it — the app's
            // own timeout mechanism will handle the missing response.
        } finally {
            // Always close the socket, even if an exception was thrown above.
            // UDP sockets are cheap to create but we must not leak them.
            sock.close()
        }
    }

    // ── Packet Builders ───────────────────────────────────────────────────────
    //
    // These functions craft raw IP packets from scratch — byte by byte.
    // The result is written directly into the TUN file descriptor.
    // The device's kernel TCP/IP stack reads them from TUN and treats them
    // as if they arrived from the real network.

    // buildTcpControl() creates a TCP packet with no application-layer payload.
    // Used for control packets: SYN-ACK, ACK (window update), RST.
    private fun buildTcpControl(
        srcIp: String, srcPort: Int,   // the "from" address (often the server's address)
        dstIp: String, dstPort: Int,   // the "to" address (often the device's TUN address)
        seq: Long,                     // TCP sequence number for this packet
        ackNum: Long,                  // TCP acknowledgement number (next byte we expect from the other side)
        flags: Int                     // TCP flags bitmask (0x12=SYN+ACK, 0x10=ACK, 0x04=RST)
    ): ByteArray {
        val totalLen = 40              // 20 bytes IP header + 20 bytes TCP header + 0 payload
        val buf = ByteBuffer.allocate(totalLen)

        // Write the 20-byte IP header
        fillIpHeader(buf, srcIp, dstIp, 6, totalLen) // proto 6 = TCP

        // ── TCP Header ────────────────────────────────────────────────────────
        buf.putShort(srcPort.toShort())                      // source port (2 bytes)
        buf.putShort(dstPort.toShort())                      // destination port (2 bytes)
        buf.putInt((seq and 0xFFFFFFFFL).toInt())            // sequence number (4 bytes)
        buf.putInt((ackNum and 0xFFFFFFFFL).toInt())         // acknowledgement number (4 bytes)
        buf.put(0x50.toByte())        // data offset = 5 words = 20 bytes; reserved bits = 0
        buf.put(flags.toByte())       // TCP control flags
        buf.putShort(65535.toShort()) // receive window size (max: 65535)
        buf.putShort(0)               // checksum — will be computed by patchTcpChecksum()
        buf.putShort(0)               // urgent pointer (not used; set to 0)

        val bytes = buf.array()
        patchIpChecksum(bytes)             // compute and write the IP header checksum
        patchTcpChecksum(bytes, srcIp, dstIp, 20) // compute and write the TCP checksum
        return bytes
    }

    // buildTcpData() creates a TCP packet that carries application payload data.
    // Used to send server response data back to the device (PSH + ACK).
    private fun buildTcpData(
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
        seq: Long,
        ackNum: Long,
        payload: ByteArray             // the application-layer data bytes
    ): ByteArray {
        val totalLen = 40 + payload.size // 20 IP + 20 TCP + payload
        val buf = ByteBuffer.allocate(totalLen)
        fillIpHeader(buf, srcIp, dstIp, 6, totalLen)

        // TCP header (same structure as buildTcpControl)
        buf.putShort(srcPort.toShort())
        buf.putShort(dstPort.toShort())
        buf.putInt((seq and 0xFFFFFFFFL).toInt())
        buf.putInt((ackNum and 0xFFFFFFFFL).toInt())
        buf.put(0x50.toByte())
        buf.put(0x18.toByte())        // 0x18 = PSH (0x08) | ACK (0x10)
                                      // PSH tells the receiver to deliver data immediately
        buf.putShort(65535.toShort())
        buf.putShort(0)               // checksum placeholder
        buf.putShort(0)               // urgent pointer

        // Append the actual payload bytes after the headers
        buf.put(payload)

        val bytes = buf.array()
        patchIpChecksum(bytes)
        patchTcpChecksum(bytes, srcIp, dstIp, 20 + payload.size)
        return bytes
    }

    // buildUdpPacket() creates a complete IP + UDP packet.
    // Used to inject UDP server responses back into TUN.
    private fun buildUdpPacket(
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
        payload: ByteArray
    ): ByteArray {
        val udpLen   = 8 + payload.size      // UDP header is always 8 bytes + payload
        val totalLen = 20 + udpLen           // total packet = 20 IP + 8 UDP + payload
        val buf = ByteBuffer.allocate(totalLen)
        fillIpHeader(buf, srcIp, dstIp, 17, totalLen) // proto 17 = UDP

        // ── UDP Header ────────────────────────────────────────────────────────
        buf.putShort(srcPort.toShort()) // source port (2 bytes)
        buf.putShort(dstPort.toShort()) // destination port (2 bytes)
        buf.putShort(udpLen.toShort())  // length: UDP header + payload in bytes (2 bytes)
        buf.putShort(0)                 // checksum: optional for IPv4, set to 0 (2 bytes)

        // Append the UDP payload
        buf.put(payload)

        val bytes = buf.array()
        patchIpChecksum(bytes) // UDP checksum is optional; only IP checksum is required
        return bytes
    }

    // ── Header Helpers ────────────────────────────────────────────────────────

    // fillIpHeader() writes a standard 20-byte IPv4 header into the ByteBuffer.
    // The buffer's write position must be at byte 0 when this is called.
    private fun fillIpHeader(buf: ByteBuffer, srcIp: String, dstIp: String, proto: Int, totalLen: Int) {
        // Byte 0: Version (4) in the upper nibble, IHL=5 (20 bytes) in the lower nibble
        // 0x45 = 0100 0101 binary = version 4, IHL 5
        buf.put(0x45.toByte())

        // Byte 1: DSCP/ECN — we use 0 (best-effort, no explicit congestion notification)
        buf.put(0)

        // Bytes 2–3: Total length of the entire IP packet (header + payload) in bytes
        buf.putShort(totalLen.toShort())

        // Bytes 4–5: Identification — used for fragment reassembly.  We set 0 because
        // we never fragment packets.
        buf.putShort(0)

        // Bytes 6–7: Flags (3 bits) + Fragment Offset (13 bits).
        // 0x4000 = 0100 0000 0000 0000 binary = DF (Don't Fragment) flag set, offset 0.
        // Setting DF prevents intermediate routers from fragmenting our packets.
        buf.putShort(0x4000.toShort())

        // Byte 8: TTL = 64 — a standard starting TTL; packet is discarded if it reaches 0.
        buf.put(64)

        // Byte 9: Protocol number (6=TCP, 17=UDP)
        buf.put(proto.toByte())

        // Bytes 10–11: IP header checksum — set to 0 now; patchIpChecksum() will fill it in.
        buf.putShort(0)

        // Bytes 12–15: Source IP address (4 bytes)
        // InetAddress.getByName() converts "142.250.74.78" to a 4-byte array.
        buf.put(InetAddress.getByName(srcIp).address)

        // Bytes 16–19: Destination IP address (4 bytes)
        buf.put(InetAddress.getByName(dstIp).address)
    }

    // patchIpChecksum() computes the RFC 791 one's-complement checksum over the
    // first 20 bytes of the packet (the IP header) and writes it into bytes 10–11.
    // This must be called AFTER fillIpHeader() has written everything else.
    private fun patchIpChecksum(bytes: ByteArray) {
        val cs = internetChecksum(bytes, 0, 20) // checksum of bytes 0..19
        bytes[10] = (cs shr 8).toByte()          // high byte of the checksum
        bytes[11] = (cs and 0xFF).toByte()       // low byte of the checksum
    }

    // patchTcpChecksum() computes the TCP checksum and writes it into the TCP header.
    // TCP checksum is special: it is computed over a "pseudo-header" that includes
    // source IP, destination IP, protocol number, and TCP length — plus the real TCP data.
    // This binds the TCP segment to the IP addresses, preventing spoofing.
    private fun patchTcpChecksum(bytes: ByteArray, srcIp: String, dstIp: String, tcpLen: Int) {
        val tcpOff = 20 // TCP header starts at byte 20 (after the 20-byte IP header)

        // Build the pseudo-header in a temporary array:
        //   bytes 0–3 : source IP (4 bytes)
        //   bytes 4–7 : destination IP (4 bytes)
        //   byte  8   : zero (padding)
        //   byte  9   : protocol number (6 for TCP)
        //   bytes 10–11: TCP segment length (header + payload in bytes)
        // Then append the actual TCP segment bytes.
        val pseudo = ByteArray(12 + tcpLen)
        System.arraycopy(InetAddress.getByName(srcIp).address, 0, pseudo, 0, 4) // src IP
        System.arraycopy(InetAddress.getByName(dstIp).address, 0, pseudo, 4, 4) // dst IP
        pseudo[8]  = 0                              // zero pad byte
        pseudo[9]  = 6                              // TCP protocol number
        pseudo[10] = (tcpLen shr 8).toByte()        // TCP length high byte
        pseudo[11] = (tcpLen and 0xFF).toByte()     // TCP length low byte
        System.arraycopy(bytes, tcpOff, pseudo, 12, tcpLen) // copy the real TCP bytes

        // Zero out the checksum field inside the copied TCP bytes before computing.
        // The checksum is computed with its own field set to zero.
        pseudo[12 + 16] = 0 // byte 16 of TCP header = high byte of checksum field
        pseudo[12 + 17] = 0 // byte 17 of TCP header = low byte of checksum field

        // Compute the checksum over the entire pseudo-header + TCP data
        val cs = internetChecksum(pseudo, 0, pseudo.size)

        // Write the result into the TCP header's checksum field (bytes 16–17 of TCP header)
        bytes[tcpOff + 16] = (cs shr 8).toByte()
        bytes[tcpOff + 17] = (cs and 0xFF).toByte()
    }

    // internetChecksum() implements the RFC 791 one's-complement checksum algorithm.
    // It is used for both IP and TCP header verification.
    //
    // Algorithm:
    //   1. Sum all 16-bit words in the data.
    //   2. If the sum overflows 16 bits, add the overflow ("fold" the carry).
    //   3. Return the bitwise NOT (one's complement) of the final sum.
    //
    // The result is 0xFFFF for a correct packet (checksum of data + checksum == 0xFFFF).
    private fun internetChecksum(buf: ByteArray, offset: Int, length: Int): Int {
        var sum = 0
        var i = offset

        // Sum pairs of bytes as 16-bit big-endian words
        while (i < offset + length - 1) {
            // Combine two consecutive bytes into one 16-bit value:
            //   buf[i]   << 8 = high byte
            //   buf[i+1]      = low byte
            // 'and 0xFF' prevents sign extension (Kotlin bytes are signed)
            sum += ((buf[i].toInt() and 0xFF) shl 8) or (buf[i + 1].toInt() and 0xFF)
            i += 2
        }

        // If length is odd, there's one byte left — treat it as the high byte of a 16-bit word
        if ((length and 1) != 0) sum += (buf[offset + length - 1].toInt() and 0xFF) shl 8

        // Fold any carry bits from the upper 16 bits back into the lower 16 bits.
        // Repeat until the upper 16 bits are zero.
        while (sum shr 16 != 0) sum = (sum and 0xFFFF) + (sum shr 16)

        // One's complement: flip all 16 bits and mask to ensure the result is 16-bit
        return sum.inv() and 0xFFFF
    }

    // readU32() reads a big-endian 32-bit unsigned integer from a byte array.
    // Returns it as a Long to avoid Kotlin's signed-int overflow issues.
    // (TCP sequence numbers are unsigned 32-bit values — they wrap at 2^32.)
    private fun readU32(buf: ByteArray, offset: Int): Long =
        ((buf[offset].toLong() and 0xFF) shl 24) or     // byte 0: most significant byte
        ((buf[offset + 1].toLong() and 0xFF) shl 16) or  // byte 1
        ((buf[offset + 2].toLong() and 0xFF) shl 8) or   // byte 2
         (buf[offset + 3].toLong() and 0xFF)              // byte 3: least significant byte

    // writeSynced() is an extension function on FileOutputStream.
    // It writes a byte array and flushes inside a synchronized block.
    // 'synchronized(this)' ensures that two coroutines can never write to the TUN
    // file descriptor at the exact same time — interleaved writes would produce
    // corrupted packets that the device's TCP/IP stack can't parse.
    private fun FileOutputStream.writeSynced(data: ByteArray) {
        synchronized(this) { write(data); flush() }
    }

    // ─────────────────────────────────────────────────────────────────────────

    // onDestroy() is called by Android when the service is stopping.
    // We must release all resources here to avoid memory leaks and fd leaks.
    override fun onDestroy() {
        isRunning = false               // signal the read loop to stop on its next iteration
        clearBlockedIps()               // reset the block list for the next VPN session

        // Remove the foreground notification from the status bar
        stopForeground(STOP_FOREGROUND_REMOVE)

        // Cancel all running coroutines (read loop, all relay jobs, all UDP handlers)
        scope.cancel()

        // Close every open TCP socket.  runCatching{} swallows any IOException
        // so one failed close doesn't prevent the others from running.
        tcpConnections.values.forEach { runCatching { it.socket.close() } }

        // Clear the map — the Socket objects can now be garbage collected
        tcpConnections.clear()

        // Close the TUN file descriptor.  This causes input.read() in the loop to
        // throw an exception (which the loop catches), cleanly ending it.
        vpnInterface?.close()
        vpnInterface = null

        // Reset the flow tracker so it doesn't hold stale data if the VPN is restarted
        flowTracker.reset()

        // Always call super.onDestroy() so Android can clean up the Service base class
        super.onDestroy()
    }
}
