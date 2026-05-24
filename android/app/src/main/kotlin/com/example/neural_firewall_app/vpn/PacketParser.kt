// PacketParser.kt
// Responsible for one thing: reading raw IPv4 bytes that came off the TUN
// interface and turning them into a structured ParsedPacket object the rest
// of the app can use.  Nothing in here touches the network — it only reads.
package com.example.neural_firewall_app.vpn

// ByteBuffer wraps a byte array and lets us call get()/getShort()/getInt()
// instead of manually indexing into the array with offsets.
import java.nio.ByteBuffer

// ParsedPacket is a Kotlin data class — a plain container with no logic.
// It carries every field the IDS and the Flutter UI need from a single packet.
data class ParsedPacket(
    val id: String,       // unique string so Flutter can key each row in the table
    val srcIp: String,    // source IP as dotted-decimal, e.g. "10.0.0.2"
    val srcPort: Int,     // source port (0 for ICMP, which has no ports)
    val dstIp: String,    // destination IP as dotted-decimal, e.g. "142.250.74.78"
    val dstPort: Int,     // destination port, e.g. 443 for HTTPS
    val protocol: Int,    // IP protocol number: 6 = TCP, 17 = UDP, 1 = ICMP
    val sizeBytes: Int,   // total wire length of the IP packet in bytes
    val flags: Int,       // TCP control-flags bitmask (SYN=0x02, ACK=0x10, FIN=0x01, RST=0x04)
    val timestamp: Long   // Unix epoch ms when this packet was read from the TUN
) {
    // toJson() converts this object into a plain Map<String, Any>.
    // Flutter's EventChannel requires plain Java/Kotlin types — it cannot
    // send a ParsedPacket directly, so we serialise to a Map first.
    fun toJson(): Map<String, Any> = mapOf(
        "id"        to id,
        "srcIp"     to srcIp,
        "srcPort"   to srcPort,
        "dstIp"     to dstIp,
        "dstPort"   to dstPort,
        "protocol"  to protocol,
        "sizeBytes" to sizeBytes,
        "flags"     to flags,
        "timestamp" to timestamp
    )
}

// PacketParser is declared as an 'object' (Kotlin singleton).
// There is never more than one instance; every call goes to the same instance.
// This is fine because parse() is stateless — it does not keep any data between calls.
object PacketParser {

