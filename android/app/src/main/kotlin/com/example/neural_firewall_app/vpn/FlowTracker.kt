package com.example.neural_firewall_app.vpn

import kotlin.math.abs

data class FlowStats(
    val iatMean: Double = 0.0,
    val iatStd: Double = 0.0,
    val duration: Long = 0L
)

class FlowTracker {
    private data class Flow(
        val key: String,
        val packets: MutableList<Long> = mutableListOf(),
        val startTime: Long = System.currentTimeMillis()
    )

    private val flows = mutableMapOf<String, Flow>()
    private val maxFlows = 10000

    fun update(packet: ParsedPacket): FlowStats {
        val flowKey = "${packet.srcIp}:${packet.srcPort}-${packet.dstIp}:${packet.dstPort}"

        val flow = flows.getOrPut(flowKey) {
            Flow(flowKey, mutableListOf(), System.currentTimeMillis())
        }

        flow.packets.add(packet.timestamp)

        // Keep only last 100 packets per flow
        if (flow.packets.size > 100) {
            flow.packets.removeAt(0)
        }

        // Cleanup old flows
        if (flows.size > maxFlows) {
            val now = System.currentTimeMillis()
            flows.entries.removeAll { (_, f) -> now - f.startTime > 300000 } // 5 min
        }

        return computeStats(flow)
    }

    private fun computeStats(flow: Flow): FlowStats {
        if (flow.packets.isEmpty()) return FlowStats()

        val now = System.currentTimeMillis()
        val duration = now - flow.startTime

        if (flow.packets.size < 2) {
            return FlowStats(iatMean = 0.0, iatStd = 0.0, duration = duration)
        }

        val iats = mutableListOf<Double>()
        for (i in 1 until flow.packets.size) {
            val iat = (flow.packets[i] - flow.packets[i - 1]).toDouble()
            iats.add(iat)
        }

        val iatMean = iats.average()
        val iatStd = if (iats.size > 1) {
            val variance = iats.map { (it - iatMean) * (it - iatMean) }.average()
            kotlin.math.sqrt(variance)
        } else {
            0.0
        }

        return FlowStats(iatMean = iatMean, iatStd = iatStd, duration = duration)
    }

    fun reset() {
        flows.clear()
    }
}
