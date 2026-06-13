# Neural Firewall — Android VPN Engine

A deep-dive analysis of the native Android VPN layer that powers the app's
Intrusion Detection System (IDS).

**Files covered**

| File                                       | Role                                                      |
| ------------------------------------------ | --------------------------------------------------------- |
| [NeuralVpnService.kt](NeuralVpnService.kt) | The engine. Captures, inspects, and relays every packet.  |
| [PacketParser.kt](PacketParser.kt)         | Turns raw IPv4 bytes into a structured `ParsedPacket`.    |
| [FlowTracker.kt](FlowTracker.kt)           | Computes per-connection timing features for the ML model. |
| [DnsCache.kt](DnsCache.kt)                 | Maps IP addresses → hostnames → friendly service labels.  |

---

## 1. The Big Picture

This is a **userspace transparent proxy** built on top of Android's `VpnService`
API. It does **not** connect to any remote VPN server. Instead it inserts itself
between every app on the device and the real internet:

```
┌──────────┐   1. packet out   ┌──────────────────┐   3. real socket   ┌──────────┐
│  Device  │ ────────────────► │  NeuralVpnService │ ─────────────────► │ Internet │
│   apps   │                   │   (TUN proxy)     │                    │  server  │
│          │ ◄──────────────── │                   │ ◄───────────────── │          │
└──────────┘   4. injected     └──────────────────┘   3b. response      └──────────┘
                  response               │
                                         │ 2. metadata via EventChannel
                                         ▼
                                  ┌──────────────┐
                                  │  Flutter UI  │  ← the AI / IDS lives here
                                  │  + ML model  │
                                  └──────────────┘
```

The four responsibilities, in order:

1. **Capture** — create a virtual TUN interface and route _all_ device traffic
   into it (`addRoute("0.0.0.0", 0)`).
2. **Inspect** — parse each packet and push its metadata to Flutter, where the
   AI model decides whether it's malicious.
3. **Relay** — forward the packet to the genuine destination server so the user
   never loses connectivity.
4. **Inject** — write the server's reply back into TUN so the device receives it
   as if no VPN existed.

The net effect: the user keeps full internet access, but every byte is observed,
labelled, and (optionally) blockable.

---

## 2. NeuralVpnService.kt — The Engine

### 2.1 Lifecycle

```
MainActivity sends Intent
        │
        ▼
onStartCommand()  ──►  loadBlockedIps()   ← restore blocklist from disk (always-on)
        │              isRunning = true
        │              startForegroundNotification()   (Android requires this)
        │              scope.launch { startCapture() }
        ▼
startCapture()    ──►  Builder().addAddress("10.0.0.2/32")
        │                       .addRoute("0.0.0.0/0")     ← capture everything
        │                       .addDnsServer("8.8.8.8")
        │                       .setMtu(1500)
        │                       .addDisallowedApplication(self)  ← avoid loop
        │              establish()  → TUN file descriptor
        ▼
readPacketLoop()  ──►  the forever loop (see below)
        │
        ▼
onDestroy()       ──►  isRunning = false, cancel coroutines, close sockets & TUN
```

Key configuration decisions in `startCapture()`:

- **`10.0.0.2/32`** — a private point-to-point address for the TUN interface; it
  will never collide with a real internet IP.
- **`addRoute("0.0.0.0", 0)`** — the default route. This is what makes the VPN
  _transparent and total_: every destination matches, so nothing escapes capture.
- **`addDnsServer("8.8.8.8")`** — because we hijacked the route to the local
  router, the device's normal DNS (e.g. `192.168.1.1`) is unreachable. We point
  it at Google DNS, which our UDP handler can forward to.
- **`addDisallowedApplication(packageName)`** — critical. When the service opens
  a real socket to `youtube.com`, that socket's traffic must **not** re-enter
  TUN, or we'd capture our own forwarded packets in an infinite loop. This (plus
  `protect(socket)` per-socket) breaks the loop.

### 2.2 The Read Loop — `readPacketLoop()`

This is the heartbeat. One iteration = one packet:

1. **Blocking read** from the TUN file descriptor into a reusable buffer.
2. **Copy out** exactly `length` bytes into a fresh array (the shared buffer is
   about to be overwritten by the next read, so anything handed to a coroutine
   must be copied first).
