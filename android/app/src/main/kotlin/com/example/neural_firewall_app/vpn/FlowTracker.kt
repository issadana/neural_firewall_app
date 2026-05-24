// FlowTracker.kt
// A "flow" is a single ongoing network conversation identified by its
// 4-tuple: (srcIp, srcPort, dstIp, dstPort).
//
// This class tracks every flow it sees and, for each one, records when
// each packet arrived.  From those timestamps it computes two statistical
// features that the ML model uses to detect anomalies:
//
//   IAT Mean  — average time (ms) between consecutive packets in this flow
//   IAT Std   — standard deviation of those inter-arrival times
//
// A brute-force attack sends packets very rapidly (low IAT, low std dev).
// Normal web traffic has more varied, slower timing.
package com.example.neural_firewall_app.vpn

// abs is imported but currently unused — kept for potential future use
import kotlin.math.abs

// FlowStats is a small data class that bundles the three computed values
// returned after each packet update.  Default values of 0 are used for
// the very first packet in a flow (can't compute IAT with one point).
data class FlowStats(
    val iatMean: Double = 0.0, // mean inter-arrival time in milliseconds
    val iatStd: Double  = 0.0, // standard deviation of inter-arrival times
    val duration: Long  = 0L   // how long this flow has been alive (ms)
)

// FlowTracker is a regular class (not a singleton) because NeuralVpnService
// creates one instance and owns its lifetime.
class FlowTracker {

    // Flow is a private inner data class — only FlowTracker needs to know about it.
    // It stores the identity and history of one network conversation.
    private data class Flow(
        val key: String,                                         // the 4-tuple string used as a map key
        val packets: MutableList<Long> = mutableListOf(),        // timestamps (ms) of each packet seen
        val startTime: Long = System.currentTimeMillis()         // when the first packet was seen
    )

    // flows maps each 4-tuple key to its Flow object.
    // mutableMapOf gives us a LinkedHashMap, which preserves insertion order.
    private val flows = mutableMapOf<String, Flow>()

    // Hard cap on how many concurrent flows we track.
    // Without this, a flood attack could grow the map until we run out of memory.
    private val maxFlows = 10000

    // update() is called once per packet from the TUN read loop.
    // It finds or creates the flow for this packet, records its timestamp,
    // and returns fresh statistics.
    fun update(packet: ParsedPacket): FlowStats {

        // Build a canonical string key from the packet's 4-tuple.
        // e.g. "10.0.0.2:49876-142.250.74.78:443"
        // Two packets belong to the same flow if and only if their keys match.
        val flowKey = "${packet.srcIp}:${packet.srcPort}-${packet.dstIp}:${packet.dstPort}"

        // getOrPut: if flowKey already exists, returns the existing Flow.
        // If not, runs the lambda to create a new Flow and stores it first.
        val flow = flows.getOrPut(flowKey) {
            Flow(flowKey, mutableListOf(), System.currentTimeMillis())
        }

        // Append this packet's arrival time to the flow's history list.
        flow.packets.add(packet.timestamp)

        // ── Sliding window ────────────────────────────────────────────────────
        // Keeping unlimited timestamps would grow memory without bound for
        // long-lived connections (e.g. a streaming session).
        // We cap at 100 and drop the oldest entry when we exceed that.
        // 100 packets give us 99 IAT samples — more than enough for stable stats.
        if (flow.packets.size > 100) {
            flow.packets.removeAt(0) // remove index 0 (the oldest timestamp)
        }

        // ── Memory safety eviction ────────────────────────────────────────────
        // If we are tracking more than maxFlows flows, scan for stale entries.
        // A flow is considered stale if we haven't seen a packet in 5 minutes.
        // removeAll {} iterates the entry set and removes matching entries in-place.
        if (flows.size > maxFlows) {
            val now = System.currentTimeMillis()
            // 300_000 ms = 5 minutes
            flows.entries.removeAll { (_, f) -> now - f.startTime > 300000 }
        }

        // Compute and return fresh statistics for this flow
        return computeStats(flow)
    }

    // computeStats() calculates the three statistical features from the
    // packet timestamps stored in the flow.
    private fun computeStats(flow: Flow): FlowStats {

        // Edge case: no packets recorded yet — return all-zero defaults.
        if (flow.packets.isEmpty()) return FlowStats()

        // Duration is always available: from the very first packet to right now.
        val now = System.currentTimeMillis()
        val duration = now - flow.startTime

        // Edge case: only one packet recorded.
        // IAT requires at least two points (you need a "before" and "after").
        // Return zero IAT stats but the real duration.
        if (flow.packets.size < 2) {
            return FlowStats(iatMean = 0.0, iatStd = 0.0, duration = duration)
        }

        // ── Compute IAT list ──────────────────────────────────────────────────
        // IAT (Inter-Arrival Time) = the gap between packet[i] and packet[i-1].
        // We iterate from index 1 to the end, subtracting the previous timestamp.
        val iats = mutableListOf<Double>()
        for (i in 1 until flow.packets.size) {
            val iat = (flow.packets[i] - flow.packets[i - 1]).toDouble() // delta in ms
            iats.add(iat)
        }

        // ── Mean ─────────────────────────────────────────────────────────────
        // average() is a Kotlin extension on Iterable<Double> — sums and divides.
        val iatMean = iats.average()

        // ── Standard Deviation ────────────────────────────────────────────────
        // std dev = sqrt( mean of squared deviations from the mean )
        // If there's only one IAT value the deviation is undefined → return 0.
        val iatStd = if (iats.size > 1) {
            // Compute variance: average of (each value − mean)²
            val variance = iats.map { (it - iatMean) * (it - iatMean) }.average()
            // Standard deviation = square root of variance
            kotlin.math.sqrt(variance)
        } else {
            0.0
        }

        return FlowStats(iatMean = iatMean, iatStd = iatStd, duration = duration)
    }

    // reset() wipes all tracked flow state.
    // Called in NeuralVpnService.onDestroy() so we don't leak memory across
    // VPN sessions.
    fun reset() {
        flows.clear()
    }
}
