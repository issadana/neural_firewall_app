// DnsCache.kt
// Every time your device opens a website or connects to an app's server,
// it first sends a DNS query: "what is the IP address for youtube.com?".
// The DNS response comes back with one or more IP addresses.
//
// This class intercepts those DNS responses as they pass through our TUN
// interface, parses them, and builds a lookup table:
//
//   IP address  →  hostname  (e.g. "142.250.74.78" → "youtube.com")
//
// Later, when we see a TCP/UDP packet going to 142.250.74.78, we can look
// it up and show "YouTube" in the UI instead of a raw IP address.
package com.example.neural_firewall_app.vpn

// ConcurrentHashMap is thread-safe: the TUN read loop (IO dispatcher) and
// the DNS parsing can both access the cache from different coroutines
// without causing data corruption or crashes.
import java.util.concurrent.ConcurrentHashMap

class DnsCache {

    // The main lookup table: maps an IPv4 address string to the hostname
    // that was resolved to that address.
    // e.g. { "142.250.74.78" → "youtube.com", "8.8.8.8" → "dns.google" }
    private val cache = ConcurrentHashMap<String, String>()

    // lookup() returns the hostname for a given IP, or null if unknown.
    // Used directly when you want the raw hostname rather than a label.
    fun lookup(ip: String): String? = cache[ip]

    // parseAndCache() is called with the raw bytes of a DNS response payload
    // (the UDP payload, not the full IP+UDP packet — just the DNS bytes).
    // It parses the response and stores every A-record (IPv4 address) it finds.
    fun parseAndCache(dnsPayload: ByteArray) {
        try {
            // ── Minimum size check ─────────────────────────────────────────────
            // Every DNS message starts with a 12-byte fixed header.
            // Anything shorter is not a valid DNS message.
            if (dnsPayload.size < 12) return

            // ── DNS Header (bytes 0–11) ────────────────────────────────────────
            // Layout of the 12-byte DNS header:
            //   bytes 0–1: Transaction ID  (matches query to response)
            //   bytes 2–3: Flags           (QR bit, opcode, RCODE, etc.)
            //   bytes 4–5: QDCOUNT         (number of questions)
            //   bytes 6–7: ANCOUNT         (number of answer records)
            //   bytes 8–9: NSCOUNT         (number of authority records — not used)
            //   bytes 10–11: ARCOUNT       (number of additional records — not used)

            // Read bytes 2–3 as a 16-bit flags field.
            // We build the 16-bit value manually because ByteArray has no getShort().
            // (byte and 0xFF) removes the sign extension that Kotlin applies to bytes.
            // (shl 8) shifts the high byte 8 positions left, then OR with the low byte.
            val flags = ((dnsPayload[2].toInt() and 0xFF) shl 8) or (dnsPayload[3].toInt() and 0xFF)

            // The QR bit is the most significant bit of the flags field (bit 15).
            // QR = 1 means this is a RESPONSE.  QR = 0 means it is a QUERY.
            // We only want to parse responses — queries don't contain IP addresses.
            if ((flags and 0x8000) == 0) return // not a response, skip

            // QDCOUNT: how many questions are in this message (usually 1)
            val qdcount = ((dnsPayload[4].toInt() and 0xFF) shl 8) or (dnsPayload[5].toInt() and 0xFF)

            // ANCOUNT: how many answer records follow the question section
            val ancount = ((dnsPayload[6].toInt() and 0xFF) shl 8) or (dnsPayload[7].toInt() and 0xFF)

            // If there are no answer records there's nothing to cache
            if (ancount == 0) return

            // ── Question Section ───────────────────────────────────────────────
            // The question section starts at byte 12 (right after the header).
            // We use 'offset' as our read cursor into dnsPayload.
            var offset = 12

            // parseName() reads the DNS name at 'offset' and returns it as a
            // dotted string like "youtube.com".
            // We read the name from the FIRST question to get the queried hostname.
            val hostname = parseName(dnsPayload, offset)

            // Now skip past ALL questions to reach the answer section.
            // Each question is: NAME (variable) + QTYPE (2 bytes) + QCLASS (2 bytes)
            for (i in 0 until qdcount) {
                offset = skipName(dnsPayload, offset) + 4 // +4 skips QTYPE and QCLASS
            }

            // ── Answer Section ─────────────────────────────────────────────────
            // Each answer record (Resource Record / RR) has this layout:
            //   NAME     : variable length (often a 2-byte compression pointer)
            //   TYPE     : 2 bytes  (1 = A record = IPv4 address)
            //   CLASS    : 2 bytes  (1 = IN = Internet)
            //   TTL      : 4 bytes  (how long to cache this record, in seconds)
            //   RDLENGTH : 2 bytes  (length of the RDATA field that follows)
            //   RDATA    : RDLENGTH bytes  (the actual data, e.g. 4 bytes for an A record)

            for (i in 0 until ancount) {
                // Safety: stop if we've run past the end of the buffer
                if (offset >= dnsPayload.size) break

                // Skip past the NAME field of this answer record.
                // skipName() returns the offset of the byte AFTER the name.
                offset = skipName(dnsPayload, offset)

                // We need at least 10 more bytes: TYPE(2) + CLASS(2) + TTL(4) + RDLENGTH(2)
                if (offset + 10 > dnsPayload.size) break

                // Read TYPE (2 bytes): 1 = A record (IPv4), 28 = AAAA (IPv6), 5 = CNAME, etc.
                val type = ((dnsPayload[offset].toInt() and 0xFF) shl 8) or
                           (dnsPayload[offset + 1].toInt() and 0xFF)

                // Read RDLENGTH (bytes 8–9 of the fixed 10-byte section).
                // Bytes 2–3 are CLASS, bytes 4–7 are TTL — we skip them but count them.
                val rdlength = ((dnsPayload[offset + 8].toInt() and 0xFF) shl 8) or
                               (dnsPayload[offset + 9].toInt() and 0xFF)

                // Advance past the 10-byte fixed section (TYPE + CLASS + TTL + RDLENGTH)
                // to reach the start of RDATA.
                offset += 10

                // We only care about A records (type == 1):
                //   - rdlength must be exactly 4 (IPv4 addresses are always 4 bytes)
                //   - there must be at least 4 bytes remaining in the buffer
                if (type == 1 && rdlength == 4 && offset + 4 <= dnsPayload.size) {
                    // Read the 4 RDATA bytes and format as dotted-decimal
                    val ip = "${dnsPayload[offset].toInt() and 0xFF}." +
                             "${dnsPayload[offset + 1].toInt() and 0xFF}." +
                             "${dnsPayload[offset + 2].toInt() and 0xFF}." +
                             "${dnsPayload[offset + 3].toInt() and 0xFF}"

                    // Store the mapping: this IP was resolved from the queried hostname.
                    // Only cache if we actually got a non-empty hostname.
                    if (hostname.isNotEmpty()) cache[ip] = hostname
                }

                // Advance past this record's RDATA to reach the next record
                offset += rdlength
            }
        } catch (_: Exception) {
            // Malformed DNS packet, unexpected buffer overrun, etc.
            // We silently ignore it — a failed cache miss just means the UI
            // won't show a label for that IP, which is fine.
        }
    }