3. **Parse** via `PacketParser.parse()` → `ParsedPacket` (or `null` = drop).
4. **Block check** — if **either** `parsed.srcIp` **or** `parsed.dstIp` is in the
   blocked set, `continue` (the packet is silently dropped — this is the _real_
   network-level block). Checking `dstIp` is the essential half: packets read from
   TUN are outbound, so their `srcIp` is always the device (`10.0.0.2`) and the
   flagged threat is the `dstIp`.
5. **Flow stats** — `flowTracker.update(parsed)` returns IAT mean/std/duration.
6. **Enrich & emit** — build a `Map` of all fields + ML features + DNS label and
   push it to Flutter on the **main thread** (the EventChannel is not
   thread-safe, hence `withContext(Dispatchers.Main)`).
7. **Forward** — dispatch by protocol:
   - `6` → `handleTcp()`
   - `17` → `handleUdp()`
   - ICMP (`1`) → dropped (a userspace proxy can't relay ping without raw-socket
     privileges; harmless to drop).

Each handler is launched as its **own child coroutine** so a slow network round
trip never stalls the read loop.

### 2.3 TCP Handling — `handleTcp()` (the hard part)

TCP is **stateful**: it has sequence numbers, acknowledgement numbers, control
flags, and a handshake. The service implements a miniature TCP state machine and
**spoofs the server side** locally while relaying real data through a genuine
socket.

State per connection is stored in `TcpState`, keyed by the 4-tuple
`"srcIp:srcPort->dstIp:dstPort"`:

```kotlin
data class TcpState(
    val socket: Socket,        // real connection to the internet server
    val relayJob: Job,         // coroutine: server → device
    val serverSeq: AtomicLong, // our seq number (bytes we've sent to device)
    val clientSeq: AtomicLong  // next seq we expect from the device
)
```

The handler branches on TCP flags:

#### CASE 1 — `SYN` only (new connection)

The device wants to open a connection. The service:

