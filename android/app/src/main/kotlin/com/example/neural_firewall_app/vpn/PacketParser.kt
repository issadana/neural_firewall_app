package com.example.neural_firewall_app.vpn

import java.nio.ByteBuffer

// A simple data container holding: unique id, source/dest IPs and ports, 
// protocol number (6=TCP, 17=UDP, 1=ICMP), total size in bytes, 
// TCP flags bitmask, and a timestamp.
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

    // Serializes the packet fields into a Map<String, Any> for sending 
    // to Flutter over the event channel.
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

// Parses raw IPv4 bytes off the TUN interface into a 
// structured ParsedPacket object.
object PacketParser {
    // parse() takes raw bytes and a timestamp
    fun parse(data: ByteArray, timestamp: Long): ParsedPacket? {
        return try {
            //  Reject anything shorter than 20 bytes 
            // => minimum IPv4 header size
            if (data.size < 20) return null


            // Read the first byte 
            val buffer = ByteBuffer.wrap(data)
            // IPv4 header parsing, upper nibble is IP version (4)
            val versionAndHeaderLength = buffer.get().toInt() and 0xFF
            // lower nibble × 4 = header length in bytes. 
            val headerLength = (versionAndHeaderLength and 0x0F) * 4
            // Reject if header < 20 bytes
            if (headerLength < 20 || data.size < headerLength) return null



            // Read DSCP
            val dscp = buffer.get() // ToS field
            // total length
            val totalLength = (buffer.short.toInt() and 0xFFFF)
            // IP identification
            val identification = buffer.short.toInt() and 0xFFFF
            // flags+fragment offset
            val flagsAndOffset = buffer.short.toInt() and 0xFFFF
            // TTL
            val ttl = buffer.get().toInt() and 0xFF
            // protocol number,
            val protocol = buffer.get().toInt() and 0xFF
            // header checksum
            val checksum = buffer.short.toInt() and 0xFFFF


            // Read 4 bytes each for source IP and destination IP
            val srcIpBytes = ByteArray(4)
            buffer.get(srcIpBytes)
            // Format them as dotted-decimal strings ("192.168.1.1")
            val srcIp = srcIpBytes.joinToString(".") { (it.toInt() and 0xFF).toString() }

            // Read 4 bytes each for destination IP
            val dstIpBytes = ByteArray(4)
            buffer.get(dstIpBytes)
            // Format them as dotted-decimal strings ("192.168.1.1")
            val dstIp = dstIpBytes.joinToString(".") { (it.toInt() and 0xFF).toString() }

            var srcPort = 0
            var dstPort = 0
            var flags = 0

            // Parse transport layer
            if (protocol == 6) {
                // TCP
                // Read src port, dst port, sequence number, ack number, 
                // and the data-offset+flags short — the lower byte of that short is the TCP flags bitmask.
                srcPort = (buffer.short.toInt() and 0xFFFF)
                dstPort = (buffer.short.toInt() and 0xFFFF)
                val seqNum = buffer.int
                val ackNum = buffer.int
                val offsetAndFlags = buffer.short.toInt() and 0xFFFF
                flags = offsetAndFlags and 0xFF
            } else if (protocol == 17) {
                // UDP
                // Read src port, dst port, UDP length (checksum is skipped).
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
            // Any exception (malformed packet, buffer underflow) returns null silently.
            null
        }
    }
}