    // parse() is called once per packet in the TUN read loop.
    // data      : the raw bytes read from the TUN file descriptor (one complete IP packet)
    // timestamp : the millisecond clock value at the moment we read the packet
    // Returns   : a filled ParsedPacket, or null if the bytes are too short / malformed
    fun parse(data: ByteArray, timestamp: Long): ParsedPacket? {
        return try {

            // ── Minimum size check ────────────────────────────────────────────
            // A valid IPv4 header is at minimum 20 bytes.
            // If we got fewer bytes than that, this is not a real packet.
            if (data.size < 20) return null

            // Wrap the raw byte array in a ByteBuffer.
            // ByteBuffer.wrap() does NOT copy the array — it just creates a view.
            // Each call to get()/getShort()/getInt() advances an internal read cursor.
            val buffer = ByteBuffer.wrap(data)

            // ── IPv4 Header — Byte 0 ─────────────────────────────────────────
            // Byte 0 packs two 4-bit fields:
            //   upper nibble (bits 7-4) = IP version  →  must be 4 for IPv4
            //   lower nibble (bits 3-0) = IHL (Internet Header Length) in 32-bit words
            // We need IHL to know where the IP header ends and the TCP/UDP header begins.
            val versionAndHeaderLength = buffer.get().toInt() and 0xFF
            // Isolate the lower nibble with AND 0x0F, then multiply by 4 (bytes per word)
            val headerLength = (versionAndHeaderLength and 0x0F) * 4

            // If the header claims it's smaller than 20 bytes, or the packet is
            // physically shorter than the declared header, reject it.
            if (headerLength < 20 || data.size < headerLength) return null

            // ── Byte 1: DSCP / ToS ───────────────────────────────────────────
            // Differentiated Services Code Point — used for QoS priority.
            // We read past it to advance the cursor; we don't use the value.
            val dscp = buffer.get()

            // ── Bytes 2–3: Total Length ──────────────────────────────────────
            // The total IP packet length in bytes (header + payload).
            // This is the authoritative size — we store it as sizeBytes.
            // 'and 0xFFFF' converts the signed Short to an unsigned Int (0–65535).
            val totalLength = (buffer.short.toInt() and 0xFFFF)

            // ── Bytes 4–5: Identification ────────────────────────────────────
            // A 16-bit ID used to reassemble fragmented packets.
            // We don't do reassembly here, so we just read past it.
            val identification = buffer.short.toInt() and 0xFFFF

            // ── Bytes 6–7: Flags + Fragment Offset ───────────────────────────
            // 3 flag bits (Don't Fragment, More Fragments) + 13-bit fragment offset.
            // Not needed here — read past to advance the cursor.
            val flagsAndOffset = buffer.short.toInt() and 0xFFFF

            // ── Byte 8: TTL (Time To Live) ───────────────────────────────────
            // Number of hops before the packet is discarded by a router.
            // We read it but don't use it.
            val ttl = buffer.get().toInt() and 0xFF

            // ── Byte 9: Protocol ─────────────────────────────────────────────
            // Which transport-layer protocol follows the IP header:
            //   1  = ICMP  (ping / traceroute)
            //   6  = TCP   (most web traffic)
            //   17 = UDP   (DNS, video streaming, etc.)
            val protocol = buffer.get().toInt() and 0xFF

            // ── Bytes 10–11: Header Checksum ─────────────────────────────────
            // Integrity check over the IP header fields.
            // We trust the kernel's network stack has already verified it.
            val checksum = buffer.short.toInt() and 0xFFFF

            // ── Bytes 12–15: Source IP Address ───────────────────────────────
            // Four bytes, one per octet of the IPv4 address.
            val srcIpBytes = ByteArray(4)
            buffer.get(srcIpBytes) // copies exactly 4 bytes from the buffer into the array

            // Convert each byte to its unsigned decimal value (0–255) and join with "."
            // e.g. [10, 0, 0, 2] → "10.0.0.2"
            val srcIp = srcIpBytes.joinToString(".") { (it.toInt() and 0xFF).toString() }

            // ── Bytes 16–19: Destination IP Address ──────────────────────────
            val dstIpBytes = ByteArray(4)
            buffer.get(dstIpBytes)
            val dstIp = dstIpBytes.joinToString(".") { (it.toInt() and 0xFF).toString() }

            // Default ports and flags to 0.
            // ICMP does not have port numbers, so these stay 0 for ICMP packets.
            var srcPort = 0
            var dstPort = 0
            var flags = 0

            // ── Transport Layer ───────────────────────────────────────────────
            // The buffer cursor is now positioned right after the IP header,
            // pointing at the first byte of the TCP or UDP header.

            if (protocol == 6) {
                // ── TCP Header ────────────────────────────────────────────────
                // TCP header layout (minimum 20 bytes):
                //   bytes 0–1  : source port
                //   bytes 2–3  : destination port
                //   bytes 4–7  : sequence number
                //   bytes 8–11 : acknowledgement number
                //   byte  12   : data offset (upper 4 bits) + reserved (lower 4 bits)
                //   byte  13   : TCP control flags
                //   bytes 14–15: receive window size
                //   bytes 16–17: checksum
                //   bytes 18–19: urgent pointer

                srcPort = (buffer.short.toInt() and 0xFFFF) // bytes 0–1
                dstPort = (buffer.short.toInt() and 0xFFFF) // bytes 2–3

                // Read and discard sequence number (4 bytes) — we don't need it here
                val seqNum = buffer.int

                // Read and discard acknowledgement number (4 bytes)
                val ackNum = buffer.int

                // Bytes 12–13 together: the upper byte holds the data-offset field,
                // and the lower byte holds all 8 TCP flag bits.
                // We read both as a single 16-bit value.
                val offsetAndFlags = buffer.short.toInt() and 0xFFFF

                // The lower byte (bits 0–7) is the flags byte.
                // Common flags: URG=0x20, ACK=0x10, PSH=0x08, RST=0x04, SYN=0x02, FIN=0x01
                flags = offsetAndFlags and 0xFF

            } else if (protocol == 17) {
                // ── UDP Header ────────────────────────────────────────────────
                // UDP header is always exactly 8 bytes:
                //   bytes 0–1: source port
                //   bytes 2–3: destination port
                //   bytes 4–5: length (header + payload in bytes)
                //   bytes 6–7: checksum (optional in IPv4)

                srcPort = (buffer.short.toInt() and 0xFFFF) // bytes 0–1
                dstPort = (buffer.short.toInt() and 0xFFFF) // bytes 2–3

                // Read and discard length — we already have sizeBytes from the IP header
                val length = buffer.short.toInt() and 0xFFFF

                // Checksum is left in the buffer; ByteBuffer cursor advances automatically
                // when we read the next field, but since we don't read it here the cursor
                // just sits there — that's fine because we're done with UDP parsing.
            }
            // For ICMP (protocol == 1) we only needed the IP-layer src/dst IPs,
            // so no additional parsing is required.

            // ── Build and return the result ───────────────────────────────────
            return ParsedPacket(
                // Combine the current millisecond time and this object's hash code for
                // a "unique enough" ID without needing a shared counter.
                id        = "pkt_${System.currentTimeMillis()}_${hashCode()}",
                srcIp     = srcIp,
                srcPort   = srcPort,
                dstIp     = dstIp,
                dstPort   = dstPort,
                protocol  = protocol,
                sizeBytes = totalLength, // the value from the IP header's total-length field
                flags     = flags,       // TCP flags bitmask (0 for UDP and ICMP)
                timestamp = timestamp    // the value passed in by the read loop
            )

        } catch (e: Exception) {
            // A ByteBuffer.get() throws BufferUnderflowException if there aren't
            // enough bytes left (truncated packet).  Any other unexpected format
            // also lands here.  We return null and the caller silently drops this packet.
            null
        }
    }
}
