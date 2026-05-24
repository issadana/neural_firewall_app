package com.example.neural_firewall_app.vpn

import kotlin.math.abs

// Holds three values that will be passed to the IDS model
// mean IAT, standard deviation of IAT, and flow duration in milliseconds.
data class FlowStats(
    // iat: inter-arrival time
    val iatMean: Double = 0.0,
    val iatStd: Double = 0.0,
    val duration: Long = 0L
)

class FlowTracker {
    // Internal Flow data class
    // holds a flow key string,
    // a list of packet timestamps (up to 100), 
    // and the flow start time.
    private data class Flow(
        val key: String,
        val packets: MutableList<Long> = mutableListOf(),
        val startTime: Long = System.currentTimeMillis()
    )


    // HashMap keyed by "srcIp:srcPort-dstIp:dstPort" strings.
    private val flows = mutableMapOf<String, Flow>()
    // Memory cap
    private val maxFlows = 10000

    fun update(packet: ParsedPacket): FlowStats {
        // Builds the flow key from the packet's 4-tuple.
        val flowKey = "${packet.srcIp}:${packet.srcPort}-${packet.dstIp}:${packet.dstPort}"

        // Gets or creates a Flow entry for this key.
        val flow = flows.getOrPut(flowKey) {
            Flow(flowKey, mutableListOf(), System.currentTimeMillis())
        }

        // Appends the packet's timestamp to the flow's packet list.
        flow.packets.add(packet.timestamp)

        // Sliding window — if more than 100 packets, drop the oldest
        // Keep only last 100 packets per flow.
        if (flow.packets.size > 100) {
            flow.packets.removeAt(0)
        }

        // Memory safety — if over 10,000 flows exist, evict any flows older than 5 mins
        // Cleanup old flows
        if (flows.size > maxFlows) {
            val now = System.currentTimeMillis()
            flows.entries.removeAll { (_, f) -> now - f.startTime > 300000 } // 5 min
        }
        // Returns computed stats for this flow
        return computeStats(flow)
    }




    private fun computeStats(flow: Flow): FlowStats {
        // Edge cases — empty list returns zeroed stats; 
        // single packet returns duration only (can't compute IAT with one point)
        if (flow.packets.isEmpty()) return FlowStats()

        val now = System.currentTimeMillis()
        val duration = now - flow.startTime

        if (flow.packets.size < 2) {
            return FlowStats(iatMean = 0.0, iatStd = 0.0, duration = duration)
        }
        // Computes the list of IATs
        // the time difference between each consecutive pair of packet timestamps
        val iats = mutableListOf<Double>()
        for (i in 1 until flow.packets.size) {
            val iat = (flow.packets[i] - flow.packets[i - 1]).toDouble()
            iats.add(iat)
        }

        // Mean IAT = average of all IAT values
        val iatMean = iats.average()

        // IAT std dev = sqrt of the variance. 
        // If only one IAT exists, std dev is 0
        val iatStd = if (iats.size > 1) {
            val variance = iats.map { (it - iatMean) * (it - iatMean) }.average()
            kotlin.math.sqrt(variance)
        } else {
            0.0
        }

        return FlowStats(iatMean = iatMean, iatStd = iatStd, duration = duration)
    }



    // Clears all tracked flows (called on service shutdown).
    fun reset() {
        flows.clear()
    }
}
