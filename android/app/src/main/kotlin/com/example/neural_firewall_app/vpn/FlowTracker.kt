// FlowTracker.kt
// A "flow" is a single ongoing network conversation identified by its
// 4-tuple: (srcIp, srcPort, dstIp, dstPort).
//
// This class tracks every flow it sees and, for each one, records when each
// packet arrived AND in which direction.  From that it derives the timing and
// volume features the ML models were trained on (CIC-IDS style):
//
//   iat_mean / iat_std — gap between consecutive packets (microseconds)
//   duration           — age of the flow (microseconds)
//   fwd_pkts / bwd_pkts— forward (device→server) and backward packet counts
//   fwd_max / fwd_mean — max / mean forward packet size (bytes)
//   fwd_rate           — forward packets per second
//   idle_mean          — mean of "idle" gaps (microseconds)
//   pkt_size_avg       — mean packet size across the whole flow (bytes)
//
// Direction matters: forward = originated by the device, backward = the
// server's reply.  Both directions are folded into ONE flow via a canonical
// key, so fwd/bwd counts and rates are meaningful.
//
// Units note: the CIC-IDS feature set (and therefore scaler_params.json) uses
// MICROSECONDS for timing features.  Our TUN timestamps are millisecond
// resolution, so we scale ms → µs to land in the distribution the models were
// trained on.  Sub-millisecond gaps collapse to 0 — an accepted limitation of
// userspace ms-resolution capture.
package com.example.neural_firewall_app.vpn

import kotlin.math.sqrt

// FlowStats bundles the computed features returned after each packet update.
// Defaults of 0 cover the first packet in a flow (no IAT computable yet).
data class FlowStats(
    val iatMean: Double = 0.0,    // microseconds
    val iatStd: Double  = 0.0,    // microseconds
    val duration: Long  = 0L,     // microseconds
    val fwdPkts: Int     = 0,
    val bwdPkts: Int     = 0,
    val fwdMax: Int      = 0,     // bytes
    val fwdMean: Double  = 0.0,   // bytes
    val fwdRate: Double  = 0.0,   // forward packets per second
    val idleMean: Double = 0.0,   // microseconds
    val pktSizeAvg: Double = 0.0  // bytes (all packets)
)

class FlowTracker {

    // Flow stores the identity and running state of one conversation.
    private data class Flow(
        val key: String,
        // Arrival timestamps (ms) across BOTH directions, in arrival order.
        val arrivals: MutableList<Long> = mutableListOf(),
        val startTime: Long = System.currentTimeMillis(),
        var fwdPkts: Int = 0,
        var bwdPkts: Int = 0,
        var fwdBytes: Long = 0,
        var fwdMax: Int = 0,
        var totalBytes: Long = 0,
        var totalPkts: Int = 0,
    )

    private val flows = mutableMapOf<String, Flow>()
    private val maxFlows = 10000

    // A gap longer than this (ms) is treated as an "idle" period (CIC uses a
    // ~1 s activity timeout). Gaps above it feed idle_mean.
    private val idleThresholdMs = 1000L

    // Convenience overload for the outbound read loop, which holds a full
    // ParsedPacket. Forward = device→server, so isForward defaults to true.
    fun update(packet: ParsedPacket, isForward: Boolean = true): FlowStats =
        update(
            packet.srcIp, packet.srcPort, packet.dstIp, packet.dstPort,
            packet.sizeBytes, packet.timestamp, isForward,
        )

    // Core update. The 4-tuple MUST always be passed in forward (device-side as
    // src) orientation so both directions map to the same canonical key; the
    // [isForward] flag says which direction THIS packet travelled.
    //
    // @Synchronized: unlike the original (read-loop only), this is now called
    // from the read loop AND from every TCP relay / UDP handler coroutine on the
    // IO pool, so all map + flow mutations must be serialised.
    @Synchronized
    fun update(
        fwdSrcIp: String,
        fwdSrcPort: Int,
        fwdDstIp: String,
        fwdDstPort: Int,
        sizeBytes: Int,
        timestamp: Long,
        isForward: Boolean,
    ): FlowStats {
        val flowKey = "$fwdSrcIp:$fwdSrcPort-$fwdDstIp:$fwdDstPort"

        val flow = flows.getOrPut(flowKey) { Flow(flowKey) }

        // Record arrival time (sliding window of 100 across both directions).
        flow.arrivals.add(timestamp)
        if (flow.arrivals.size > 100) flow.arrivals.removeAt(0)

        // Volume counters.
        flow.totalPkts++
        flow.totalBytes += sizeBytes
        if (isForward) {
            flow.fwdPkts++
            flow.fwdBytes += sizeBytes
            if (sizeBytes > flow.fwdMax) flow.fwdMax = sizeBytes
        } else {
            flow.bwdPkts++
        }

        // Memory-safety eviction: drop flows idle for > 5 minutes once we're
        // tracking too many.
        if (flows.size > maxFlows) {
            val now = System.currentTimeMillis()
            flows.entries.removeAll { (_, f) -> now - f.startTime > 300000 }
        }

        return computeStats(flow)
    }

    private fun computeStats(flow: Flow): FlowStats {
        val now = System.currentTimeMillis()
        val durationUs = (now - flow.startTime) * 1000L
        val durationSec = (now - flow.startTime) / 1000.0

        val pktSizeAvg =
            if (flow.totalPkts > 0) flow.totalBytes.toDouble() / flow.totalPkts else 0.0
        val fwdMean =
            if (flow.fwdPkts > 0) flow.fwdBytes.toDouble() / flow.fwdPkts else 0.0
        val fwdRate =
            if (durationSec > 0.0) flow.fwdPkts / durationSec else 0.0

        // IAT / idle need at least two arrivals.
        if (flow.arrivals.size < 2) {
            return FlowStats(
                duration = durationUs,
                fwdPkts = flow.fwdPkts,
                bwdPkts = flow.bwdPkts,
                fwdMax = flow.fwdMax,
                fwdMean = fwdMean,
                fwdRate = fwdRate,
                pktSizeAvg = pktSizeAvg,
            )
        }

        // Inter-arrival times (µs) and idle periods (gaps above the threshold).
        val iats = ArrayList<Double>(flow.arrivals.size - 1)
        val idles = ArrayList<Double>()
        for (i in 1 until flow.arrivals.size) {
            val gapMs = (flow.arrivals[i] - flow.arrivals[i - 1]).toDouble()
            iats.add(gapMs * 1000.0)
            if (gapMs > idleThresholdMs) idles.add(gapMs * 1000.0)
        }

        val iatMean = iats.average()
        val iatStd = if (iats.size > 1) {
            val variance = iats.map { (it - iatMean) * (it - iatMean) }.average()
            sqrt(variance)
        } else {
            0.0
        }
        val idleMean = if (idles.isNotEmpty()) idles.average() else 0.0

        return FlowStats(
            iatMean = iatMean,
            iatStd = iatStd,
            duration = durationUs,
            fwdPkts = flow.fwdPkts,
            bwdPkts = flow.bwdPkts,
            fwdMax = flow.fwdMax,
            fwdMean = fwdMean,
            fwdRate = fwdRate,
            idleMean = idleMean,
            pktSizeAvg = pktSizeAvg,
        )
    }

    // reset() wipes all tracked flow state (called in onDestroy()).
    @Synchronized
    fun reset() {
        flows.clear()
    }
}