    // serviceLabel() is the main public query method.
    // Given an IP address, it looks up the cached hostname and maps it to
    // a human-readable app/service name like "YouTube" or "WhatsApp".
    // Returns "" (empty string) if the IP is not in the cache yet.
    fun serviceLabel(ip: String): String {
        // If we don't know this IP yet, return empty — the UI shows nothing.
        val host = cache[ip] ?: return ""
        // We know the hostname; now map it to a friendly label.
        return hostToLabel(host)
    }

    // ── DNS Name Parsing ──────────────────────────────────────────────────────

    // parseName() reads a DNS "domain name" starting at startOffset.
    // DNS names are encoded as a sequence of labels:
    //   [length byte][label bytes][length byte][label bytes]...[0x00]
    // e.g. "youtube.com" is encoded as: 7 youtube 3 com 0
    //
    // DNS also supports "compression pointers": a 2-byte marker (upper bits = 11)
    // that says "the rest of the name is at this other offset in the message".
    // This saves space by avoiding repetition.
    //
    // Returns the full name as a dotted string, e.g. "r3---sn-p5qlsnee.googlevideo.com"
    private fun parseName(data: ByteArray, startOffset: Int): String {
        val parts = mutableListOf<String>() // accumulates each label
        var offset = startOffset
        var jumped = false  // tracks whether we followed a compression pointer
        var safety = 0      // prevents infinite loops from malformed/circular pointers

        while (offset < data.size && safety++ < 128) {
            val len = data[offset].toInt() and 0xFF // length of next label (unsigned)

            // A length of 0 signals the end of the name
            if (len == 0) break

            // Check for a compression pointer: upper 2 bits = 11 (i.e. 0xC0 mask)
            if ((len and 0xC0) == 0xC0) {
                // The lower 6 bits of this byte + the next full byte form a 14-bit offset
                val ptr = ((len and 0x3F) shl 8) or (data[offset + 1].toInt() and 0xFF)
                // Recursively read the name at the pointer location and add it as one chunk
                parts.add(parseName(data, ptr))
                jumped = true
                break // a compression pointer always ends the name — don't keep reading
            }

            // Normal label: advance past the length byte
            offset++
            // Safety: make sure the label doesn't go past the end of the buffer
            if (offset + len > data.size) break
            // Read 'len' bytes as ASCII text and add as one label part
            parts.add(String(data, offset, len, Charsets.US_ASCII))
            // Advance past the label bytes to the next length byte
            offset += len
        }

        // Join all collected labels with "." to form the full domain name
        return parts.joinToString(".")
    }

