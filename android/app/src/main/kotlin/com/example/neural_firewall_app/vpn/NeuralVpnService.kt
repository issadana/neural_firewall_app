package com.example.neural_firewall_app.vpn

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.io.FileOutputStream

class NeuralVpnService : VpnService() {
    companion object {
        private var eventSink: ((Any) -> Unit)? = null
        private const val BUFFER_SIZE = 32767
        @JvmStatic @Volatile var isRunning = false

        fun setEventSink(sink: ((Any) -> Unit)?) {
            eventSink = sink
        }
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val flowTracker = FlowTracker()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true
        scope.launch {
            startCapture()
        }
        return START_STICKY
    }

    private suspend fun startCapture() {
        try {
            vpnInterface = Builder()
                .addAddress("10.0.0.2", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("8.8.8.8")
                .setSession("NeuralFirewall")
                .setMtu(1500)
                .establish()

            if (vpnInterface == null) {
                return
            }

            readPacketLoop()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private suspend fun readPacketLoop() {
        try {
            val fd = vpnInterface?.fileDescriptor ?: return
            val input = FileInputStream(fd)
            val output = FileOutputStream(fd)
            val buffer = ByteArray(BUFFER_SIZE)

            while (isRunning && !Thread.currentThread().isInterrupted) {
                try {
                    val length = input.read(buffer)
                    if (length <= 0) {
                        delay(10)
                        continue
                    }

                    val rawBytes = buffer.copyOf(length)
                    val parsed = PacketParser.parse(rawBytes, System.currentTimeMillis())

                    if (parsed != null) {
                        val flowStats = flowTracker.update(parsed)
                        val enriched = mapOf(
                            "id" to parsed.id,
                            "srcIp" to parsed.srcIp,
                            "srcPort" to parsed.srcPort,
                            "dstIp" to parsed.dstIp,
                            "dstPort" to parsed.dstPort,
                            "protocol" to parsed.protocol,
                            "sizeBytes" to parsed.sizeBytes,
                            "flags" to parsed.flags,
                            "timestamp" to parsed.timestamp,
                            "flowIatMean" to flowStats.iatMean,
                            "flowIatStd" to flowStats.iatStd,
                            "flowDuration" to flowStats.duration
                        )

                        withContext(Dispatchers.Main) {
                            eventSink?.invoke(enriched)
                        }
                    }

                    // Write packet back
                    output.write(rawBytes, 0, length)
                    output.flush()
                } catch (e: Exception) {
                    if (isRunning) e.printStackTrace()
                    delay(10)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        isRunning = false
        scope.cancel()
        vpnInterface?.close()
        vpnInterface = null
        flowTracker.reset()
        super.onDestroy()
    }
}