1. Picks a server Initial Sequence Number from `System.nanoTime()` (time-based,
   so it's not trivially predictable — a small security hardening).
2. Opens a **real** `Socket`, calls `protect(sock)` (exclude from VPN), and
   `connect()` to the true destination with a 5 s timeout.
3. Injects a **fake `SYN-ACK`** (`flags = 0x12`) back into TUN. The device's
   kernel believes the server accepted — note the **src/dst swap**: the reply
   appears to come _from_ the server.
   - `ackNum = clientIsn + 1` because a SYN consumes one sequence number.
4. Spawns the **relay coroutine**: it blocks reading from the real socket and,
   for each chunk received, builds a `PSH+ACK` data packet (`buildTcpData`),
   injects it into TUN, advances `serverSeq` by the byte count, and also emits an
   inbound event to Flutter. On EOF/error it removes state and closes the socket.

#### CASE 2 — `FIN` or `RST` (teardown)

The device is closing. The service removes the state, cancels the relay
coroutine, and closes the real socket.

#### CASE 3 — `ACK` with payload (device sending data)

This is an outbound request body (e.g. an HTTP request). The service:

1. Looks up the existing `TcpState` (drops the packet if none).
2. Extracts the application payload and `write()`s it to the real socket.
3. Advances `clientSeq` by the payload length.
4. Sends a **pure `ACK`** (`flags = 0x10`) back so the device's TCP stack slides
   its send window forward and can send more.

A pure ACK with no payload (the final leg of the handshake) is simply ignored.

> **Mental model:** the device thinks it's talking TCP to the real server. In
> reality it's talking to _this service_, which faithfully impersonates the
> server's half of the conversation while shuttling the actual bytes through a
> normal OS socket.

### 2.4 UDP Handling — `handleUdp()` (the easy part)

UDP is **connectionless** — every datagram is independent, so no state machine is
needed. For each UDP packet:

1. Slice out the payload (IP header length + fixed 8-byte UDP header).
2. Create a fresh `DatagramSocket`, `protect()` it, set a 3 s receive timeout.
3. `send()` the payload to the real destination.
4. `receive()` the response (or time out and silently drop).
5. **If destination port 53** → `dnsCache.parseAndCache()` the response (this is
   how the app learns IP→hostname mappings).
6. Build a UDP reply packet (src/dst swapped) and inject it into TUN.
7. Emit an inbound event to Flutter.

This path covers DNS, NTP, and most other UDP protocols.

### 2.5 Hand-Rolled Packet Builders

Because we inject packets directly into the kernel via TUN, the service must
**craft raw IPv4 packets byte-by-byte** and compute valid checksums itself:

| Function             | Produces                                                        |
| -------------------- | --------------------------------------------------------------- |
| `buildTcpControl()`  | 40-byte TCP packet, no payload (SYN-ACK / ACK / RST)            |
| `buildTcpData()`     | TCP packet carrying server response bytes (PSH+ACK)             |
| `buildUdpPacket()`   | Full IP+UDP packet for UDP responses                            |
| `fillIpHeader()`     | Standard 20-byte IPv4 header (version 4, IHL 5, TTL 64, DF set) |
| `patchIpChecksum()`  | RFC 791 one's-complement checksum over the IP header            |
| `patchTcpChecksum()` | TCP checksum over the **pseudo-header** + segment               |
| `internetChecksum()` | The shared one's-complement checksum algorithm                  |
| `readU32()`          | Big-endian unsigned 32-bit read (for sequence numbers)          |

Two details worth calling out:

- **TCP pseudo-header** — the TCP checksum deliberately includes the source IP,
  destination IP, protocol, and TCP length. This binds the segment to its
  addresses (anti-spoofing) and is why `patchTcpChecksum()` reconstructs that
  prefix before summing.
- **`writeSynced()`** — an extension on `FileOutputStream` that wraps
  `write()+flush()` in `synchronized(this)`. Multiple coroutines (the relay jobs,
  the UDP handlers) all write to the _same_ TUN fd; without this lock, interleaved
  writes would produce corrupted, unparseable packets.

### 2.6 Concurrency & Safety Model

- **`CoroutineScope(Dispatchers.IO + SupervisorJob())`** — blocking I/O runs on
  the IO thread pool; `SupervisorJob` means one crashed handler doesn't kill the
  others.
- **`@Volatile isRunning`** — written by `onDestroy()`, read by every loop;
  volatile guarantees the change is seen immediately across threads.
- **`ConcurrentHashMap` everywhere** — `tcpConnections` and `blockedIps` are
  touched by both the read loop and the MethodChannel thread.
- **`AtomicLong`** sequence counters — mutated from both `handleTcp()` and the
  relay coroutine.
- **`onDestroy()` cleanup** — flips `isRunning`, clears blocks, cancels the
  scope, closes every socket, closes the TUN fd (which unblocks the read), and
  resets the flow tracker. No fd or memory leaks across sessions.

### 2.7 The Blocking Mechanism (the whole point of the app)

This is what makes the app a _firewall_ and not just a traffic viewer. Blocking
has to actually sever communication with a flagged threat — both new and
already-open connections — so it is enforced in **three** complementary places.

The companion object exposes `blockIp()` / `unblockIp()` / `isIpBlocked()` /
`clearBlockedIps()` over a thread-safe set. When Flutter's AI model flags an IP it
calls `blockIp(ip)` through the MethodChannel, which does two things:

1. Adds the IP to the `blockedIps` set.
2. Calls `tearDownConnectionsTo(ip)` on the live service instance (reached via a
   `@Volatile instance` reference set in `onStartCommand`).

The three enforcement points:

| # | Where | Stops |
| - | ----- | ----- |
| 1 | Read loop: `if (isIpBlocked(srcIp) \|\| isIpBlocked(dstIp)) continue` | **Future outbound** packets to/from the IP — they're never forwarded. |
| 2 | `tearDownConnectionsTo(ip)` (called by `blockIp`) | **Existing TCP** connections — cancels their relay coroutine and closes the real socket immediately. |
| 3 | Relay coroutine guard: `if (isIpBlocked(parsed.dstIp)) break` | **In-flight server data** — a belt-and-suspenders check so not one more attacker packet is injected even during a race. |

Why all three are needed:

- Point 1 alone is **insufficient**: a TCP connection that is already open has its
  own relay coroutine pumping server→device data independently of the read loop, so
  blocking only future packets would let an in-progress attack run to completion.
- `tearDownConnectionsTo()` parses the destination IP out of each connection key
  (`"srcIp:srcPort->dstIp:dstPort"`) and kills every connection whose remote end is
  the blocked IP.
- The key correctness fix over the naive version: the check **must include
  `dstIp`**. Packets read from TUN are outbound, so their `srcIp` is always the
  device's own `10.0.0.2`; the threat is the destination. A `srcIp`-only check
  would never match an outbound packet and the block would silently do nothing.

**These are the enforcement points** — everything else in the service is
observation.

#### Persistence — why the blocklist survives a kill

The block set is not just in RAM; it is **persisted to `SharedPreferences`** so the
firewall behaves as a true _always-on_ guard:

- `blockIp()` and `unblockIp()` write the updated set to disk (`persistBlockedIps()`,
  stored under key `blocked_ips` in the `neural_fw_prefs` file).
- `onStartCommand()` calls `loadBlockedIps()` **before** capture starts, repopulating
  the set from disk.

This closes a real gap. If Android kills the process under memory pressure,
`START_STICKY` restarts the service with a **null Intent and no Flutter connection** —
so without persistence the restarted service would come back with an _empty_ blocklist
and silently forward traffic to known threats until the UI reconnected. With it, blocks
are enforced from the very first packet after restart.

Lifecycle subtlety: `onDestroy()` (the clean stop, e.g. user toggles the VPN off) calls
`clearBlockedIps()`, which frees **only the in-memory set** — it deliberately leaves the
persisted copy intact. So a known-malicious IP never becomes allowed again just because
the VPN was toggled off and on; the disk copy is reloaded on the next start. To actually
forget a threat you must `unblockIp()` it (which also updates disk).

```
blockIp(ip)   ─►  set.add(ip)  ─►  persistBlockedIps()  ─►  disk
                                                              │
OS kills process ─► START_STICKY restart (null Intent) ◄──────┘
        │
        ▼
onStartCommand() ─► loadBlockedIps()  ─►  set repopulated  ─►  blocks live again
```

---

## 3. PacketParser.kt — Bytes → Structure

A stateless Kotlin `object` (singleton) with one job: parse one raw IPv4 packet.

`ParsedPacket` carries: `id, srcIp, srcPort, dstIp, dstPort, protocol, sizeBytes,
flags, timestamp`.

Parsing walk-through:

1. **Reject** anything `< 20` bytes (minimum IPv4 header).
2. **Byte 0** → version (upper nibble) + IHL (lower nibble × 4 = header length in
   bytes). Validate IHL ≥ 20 and packet ≥ header.
3. Read past DSCP, total length (→ `sizeBytes`), identification, flags/offset, TTL.
4. **Byte 9 = protocol** (1/6/17).
5. Read past header checksum (trusted — the kernel already verified it).
6. **Bytes 12–19** → source & destination IPs, formatted dotted-decimal.
7. **Transport layer:**
   - **TCP (6):** read src/dst ports, skip seq/ack, then read byte 13 → the
     flags byte (`SYN/ACK/FIN/RST/PSH`).
   - **UDP (17):** read src/dst ports; length & checksum ignored.
   - **ICMP (1):** ports/flags stay 0.
8. Return a `ParsedPacket`, or `null` if a `BufferUnderflowException` (truncated
   packet) or any malformation is hit — the caller silently drops `null`.

The whole thing is wrapped in `try/catch` returning `null`, so a malformed packet
can never crash the read loop.

---

## 4. FlowTracker.kt — Timing Features for the ML Model

A "flow" = one conversation identified by the 4-tuple `srcIp:srcPort-dstIp:dstPort`.
For each flow it records packet arrival timestamps and derives two features the AI
uses to spot anomalies:

- **IAT Mean** — average inter-arrival time (ms) between consecutive packets.
- **IAT Std** — standard deviation of those gaps.
- **Duration** — age of the flow.

> Why these matter: a brute-force / flood attack fires packets in a rapid, regular
> burst → **low IAT mean, low IAT std**. Human-driven web traffic is bursty and
> irregular → higher, more variable IAT. The model uses this signature.

`update(packet)` per call:

1. Build the flow key; `getOrPut()` the `Flow`.
2. Append `packet.timestamp` to its history.
3. **Sliding window** — cap history at 100 timestamps (drop oldest). 100 packets
   give 99 IAT samples, plenty for stable stats, with bounded memory.
4. **Eviction** — if more than `maxFlows` (10 000) flows exist, drop any flow with
   no activity in 5 minutes. This is the defense against a flood inflating the map
   until OOM.
5. `computeStats()` — handle the 0-packet and 1-packet edge cases (IAT needs ≥ 2
   points), build the IAT list, compute mean, then variance → std dev.

`reset()` clears everything on `onDestroy()`.

---

## 5. DnsCache.kt — IP → Hostname → Friendly Label

This is what lets the UI display **"YouTube"** instead of `142.250.74.78`.

### How it learns mappings

When `handleUdp()` sees a response on port 53, it calls
`parseAndCache(dnsPayload)`. The cache parses the raw DNS message:

1. Validate ≥ 12 bytes (DNS header) and check the **QR bit** (must be a
   _response_, bit 15 of the flags) — queries carry no answers.
2. Read `QDCOUNT` (questions) and `ANCOUNT` (answers); bail if no answers.
3. Read the **queried hostname** from the first question via `parseName()`.
4. Skip past all questions (`skipName() + 4` for QTYPE/QCLASS each).
5. Walk each answer record; for every **A record** (`type == 1`, `rdlength == 4`),
   format the 4 RDATA bytes as an IPv4 string and store `cache[ip] = hostname`.

`parseName()` / `skipName()` correctly handle **DNS compression pointers**
(the `0xC0` two-byte back-references), with a 128-iteration `safety` guard against
malformed or circular pointers that would otherwise infinite-loop. The whole
parser is wrapped in `try/catch` — a malformed DNS packet just means a missing
label, never a crash.

### How it labels

- `serviceLabel(ip)` → looks up the hostname, then `hostToLabel()`.
- `hostToLabel()` is a substring-matching `when` covering major services:
  YouTube, Netflix, Spotify, TikTok, WhatsApp, Telegram, Snapchat, Instagram,
  Facebook, X/Twitter, Google, Apple, Microsoft, Amazon, Cloudflare, Akamai.
- **Ordering matters** — specific checks (`youtube`/`googlevideo`) precede broad
  ones (`google`), otherwise a YouTube CDN domain would be mislabelled "Google".
- **Fallback** — unknown hosts return the last two labels of the domain.

`ConcurrentHashMap` backs the cache because the read loop and DNS parsing touch it
from different coroutines.

---

## 6. End-to-End Example: Opening youtube.com

```
1. App resolves "youtube.com"
   → DNS query (UDP :53) hits TUN
   → handleUdp() forwards to 8.8.8.8, gets response
   → dnsCache caches 142.250.x.x → "youtube.com"
   → response injected back; app now has the IP

2. App opens TCP to 142.250.x.x:443
   → SYN hits TUN
   → handleTcp() CASE 1: opens real socket, sends fake SYN-ACK
   → app completes handshake (thinks it reached the server)

3. App sends TLS ClientHello (ACK + payload)
   → handleTcp() CASE 3: writes payload to real socket, ACKs the app

4. Server replies
   → relay coroutine reads socket, injects PSH+ACK packets into TUN
   → app receives them; meanwhile each packet:
       • is parsed
       • gets flow IAT stats
       • is labelled "YouTube" via dnsCache
       • is pushed to Flutter where the AI model scores it

5. If the model flags the IP → blockIp(142.250.x.x)
   → blockIp() adds it to the set AND calls tearDownConnectionsTo():
       • the live TCP relay for 142.250.x.x is cancelled, its socket closed
       • the app's connection dies instantly (server data stops flowing)
   → every future outbound packet whose dstIp == 142.250.x.x hits the
     `continue` in the read loop and is dropped before forwarding
   → result: the app can no longer talk to YouTube at all
```

---

## 7. Design Trade-offs & Limitations (worth knowing)

- **IPv4 only.** All parsing/building assumes 20-byte IPv4 headers; IPv6 packets
  (version 6) are not handled.
- **No TCP retransmission/windowing logic.** Sequence numbers are tracked, but
  there's no congestion control, selective ACK, or out-of-order reassembly — it
  relies on the OS socket and the device's stack to be forgiving. Fine for a
  monitoring/IDS proxy, not a production-grade NAT.
- **ICMP dropped.** Ping/traceroute through the tunnel won't work (needs raw
  sockets). No impact on normal browsing.
