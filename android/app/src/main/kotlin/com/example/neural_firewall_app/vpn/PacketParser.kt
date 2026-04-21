package com.example.neural_firewall_app.vpn

import java.nio.ByteBuffer

data class ParsedPacket(
    val id: String,
    val srcIp: String,
    val srcPort: Int,
    val dstIp: String,
    val dstPort: Int,
    val protocol: Int,  // 6=TCP, 17=UDP, 1=ICMP
    val sizeBytes: Int,
    val flags: Int,     // TCP flags
    val timestamp: Long
) {
    fun toJson(): Map<String, Any> = mapOf(
        "id" to id,
        "srcIp" to srcIp,
        "srcPort" to srcPort,
        "dstIp" to dstIp,
        "dstPort" to dstPort,
        "protocol" to protocol,
        "sizeBytes" to sizeBytes,
        "flags" to flags,
        "timestamp" to timestamp
    )
}

object PacketParser {
    fun parse(data: ByteArray, timestamp: Long): ParsedPacket? {
        return try {
            if (data.size < 20) return null

            val buffer = ByteBuffer.wrap(data)

            // IPv4 header parsing
            val versionAndHeaderLength = buffer.get().toInt() and 0xFF
            val headerLength = (versionAndHeaderLength and 0x0F) * 4
            if (headerLength < 20 || data.size < headerLength) return null

            val dscp = buffer.get() // ToS field
            val totalLength = (buffer.short.toInt() and 0xFFFF)
            val identification = buffer.short.toInt() and 0xFFFF
            val flagsAndOffset = buffer.short.toInt() and 0xFFFF
            val ttl = buffer.get().toInt() and 0xFF
            val protocol = buffer.get().toInt() and 0xFF
            val checksum = buffer.short.toInt() and 0xFFFF

            val srcIpBytes = ByteArray(4)
            buffer.get(srcIpBytes)
            val srcIp = srcIpBytes.joinToString(".") { (it.toInt() and 0xFF).toString() }

            val dstIpBytes = ByteArray(4)
            buffer.get(dstIpBytes)
            val dstIp = dstIpBytes.joinToString(".") { (it.toInt() and 0xFF).toString() }

            var srcPort = 0
            var dstPort = 0
            var flags = 0

            // Parse transport layer
            if (protocol == 6) {
                // TCP
                srcPort = (buffer.short.toInt() and 0xFFFF)
                dstPort = (buffer.short.toInt() and 0xFFFF)
                val seqNum = buffer.int
                val ackNum = buffer.int
                val offsetAndFlags = buffer.short.toInt() and 0xFFFF
                flags = offsetAndFlags and 0xFF
            } else if (protocol == 17) {
                // UDP
                srcPort = (buffer.short.toInt() and 0xFFFF)
                dstPort = (buffer.short.toInt() and 0xFFFF)
                val length = buffer.short.toInt() and 0xFFFF
            }

            return ParsedPacket(
                id = "pkt_${System.currentTimeMillis()}_${hashCode()}",
                srcIp = srcIp,
                srcPort = srcPort,
                dstIp = dstIp,
                dstPort = dstPort,
                protocol = protocol,
                sizeBytes = totalLength,
                flags = flags,
                timestamp = timestamp
            )
        } catch (e: Exception) {
            null
        }
    }
}
