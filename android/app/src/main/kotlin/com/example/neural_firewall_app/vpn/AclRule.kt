// AclRule.kt
// A minimal Access Control List (ACL) rule engine for the Neural Firewall.
//
// CONCEPT.  An ACL is an ORDERED list of rules.  Each rule is a set of MATCH
// conditions (direction, protocol, source/destination IP-CIDR, source/destination
// port range) plus an ACTION (allow / deny / warn).  For every packet we walk the
// list top-down and the FIRST rule that matches decides the outcome
// (first-match-wins).  If nothing matches, a DEFAULT POLICY applies.
//
// WHERE IT SITS.  This is the deterministic, rule-based layer that runs IN FRONT
// of the AI.  Known-bad ports / protocols / addresses are dropped here instantly
// and never reach the ML pipeline.  Anything the rules don't explicitly deny flows
// on to the AI for behavioural scoring, exactly as before.  So the two layers are
// complementary: the ACL gives hard, auditable guarantees ("port 23 is always
// blocked"); the AI catches the fuzzy patterns rules can't express.
package com.example.neural_firewall_app.vpn

// What a matching rule does with the packet.
//   ALLOW — forward it (the normal path)
//   DENY  — drop it; the packet goes nowhere (like the existing IP block)
//   WARN  — forward it but flag/log it (used for legacy/plaintext protocols)
enum class AclAction { ALLOW, DENY, WARN }

// Which traffic direction a rule applies to.  Packets read from the TUN are
// OUTBOUND (device → internet); server responses injected back are INBOUND.
enum class AclDirection { OUTBOUND, INBOUND, ANY }

// The result of an evaluation: the action plus the rule that decided it
// (null when the default policy applied), so callers can log the reason.
data class AclDecision(val action: AclAction, val rule: AclRule?)

// A single Access Control Entry (ACE).  A null match field means "any" — e.g.
// protocol = null matches every protocol.  Ports are inclusive ranges: set only
// dstPortFrom for a single port, or both dstPortFrom/dstPortTo for a range.
data class AclRule(
    val priority: Int,                            // lower number = evaluated first
    val action: AclAction,
    val direction: AclDirection = AclDirection.ANY,
    val protocol: Int? = null,                    // 6=TCP, 17=UDP, 1=ICMP, null=any
    val srcCidr: String? = null,                  // e.g. "10.0.0.0/8", null=any
    val dstCidr: String? = null,
    val dstPortFrom: Int? = null,                 // inclusive port range start, null=any
    val dstPortTo: Int? = null,                   // inclusive port range end, null=single port
    val srcPortFrom: Int? = null,
    val srcPortTo: Int? = null,
    val enabled: Boolean = true,
    val label: String = "",                       // human-readable reason, shown in logs/UI
) {
    // matches() tests this rule against one packet's 5-tuple + direction.
    // Returns true only if EVERY specified condition matches (unspecified = any).
    fun matches(
        dir: AclDirection,
        proto: Int,
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
    ): Boolean {
        if (!enabled) return false
        if (direction != AclDirection.ANY && direction != dir) return false
        if (protocol != null && protocol != proto) return false
        if (!portInRange(dstPort, dstPortFrom, dstPortTo)) return false
        if (!portInRange(srcPort, srcPortFrom, srcPortTo)) return false
        if (srcCidr != null && !AclCidr.contains(srcCidr, srcIp)) return false
        if (dstCidr != null && !AclCidr.contains(dstCidr, dstIp)) return false
        return true
    }

    // portInRange() returns true if the field is unspecified (from == null → any)
    // or the port falls within [from, to] (to defaults to from for a single port).
    private fun portInRange(port: Int, from: Int?, to: Int?): Boolean {
        if (from == null) return true
        return port in from..(to ?: from)
    }
}

// AclCidr converts dotted-quad IPv4 strings to ints and does mask comparison,
// so a rule can match a whole range like "10.0.0.0/8" — not just one exact IP.
object AclCidr {
    // contains() returns true if `ip` falls inside `cidr`.  `cidr` may be a bare
    // IP ("1.2.3.4" → exact match) or CIDR ("10.0.0.0/8").  IPv4 only; anything
    // unparseable returns false so a malformed rule simply never matches.
    fun contains(cidr: String, ip: String): Boolean {
        return try {
            val slash = cidr.indexOf('/')
            if (slash < 0) return cidr == ip                       // bare IP = exact match
            val net = ipv4ToInt(cidr.substring(0, slash)) ?: return false
            val bits = cidr.substring(slash + 1).toIntOrNull() ?: return false
            if (bits < 0 || bits > 32) return false
            if (bits == 0) return true                             // /0 matches everything
            val addr = ipv4ToInt(ip) ?: return false
            val mask = -0x1 shl (32 - bits)                        // top `bits` bits set
            (net and mask) == (addr and mask)
        } catch (_: Exception) {
            false
        }
    }