- **UDP is one-shot.** Each datagram opens a fresh socket and waits ≤ 3 s for a
  single reply. Multi-response UDP flows (e.g. some QUIC/WebRTC patterns) aren't
  fully modelled — though DNS, the primary need, works perfectly.
- **UDP checksum set to 0.** Legal for IPv4, so this is fine.
- **Inbound events use placeholder flow stats** (`flowIatMean = 0.0` etc.) — the
  full ML features are computed only on the outbound path.

---

## 8. Hardware Metrics — Native Device Sampling

> **Scope note:** this logic does **not** live in the `vpn/` package. It sits in
> [MainActivity.kt](../MainActivity.kt) alongside the VPN MethodChannel, and is
> documented here because it's the other half of the app's native↔Flutter bridge.

A second MethodChannel, **`com.sentri.app/hardware`**, lets the Flutter
`HardwareMetricsCubit` pull a point-in-time device health snapshot. Flutter polls
it on a **2-minute timer** and POSTs the result to the backend so each user's
device behaviour can be monitored over time.

### 8.1 The Channel

```
Flutter HardwareMetricsCubit (every 2 min)
        │  invokeMethod("getHardwareSnapshot")
        ▼
MainActivity  ──►  hardwareExecutor.execute { ... }   ← single background thread
        │              collectHardwareSnapshot()
        │              runOnUiThread { result.success(map) }   ← reply on main thread
        ▼
Map { cpuUsage, ramUsedMb, ramTotalMb, batteryLevel }
```