    // skipName() advances 'offset' past a DNS name WITHOUT decoding it.
    // Used when we want to move the cursor past the NAME field of a question
    // or answer record without storing the name itself.
    // Returns the offset of the first byte AFTER the name.
    private fun skipName(data: ByteArray, startOffset: Int): Int {
        var offset = startOffset
        var safety = 0 // loop guard against malformed data

        while (offset < data.size && safety++ < 128) {
            val len = data[offset].toInt() and 0xFF

            // 0x00 = end of name; return the byte after it
            if (len == 0) return offset + 1

            // Compression pointer (2 bytes total) — name ends here
            if ((len and 0xC0) == 0xC0) return offset + 2

            // Normal label: skip the length byte + all label bytes
            offset += len + 1
        }

        return offset // return wherever we stopped (handles edge cases)
    }

    // ── Hostname → Service Label ──────────────────────────────────────────────

    // hostToLabel() maps a raw hostname like "r3.sn-p5qlsnee.googlevideo.com"
    // to a friendly name like "YouTube".
    // Uses Kotlin's 'when' expression with substring matching.
    // The order matters: more specific checks (youtube, whatsapp) come before
    // broader ones (google) so a YouTube domain is labelled "YouTube" not "Google".
    private fun hostToLabel(host: String): String = when {

        // ── Video / streaming ──────────────────────────────────────────────────
        // YouTube uses "youtube.com" for the site and "googlevideo.com" for video delivery
        host.contains("youtube") || host.contains("googlevideo") -> "YouTube"

        // Netflix CDN domains all contain "netflix"
        host.contains("netflix")                                  -> "Netflix"

        // Spotify's domains contain "spotify"
        host.contains("spotify")                                  -> "Spotify"

        // TikTok owns "tiktok.com" and uses "bytedance.com" for CDN/analytics
        host.contains("tiktok") || host.contains("bytedance")    -> "TikTok"

        // ── Messaging ─────────────────────────────────────────────────────────
        // WhatsApp servers are under "whatsapp.net" and "whatsapp.com"
        host.contains("whatsapp")                                 -> "WhatsApp"

        // Telegram uses "telegram.org" and "t.me"
        host.contains("telegram")                                 -> "Telegram"

        // Snapchat uses "snapchat.com" for API and "sc-cdn.net" for media
        host.contains("snapchat")                                 -> "Snapchat"

        // ── Social media ──────────────────────────────────────────────────────
        // Instagram is owned by Meta; CDN assets come from "fbcdn.net"
        host.contains("instagram")                                -> "Instagram"

        // Facebook also uses "fbcdn.net" for media
        host.contains("facebook") || host.contains("fbcdn")      -> "Facebook"

        // Twitter rebranded to X; "twimg.com" hosts images, "t.co" shortens links
        host.contains("twitter") || host.contains("twimg") ||
            host.contains("t.co")                                -> "X / Twitter"

        // ── Google (broad — checked AFTER youtube to avoid mis-labelling) ──────
        // googleapis.com = Google APIs, gstatic.com = static assets, ggpht.com = avatars
        host.contains("google") || host.contains("googleapis") ||
            host.contains("gstatic") || host.contains("ggpht")  -> "Google"

        // ── Apple ─────────────────────────────────────────────────────────────
        // apple.com = main domain, icloud.com = iCloud sync, mzstatic.com = App Store assets
        host.contains("apple") || host.contains("icloud") ||
            host.contains("mzstatic")                            -> "Apple"

        // ── Microsoft ─────────────────────────────────────────────────────────
        // microsoft.com, azure.com, windows.com, office365.com, outlook.com, live.com
        host.contains("microsoft") || host.contains("azure") ||
            host.contains("windows") || host.contains("office365") ||
            host.contains("outlook") || host.contains("live.com") -> "Microsoft"

        // ── Amazon / AWS ──────────────────────────────────────────────────────
        // amazonaws.com is AWS; amazon.com is the shopping site and API
        host.contains("amazonaws") || host.contains("amazon")    -> "Amazon"

        // ── CDN / infrastructure ───────────────────────────────────────────────
        // Cloudflare powers many websites' CDN and DNS (1.1.1.1)
        host.contains("cloudflare")                              -> "Cloudflare"

        // Akamai is one of the world's largest CDN providers
        host.contains("akamai") || host.contains("akadns")       -> "Akamai CDN"

        // ── Fallback ───────────────────────────────────────────────────────────
        // For anything we don't recognise, show just the base domain (last two labels).
        // e.g. "cdn.somedomain.co.uk" → "co.uk" is wrong, so we take the last 2 parts.
        // This gives "somedomain.co" which is better than showing the full CDN subdomain.
        else -> host.split(".").takeLast(2).joinToString(".")
    }
}