    // ipv4ToInt() packs "142.250.74.78" into a 32-bit int, or null if malformed.
    private fun ipv4ToInt(ip: String): Int? {
        val parts = ip.split(".")
        if (parts.size != 4) return null
        var result = 0
        for (p in parts) {
            val octet = p.toIntOrNull() ?: return null
            if (octet < 0 || octet > 255) return null
            result = (result shl 8) or octet
        }
        return result
    }
}

// AclEngine holds the active ruleset and evaluates packets against it.
// It is an object (process-wide singleton) so the VPN read loop and any future
// MethodChannel handler (to let Flutter push user-defined rules) share one list.
object AclEngine {

    // The active ruleset, always kept sorted by priority.  @Volatile so a
    // setRules() call from another thread is seen immediately by the read loop.
    @Volatile private var rules: List<AclRule> = defaultRules()

    // DEFAULT POLICY — the action when no rule matches.
    // We start DEFAULT-ALLOW so the device stays fully connected: only the
    // explicit DENY rules below drop traffic.  A default-DENY (whitelist model)
    // is more secure but would black-hole every app that uses an unlisted port,
    // so only switch to it once the ruleset is proven complete.
    @Volatile var defaultPolicy: AclAction = AclAction.ALLOW

    // setRules() replaces the whole ruleset (e.g. when Flutter pushes user rules).
    // Kept sorted by priority so evaluate() can rely on top-down order.
    fun setRules(newRules: List<AclRule>) {
        rules = newRules.sortedBy { it.priority }
    }

    // currentRules() exposes the active list (e.g. for a rules UI / debugging).
    fun currentRules(): List<AclRule> = rules

    // evaluate() is the hot path — called once per packet.  Walks the sorted
    // rules top-down and returns the FIRST match (first-match-wins); if none
    // match, returns the default policy with a null rule.
    fun evaluate(
        dir: AclDirection,
        proto: Int,
        srcIp: String, srcPort: Int,
        dstIp: String, dstPort: Int,
    ): AclDecision {
        for (rule in rules) {
            if (rule.matches(dir, proto, srcIp, srcPort, dstIp, dstPort)) {
                return AclDecision(rule.action, rule)
            }
        }
        return AclDecision(defaultPolicy, null)
    }

    // defaultRules() is the seed ruleset the firewall ships with.
    //
    // Philosophy for a PHONE (a client, not a server): default-allow outbound,
    // with a targeted DENY list of ports that are effectively never legitimate
    // from a mobile device and are strongly associated with malware / worms /
    // C2.  These are safe to block — normal apps (web, push, calls, email) use
    // 443/53/5228/etc., none of which appear here.  Everything not listed flows
    // through to the AI as before.
    private fun defaultRules(): List<AclRule> {
        val tcp = 6
        // Small helper for "deny outbound TCP to a single destination port".
        fun deny(port: Int, prio: Int, label: String) = AclRule(
            priority = prio, action = AclAction.DENY,
            direction = AclDirection.OUTBOUND, protocol = tcp,
            dstPortFrom = port, label = label,
        )
        return listOf(
            // ── Telnet — plaintext, obsolete; classic Mirai/IoT botnet signature ──
            deny(23, 100, "Telnet (plaintext / Mirai IoT botnet)"),
            deny(2323, 101, "Telnet alt (Mirai)"),
            // ── Windows LAN / file-sharing — worm propagation, never valid to WAN ──
            deny(445, 110, "SMB (EternalBlue / WannaCry)"),
            deny(135, 111, "MS-RPC (worm propagation)"),
            AclRule(
                priority = 112, action = AclAction.DENY,
                direction = AclDirection.OUTBOUND, protocol = tcp,
                dstPortFrom = 137, dstPortTo = 139, label = "NetBIOS",
            ),
            // ── Remote access ──
            deny(3389, 130, "RDP (BlueKeep)"),
            // ── Raw SMTP — phones use 587/465; outbound 25 = spam-bot indicator ──
            deny(25, 140, "SMTP raw (spam bot indicator)"),
            // ── Database ports — a phone hitting these directly = exfil / C2 ──
            deny(1433, 150, "MS SQL Server"),
            deny(3306, 151, "MySQL"),
            deny(5432, 152, "PostgreSQL"),
            deny(6379, 153, "Redis"),
            deny(27017, 154, "MongoDB"),
            deny(11211, 155, "memcached"),
            // ── IRC — classic botnet command-and-control channel ──
            deny(6667, 160, "IRC (botnet C2)"),
            deny(6697, 161, "IRC over TLS (botnet C2)"),
            // ── Exploit-framework / backdoor / ADB-worm default ports ──
            deny(4444, 170, "Metasploit/Meterpreter default"),
            deny(1337, 171, "Common backdoor"),
            deny(31337, 172, "Elite backdoor"),
            deny(5555, 173, "Android ADB (worm target)"),
            // ── Legacy plaintext — allowed but flagged so the user can see it ──
            AclRule(
                priority = 200, action = AclAction.WARN,
                direction = AclDirection.OUTBOUND, protocol = tcp,
                dstPortFrom = 21, label = "FTP (plaintext)",
            ),
        ).sortedBy { it.priority }
    }
}