The handler accepts a single method, `getHardwareSnapshot`; anything else returns
`notImplemented()`.

**Why a background thread:** sampling does blocking work — `/proc` file reads plus
a deliberate 400 ms CPU sampling sleep. Running that on the platform/main thread
would risk an ANR, so it's dispatched to a single-thread `Executor` and the result
is marshalled back via `runOnUiThread` (MethodChannel replies must come from the
main thread).

### 8.2 The Four Fields

The returned `Map` keys match exactly what `HardwareLocalDataSource` reads on the
Dart side:

| Key            | Type      | Source                                                        |
| -------------- | --------- | ------------------------------------------------------------- |
| `cpuUsage`     | `Double`  | App process CPU %, sampled from `/proc/self/stat` (see below) |
| `ramUsedMb`    | `Int`     | `ActivityManager.MemoryInfo`: `(totalMem − availMem) / 1 MB`  |
| `ramTotalMb`   | `Int`     | `ActivityManager.MemoryInfo`: `totalMem / 1 MB`               |
| `batteryLevel` | `Double?` | `BatteryManager.BATTERY_PROPERTY_CAPACITY` (null if unknown)  |

Each field is computed inside its own `try/catch`, so a single failure degrades
to a default (0, or `null` for battery) instead of taking down the whole snapshot.

### 8.3 CPU Usage — `collectHardwareSnapshot()` + `readProcessCpuJiffies()`

Device-wide `/proc/stat` has been **unreadable to apps since Android 8**, so we
measure **this app's own process CPU** instead — which is the more meaningful
signal for "how is the app behaving on this device" anyway.

The measurement is a short delta sample:

1. Read `utime + stime` (in clock ticks / "jiffies") from `/proc/self/stat`.
2. Record `SystemClock.elapsedRealtime()`.
3. `Thread.sleep(400)`.
4. Read both again.
5. Convert: `cpu% = (Δjiffies / 100) / (Δseconds × cores) × 100`, clamped to
   `0..100`.
   - `100` = `_SC_CLK_TCK`, the standard clock-tick rate on Android.
   - dividing by `cores` (`Runtime.availableProcessors()`, floored at 1)
     expresses usage as a fraction of **total device CPU capacity**, not of a
     single core — so a value of `100` means every core is saturated.

**Parsing `/proc/self/stat` safely:** the 2nd field (`comm`, the process name)
can itself contain spaces or parentheses, which would break a naive
space-split. `readProcessCpuJiffies()` therefore slices the string **after the
last `)`** and splits the remainder; in that remainder field 3 (`state`) is at
index 0, which puts `utime` (field 14) at index 11 and `stime` (field 15) at
index 12. Any failure returns `-1L`, which the caller treats as "no sample" and
reports `cpuUsage = 0.0`.

---

## 9. One-Line Summary per File

- **NeuralVpnService.kt** — a userspace TUN proxy that captures all traffic,
  spoofs the server side of TCP locally, relays real bytes through protected
  sockets, injects responses back, streams metadata to the Flutter IDS, and
  enforces IP blocks.
- **PacketParser.kt** — a safe, stateless IPv4 byte-decoder that yields a
  structured `ParsedPacket` or `null`.
- **FlowTracker.kt** — computes inter-arrival-time statistics per connection so
  the AI can recognise the timing signature of attacks.
- **DnsCache.kt** — sniffs DNS responses to map IPs to hostnames and turn them
  into human-friendly service labels for the UI.
