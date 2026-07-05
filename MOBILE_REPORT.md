# Mobile Application — Final Year Project Report Content

> Content for the **Mobile Application** part of the _Sentri Neural Firewall_ FYP report.
> Written to mirror the structure and academic tone of the Backend chapter (numbered
> sections, each chapter with an Introduction and a Conclusion, supporting tables).
> Two chapters are provided because the mobile deliverable has two clearly distinct
> halves: (1) the Flutter application and its architecture, and (2) the on-device
> packet-interception and real-time detection engine that makes Sentri a _firewall_
> rather than a dashboard.

---

# Chapter — Mobile Application Implementation

## 1. Introduction

This chapter presents the mobile application implementation of the Sentri Neural Firewall system. Unlike a conventional security app that merely visualises data produced elsewhere, the Sentri mobile application is itself the firewall: it captures and inspects every network packet leaving and entering the device, scores that traffic with on-device machine-learning models, enforces blocking decisions at the network level, and only then streams the results to the backend for long-term storage and cross-device synchronisation.

The application was developed using **Flutter** (Dart) targeting Android, and combines a pure-Dart application layer with a native **Android VPN Service** written in **Kotlin**. This hybrid design is deliberate: Flutter provides a fast, expressive, single-codebase user interface and business-logic layer, while the native layer provides the low-level networking capabilities (a virtual TUN interface, raw packet parsing, and per-connection relaying) that are only reachable through the Android platform APIs.

Because the application runs continuously as an always-on firewall, it was engineered around several demanding requirements: it must survive process death and restarts, must never lose internet connectivity for the user, must keep battery and CPU consumption acceptable, must keep sensitive credentials secure, and must remain responsive while inference runs on a live packet stream. These requirements shaped every architectural decision described in this chapter.

This chapter covers the application architecture (Clean Architecture with the BLoC pattern), the technology stack, the feature modules, the centralised design system, state management, authentication and secure networking, offline-first persistence, and the real-time communication layer that connects the application to the backend.

## 2. Application Overview

The Sentri mobile application acts as the user-facing entry point and the on-device enforcement point of the whole system. It is responsible for authenticating the user, requesting the Android VPN permission, capturing live network traffic, extracting statistical flow features from that traffic, running five specialised threat-detection models entirely on the device, deciding whether each flow should be allowed, warned, or blocked, and persisting the resulting security events both locally and to the backend.

The application is organised around **feature modules** (authentication, traffic/detection, VPN control, firewall logs, blacklist, access control, hardware metrics, settings, dashboard, analytics, and the Nova AI assistant). Each module is self-contained and follows the same three-layer Clean Architecture pattern, which keeps the codebase modular, testable, and maintainable — the mobile equivalent of the backend's Flask Blueprint organisation.

At runtime the application exposes four primary tabs through a custom floating navigation bar — **Home** (live traffic), **Portal/Dashboard** (overview), **Blacklist**, and **Settings** — plus a floating action button that opens the **Nova** conversational security assistant. Behind these screens, a set of BLoC/Cubit controllers coordinate the live packet stream, the machine-learning verdicts, the local caches, and the network synchronisation.

Overall, the mobile application provides a complete, self-sufficient intrusion-detection and prevention client that continues to protect the device even when it is offline, and enriches that protection with centralised threat intelligence when a connection to the backend is available.

## 3. Technology Stack

The mobile implementation relies on a curated set of packages, each chosen for its role in a scalable, maintainable, production-grade Flutter application. The framework itself is Flutter on Dart SDK `^3.11.0`; the application identifier is `Sentri`, version `1.0.0+1`.

| Category                | Technology / Package                                                          | Purpose                                                                 |
| ----------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Framework               | Flutter (Dart)                                                                | Cross-platform UI and application logic                                 |
| Native bridge           | Kotlin Android VPN Service                                                    | TUN interface, packet capture, network-level enforcement                |
| State management        | `flutter_bloc`, `bloc`, `equatable`                                           | BLoC/Cubit state management with value equality                         |
| Dependency injection    | `get_it`, `injectable`                                                        | Service locator and DI code generation                                  |
| HTTP client             | `dio`                                                                         | REST communication with the backend                                     |
| Real-time               | `web_socket_channel`                                                          | Streaming firewall logs to the backend (write path)                     |
| On-device ML            | `tflite_flutter`                                                              | Running the TensorFlow Lite detection models                            |
| Secure storage          | `flutter_secure_storage`                                                      | Encrypted storage of JWT tokens (Keychain / EncryptedSharedPreferences) |
| Local persistence       | `shared_preferences`                                                          | Local caches (logs, blacklist, settings)                                |
| Foreground service      | `flutter_foreground_task`                                                     | Keeping the firewall alive in the background                            |
| Permissions             | `permission_handler`                                                          | Runtime permission requests                                             |
| Responsive UI           | `flutter_screenutil`                                                          | Density-independent sizing against a 375×812 design canvas              |
| Charts                  | `fl_chart`                                                                    | Threat-trend sparkline visualisation                                    |
| UI polish               | `flutter_animate`, `shimmer`, `badges`, `percent_indicator`, `auto_size_text` | Animations, loading placeholders, nav badges, gauges                    |
| Typography              | `google_fonts`, bundled _Figtree_ font                                        | Application typography                                                  |
| Serialization / codegen | `freezed`, `json_serializable`, `build_runner`                                | Immutable models and JSON handling                                      |
| Formatting              | `intl`, `collection`                                                          | Date/number formatting and collection helpers                           |
| Logging                 | `logger`                                                                      | Structured diagnostic logging                                           |
| Branding                | `flutter_launcher_icons`, `flutter_native_splash`                             | Launcher icon and native splash screen                                  |

Flutter was selected for its single-codebase productivity, its rich widget system, and its native-interoperability through platform channels — which is essential for a project that must reach down to the Android VPN APIs. TensorFlow Lite (`tflite_flutter`) allows the trained detection models to run **entirely on the device**, so traffic is classified without ever leaving the phone, preserving user privacy and eliminating network round-trips from the detection hot path. The BLoC pattern was chosen to keep UI, business logic, and data strictly separated, which is critical in an application whose logic is driven by a continuous, high-rate event stream.

## 4. Application Architecture

The application is built on **Clean Architecture**, the same principle of layered separation used on the backend. Every feature is divided into three layers with dependencies pointing strictly inward (presentation → domain → data), so that the core business rules never depend on frameworks or I/O details.

- **Domain layer** — pure Dart with no Flutter or Dio imports. It contains the _entities_ (plain data objects such as `PacketRecord`, `FirewallLog`, `BlacklistEntry`, `HardwareSnapshot`, `User`), the abstract _repository contracts_, and the _use cases_. Each use case is a single-purpose class exposing one `call()` method (the command pattern), e.g. `ProcessPacketUseCase`, `SignInUseCase`, `AddToBlacklistUseCase`, `CollectSnapshotUseCase`. This layer defines _what_ the application does, independent of _how_.
- **Data layer** — the _implementations_ of the repository contracts, plus the _data sources_ (remote HTTP data sources, native method-channel data sources, and local persistence data sources) and the _models_ that serialise to and from JSON. The data layer is where the domain contracts meet the outside world (backend, native VPN service, secure storage, shared preferences).
- **Presentation layer** — the _BLoC/Cubit_ controllers that hold UI state, plus the _screens_ and _widgets_. This layer reacts to user input and to domain events, and never talks to data sources directly — always through use cases.

This structure directly mirrors the backend's modular Blueprint design: each mobile feature module (`auth`, `traffic`, `vpn`, `firewall_logs`, `blacklist`, `hardware_metrics`, `settings`, `dashboard`, `analytics`, `chatbot`) is an isolated vertical slice, which improves organisation, testability, and parallel development.

Dependency injection is handled by `get_it` and `injectable`: the entire dependency graph — secure storage, the shared Dio client, interceptors, repositories, use cases, and BLoCs — is registered through code-generated annotations, with a single `@module` supplying the third-party and asynchronously-initialised objects (the two Dio clients, `SharedPreferences`, `FlutterSecureStorage`, and the TensorFlow Lite models). A single call to `configureDependencies()` at startup builds the container; it is awaited because a handful of dependencies resolve asynchronously (`@preResolve`) — most notably the ML models, which finish loading before the first screen is built. A single shared Dio client and a single shared secure-storage session object are registered as singletons and reused across all authenticated features, so a refreshed token propagates everywhere at once.

A deliberate design choice removes what would otherwise be a circular dependency in this graph. The token-refresh interceptor must force a sign-out when a session expires, yet it is constructed before — and independently of — the `AuthCubit` it would need to call. Rather than wiring the two together by hand, the interceptor publishes a "session-expired" event on a lightweight `SessionEventBus` the moment it discards a dead refresh token; the `AuthCubit` subscribes to that bus directly and drops the UI back to the sign-in gate, while the `AppBootstrap` orchestrator reacts to the same event to tear down the authenticated firewall-log WebSocket. Because no component holds a direct reference to another, registration order is irrelevant and the container wires itself. The small amount of runtime orchestration a service locator cannot express — cross-BLoC stream wiring, seeding the live detection pipeline from the persisted settings, and resuming the sticky VPN session after a restart — is centralised in a single `AppBootstrap` object, invoked once immediately after the container is built and before the UI is shown.

## 5. State Management (BLoC / Cubit)

State across the application is managed with the **BLoC** pattern from the `flutter_bloc` package, using the lighter **Cubit** variant for most features and the full event-driven **Bloc** for the high-rate traffic pipeline.

- **`TrafficBloc`** is the only true event-driven Bloc. It consumes a continuous stream of raw packets and processes events such as `StartListeningEvent`, `PacketReceivedEvent`, `ClearLogsEvent`, and `LoadPersistedLogsEvent`. Its state carries a bounded queue of the most recent packet records (capped at 200) and a 60-point threat sparkline. It debounces local persistence so that, under heavy traffic, disk writes are coalesced into a single save every two seconds instead of one write per packet.
- **`AuthCubit`** holds an immutable `AuthState` with a status enum (`initial`, `loading`, `authenticated`, `unauthenticated`, `error`) plus user fields, and drives the top-level navigation gate.
- **`VpnCubit`** exposes `start()`, `stop()`, and `restore()` methods and mirrors the native service status (`stopped`, `starting`, `running`, `error`).
- **`DashboardCubit`** is an _aggregator_ that subscribes to the streams of `TrafficBloc` and `BlacklistCubit` and recomputes overview statistics (packets analysed, blocked/warned/safe counts, peak threat percentage, blacklisted-IP count) without any data source of its own — a clean example of cross-BLoC composition.
- **`BlacklistCubit`**, **`FirewallLogsCubit`**, **`HardwareMetricsCubit`**, **`SettingsCubit`**, and **`ChatCubit`** each manage their respective feature.

`equatable` is used throughout so that identical states do not trigger unnecessary rebuilds, which matters for a UI that is refreshed from a high-rate event stream.

## 6. Feature Modules

The application is composed of independent feature modules. The most important are summarised below.

### 6.1 Authentication

Handles registration, login, session restoration, profile editing, and logout. Credentials are exchanged with the backend's `/auth/*` endpoints and the returned **access** and **refresh** JWT tokens, together with the cached user profile, are stored in **encrypted, platform-backed secure storage** (Android EncryptedSharedPreferences / iOS Keychain). A session is considered active whenever an access token is present. The module is described in detail in Section 8.

### 6.2 Traffic and Detection

The core module. It receives the native packet stream, runs the on-device ML models, classifies each flow as _safe_, _warn_, _AI block_, or a special protocol category, auto-blocks malicious sources, and renders the live traffic table, statistics, and threat sparkline on the Home screen. Its internals are the subject of the next chapter.

### 6.3 VPN Control

A thin Dart bridge over the native Android VPN service. Through a **MethodChannel** (`com.neuralfw/vpn`) it can start/stop the VPN, query whether it is running, check and request the VPN permission, and push IP block/unblock commands down to the native enforcement layer. Through an **EventChannel** (`com.neuralfw/packets`) it receives the live stream of captured packets. Because the native service is a _sticky_, foreground service, the `VpnCubit.restore()` method re-synchronises the UI with an already-running session after an app restart and resumes packet listening automatically.

### 6.4 Firewall Logs

A paginated, filterable, server-backed history of firewall verdicts. It calls `GET /firewall-logs` with `limit`/`offset` pagination and optional filters (action, threat type, service name, application name, date range), and supports infinite scroll and pull-to-refresh. Each `FirewallLog` entity captures the source IP/port, destination port, protocol, size, the selected model and its score, the full per-model score map, the final action, the threat type, the resolved service and application names, and whether the traffic belonged to a system app.

### 6.5 Blacklist and Access Control

A **local-first** list of blocked IP addresses — added either manually by the user or automatically by the detection pipeline. Auto-blocks raised by the ML pipeline are enforced immediately at the network level (a `blockIp` command to the VPN service) and appear in the list in real time via a broadcast change stream; removing any entry lifts the native block (`unblockIp`) so connectivity is restored. Manual additions are written to the local cache first, then mirrored best-effort to the backend `/blacklist` endpoints, so the list follows the user across devices without ever depending on connectivity. The navigation bar shows a live blocked-count badge.

### 6.6 Hardware Metrics

Collects on-device telemetry (CPU usage, RAM used/total, battery level) through a dedicated native method channel (`com.sentri.app/hardware`), displays it on the dashboard with threshold-coloured gauges, and syncs a snapshot to the backend every two minutes. This lets the project demonstrate that continuous packet capture and on-device inference remain within an acceptable performance budget.

### 6.7 Settings

Central control over detection thresholds (block/warn), per-model AI protection toggles, flood and SYN-flood detection, maximum log entries, system-traffic scanning, and theme. Settings are **local-first with debounced two-way synchronisation**: local changes are persisted immediately and coalesced into a single backend `PUT` after 700 ms, while server changes are overlaid on top. Crucially, changes to thresholds, the enabled-model set, and system-traffic scanning are pushed straight into the _live_ detection pipeline, so tuning takes effect without a restart.

### 6.8 Dashboard and Analytics

The Dashboard aggregates live session statistics, the protection-posture hero, hardware stats, recent blocked IPs, and active-model chips. The Analytics screen adds deeper views: a verdict breakdown, threat-vector intensities (average and peak brute-force and DoS scores), the top source IPs, and the protocol mix.

### 6.9 Nova AI Assistant

A streaming conversational security assistant that answers natural-language questions ("Who is attacking me?", "Top threats today", "Is my device safe?") about the user's own traffic. The empty state is seeded with tappable **suggestion chips** carrying those example prompts, so the user can start a conversation with a single tap.

Nova is deliberately **stateless**: there is no conversation history, no saved sessions, and no auto-generated digest — each question is answered on its own, and the conversation lives only in memory for the lifetime of the screen (a "new chat" action simply clears it). This keeps both the client and the backend contract minimal: the domain layer is reduced to a single `ChatMessage` entity (role, content, streaming flag), one repository method (`sendMessage`), and one `SendMessageUseCase`, all exposing a plain `Stream<String>` of reply tokens rather than any persisted model.

Responses are streamed **token-by-token** over **Server-Sent Events** from a single JWT-protected endpoint, `GET /api/mobile_chat?prompt=<text>`. The reply arrives as an `init` → `message`\* → `end` event sequence: `init` is a handshake, each `message` event carries one token of the answer, and `end` closes the stream. The `ChatbotRemoteDataSource` consumes the raw byte stream through Dio's `ResponseType.stream`, decodes it with a UTF-8 decoder (so multi-byte characters split across network chunks are stitched back together), and hand-parses the SSE framing — buffering by line, dispatching on blank lines, and honouring `event:`/`data:` fields as well as `:` keep-alive comments. Token extraction is tolerant: a `data:` payload may be a JSON object (`{"content": …}`, plus several aliased field names), a bare JSON string, or raw text. The `ChatCubit` appends each incoming token to the trailing assistant message and re-emits, so the UI renders the answer as it arrives, complete with a live blinking cursor and an animated "thinking" dots indicator while the reply is in flight. Error handling is thorough for a streamed endpoint: because Dio leaves a failed stream's body undrained, the data source explicitly reads the error body to recover the backend's real message, and maps status codes (401 → session expired, 400 → empty prompt, 500 → surfaced server message, timeouts/connection errors → a retry prompt) to user-facing text.

## 7. User Interface and Design System

The application deliberately avoids scattering raw visual values (colours, spacing, radii, typography) throughout the widget tree. Instead, every visual token is centralised in a set of static **resource-manager** classes, each with a private constructor to enforce static-only use:

- **`ColorManager`** and the theme-aware **`AppThemeColors`** theme extension — the single source of truth for every colour, including brand, semantic, status, dark/light surface, and protocol palettes. Widgets read theme-aware colours through a `context.appColors` extension.
- **`PaddingManager`** and **`SpacesManager`** — all padding and all inter-widget gaps. Following a strict project rule, **no spacing is ever hardcoded**: every inset is a named `EdgeInsets` token and every gap is a pre-built `SizedBox`, and both embed responsive scaling so callers never repeat sizing suffixes. The token set includes a Figma-derived 8-point grid (`spacing200`…`spacing6400`) mirroring the design file.
- **`BorderRadiusManager`**, the font managers (**`FontFamilyManager`** / **`FontWeightManager`** / **`FontSizesManager`**), the top-level text-style helpers in `text_style_manager.dart`, and **`DecorationManager`** — centralise radii, typography (the bundled _Figtree_ family), and every `BoxDecoration`, gradient, shadow, and input decoration, including theme-dependent factories.

The application is fully **responsive** through `flutter_screenutil`, configured against a 375×812 reference design canvas so that layouts scale consistently across device sizes. It ships **light and dark themes** built on Material 3, switched live from the Settings cubit. Reusable widgets include a context-free global **toast service** (queued, one-at-a-time overlay toasts callable from anywhere, even outside the widget tree), an `AppPressable` tap wrapper that adds an iOS-style press-shrink and haptic feedback, and a standard `AppPrimaryButton`. Navigation is provided by a custom floating pill navigation bar with a live blocked-count badge and a separate animated Nova FAB.

## 8. Authentication and Secure Networking

Authentication and secure transport are as central to the mobile client as they are to the backend, because the device transmits credentials, JWT tokens, firewall logs, and hardware metrics.

**Session lifecycle.** On registration or login, the backend returns an access token, a refresh token, and the user profile; all three are written to encrypted secure storage by a shared `AuthLocalDataSource`. On startup the application validates the session by calling `GET /auth/me`; if the network is unavailable but the refresh token is still valid, it falls back to the cached user profile, so a transient outage never forces a sign-out. Logout makes a best-effort call to `/auth/logout` to revoke the refresh token server-side, then always clears local storage.

**Transparent token refresh.** The centrepiece of the networking layer is a custom Dio **`RefreshTokenInterceptor`**. When any authenticated request returns `401 Unauthorized`, the interceptor mints a fresh access token from the stored refresh token, replays the original request with it, and resolves the call as though the expiry never happened — so every endpoint gets transparent refresh for free. It is hardened with production-grade safeguards: a dedicated interceptor-free client performs the refresh (preventing recursion); a single in-flight refresh future coalesces concurrent 401s into one refresh; a per-request "retried" flag prevents infinite loops; refresh-token rotation is supported; and, critically, the session is only wiped on a _genuine_ auth rejection (401/403/422) of the refresh — transient network failures leave the session intact. When a refresh is genuinely rejected, the interceptor clears the stored tokens and announces the dead session on an application-wide event bus, which the `AuthCubit` observes to return the user to the sign-in gate, and which the app's bootstrap step uses to close the firewall-log WebSocket.

**HTTP client.** A single shared `DioConsumer` wraps Dio with configured timeouts (connect 60 s, receive 180 s, send 30 s), attaches `Authorization: Bearer` headers only when a token is supplied, and chains the refresh, error, and (debug-only) logging interceptors.

**Error handling.** Rather than functional `Either`/`Failure` return values, the application models failures as a **Freezed sealed union**, `NetworkExceptions`, thrown as exceptions and caught at the Cubit boundary where they are mapped to user-facing messages. The union covers the full range of transport and HTTP-status conditions (timeouts, no-connection, unauthorised, not-found, server errors, and so on), giving consistent, type-safe error handling throughout.

All communication with the deployed backend (`https://api.sentri-security.cloud/`) is over HTTPS; a self-signed-certificate bypass exists only under `kDebugMode` for local development, so production always enforces TLS validation.

## 9. Real-Time Communication and Offline-First Persistence

Because Sentri produces security events at packet rate, the write path to the backend is a **single, long-lived WebSocket** (`FirewallLogWsService`) rather than one HTTP request per event. Its design is engineered for reliability under real-world conditions:

- Processed logs are enqueued non-blocking from the detection pipeline and flushed as batched `log_batch` messages.
- Batches are chunked and **rate-paced** (one batch every 300 ms) to stay safely under the backend's rate limit, even while draining a large backlog after reconnecting.
- While disconnected, logs accumulate in a bounded in-memory backlog and drain first on the next successful connect, so no events are silently lost.
- The socket **auto-reconnects with exponential backoff**, re-reading a fresh access token on each attempt (so a refreshed token is picked up automatically), and sends periodic pings to stay under the server idle timeout.
- The same socket is bidirectional: the backend can push `blacklist_update` and `settings_update` messages down it, which the application applies to the live pipeline — refreshing the local blacklist when the server auto-blocks an IP, and updating detection thresholds when an administrator changes them.

Offline resilience is a first-class concern. The traffic log, the blacklist, and the settings are all persisted locally (`SharedPreferences`), so the firewall's history, its block list, and its configuration all survive app restarts and remain fully functional with no connectivity. The backend is treated as a best-effort mirror layered on top of an authoritative local store — the mobile mirror of the backend's own persistence guarantees.

## 10. Conclusion

In conclusion, this chapter presented the mobile application implementation of the Sentri Neural Firewall system. The application was built in Flutter on a Clean Architecture foundation with the BLoC pattern, dividing every feature into strictly separated presentation, domain, and data layers — the client-side counterpart of the backend's modular Blueprint design.

The chapter described the technology stack, the code-generated dependency-injection container (`get_it` / `injectable`) that wires the dependency graph, with runtime orchestration extracted into a dedicated bootstrap step, and the feature modules that make up the application: authentication, on-device traffic detection, VPN control, firewall logs, blacklist and access control, hardware metrics, settings, dashboard, analytics, and the Nova AI assistant. It detailed the centralised, token-driven design system that guarantees a consistent and fully responsive user interface across light and dark themes, and the state-management approach that keeps a high-rate event stream from overwhelming the UI.

Particular attention was given to the security and reliability engineering that a production-grade always-on firewall demands: encrypted token storage, transparent and hardened JWT refresh, type-safe error handling, a rate-paced auto-reconnecting WebSocket for streaming security events, and an offline-first persistence strategy in which the backend is a best-effort mirror over an authoritative local store.

Together, these decisions produce a robust, secure, and self-sufficient mobile client — one that not only visualises the system's threat intelligence but actively captures, classifies, and enforces against network threats on the device itself, as detailed in the following chapter.

---

# Chapter — On-Device Packet Interception and Real-Time Detection Engine

## 1. Introduction

The previous chapter described the Sentri mobile application as a whole. This chapter focuses on the component that most distinguishes the project from an ordinary security dashboard: the **on-device packet-interception and real-time detection engine**. This engine is what makes Sentri a genuine firewall — it sees, understands, classifies, and acts on every packet the device sends and receives, in real time, without relaying that traffic to any external server for inspection.

Building a firewall on an unrooted Android phone is challenging because applications have no direct access to the network stack. Sentri solves this using Android's **VpnService** API to create a virtual network interface (a TUN device) through which _all_ device traffic is routed. The application then acts as a transparent userspace proxy: it reads each raw IP packet, parses it, forwards it to the real internet so the user never loses connectivity, injects the server's response back to the device, and — in parallel — extracts statistical features from the flow and scores them with on-device machine-learning models. When a flow is judged malicious, the packet is dropped and its source is blocked at the network level.

This chapter presents the architecture of that engine end to end: the native Android VPN service and its TUN read loop, the packet parser, the connection-tracking TCP/UDP relays, the flow-feature tracker, the traffic-attribution and DNS-labelling subsystems, the on-device TensorFlow Lite inference pipeline, the threat-decision and auto-blocking logic, and the persistence of the block list across process death.

## 2. Detection Engine Overview

The detection engine spans two cooperating layers connected by Flutter's platform channels:

- A **native Kotlin layer** (`NeuralVpnService` and its helpers) that owns the virtual network interface, performs raw packet I/O, relays traffic to and from the real internet, computes per-flow statistics, attributes each flow to its owning application, resolves service names from DNS, and enforces IP-level blocking.
- A **Dart layer** (the traffic repository, the ML data source, and `TrafficBloc`) that receives packet metadata from the native layer, runs the machine-learning models, applies the block/warn thresholds, auto-blocks malicious sources, updates the live UI, and streams the resulting security events to the backend.

The design principle is _"do not wait for the AI."_ The native read loop forwards a clean packet to the internet **immediately**, on its own coroutine, before anything AI-related happens; a copy of the packet's metadata is then pushed asynchronously to the Dart layer for scoring. As a result, detection latency never delays the user's traffic — the firewall observes and reacts in parallel with normal connectivity.

The communication flow of the engine can be summarised as:

```
Device apps → TUN interface → Native read loop → (fast path) → real Internet
                                        │
                                        └ (AI path, async) → EventChannel → TrafficBloc
                                                                   → TFLite models → verdict
                                                                   → auto-block (MethodChannel) + WebSocket to backend
```

## 3. The Native VPN Service and TUN Interface

The heart of the engine is `NeuralVpnService`, an Android `VpnService`. When the user enables protection, the application requests the system VPN permission (via `VpnService.prepare` in the activity) and then starts the service. The service builds a virtual TUN interface configured to:

- assign itself the private point-to-point address `10.0.0.2/32`;
- route **all** traffic through it via the default route `0.0.0.0/0`;
- use a public DNS server (`8.8.8.8`), since the local router's DNS becomes unreachable once all traffic is captured;
- advertise a standard 1500-byte MTU; and
- **exclude the application's own package** from the tunnel, so that when the service opens real sockets to the internet those sockets are not themselves re-captured (which would create an infinite forwarding loop). Individually opened sockets are additionally `protect()`-ed for the same reason.

The service runs as a **foreground service** with a persistent notification (required by Android for a background service that consumes resources) and is started with `START_STICKY`, so that if Android kills the process under memory pressure the service is automatically restarted. This is what makes Sentri _always-on_: after such a restart the block list is reloaded from disk before capture resumes, so known threats stay blocked even before the Flutter UI has reconnected.

A single **read loop** drives everything. It performs a blocking read of one IP packet from the TUN file descriptor, copies the bytes out (so the shared buffer can be reused), parses them, checks the block list, updates flow statistics, resolves the owning application, forwards the packet to the internet on a per-protocol coroutine, and finally pushes the enriched metadata to Flutter. Reads and writes to the TUN descriptor are serialised through a synchronised writer so that concurrent relay coroutines can never interleave and corrupt a packet.

## 4. Packet Parsing and Feature Extraction

### 4.1 Packet parser

`PacketParser` is a stateless component that turns raw IPv4 bytes into a structured `ParsedPacket`. It validates the minimum header length, reads the IP version and header length, the total length, the protocol number, and the source and destination IP addresses, then — depending on the protocol — extracts the TCP or UDP source and destination ports and the TCP control-flag bitmask (SYN, ACK, FIN, RST). Malformed or truncated packets are rejected and silently dropped.

### 4.2 Flow tracker (CIC-IDS-style features)

`FlowTracker` is the component that produces the statistical features the machine-learning models were trained on. A _flow_ is a single network conversation identified by its 4-tuple (source IP/port, destination IP/port); both directions are folded into one flow via a canonical key so that forward (device→server) and backward (server→device) counts are meaningful. For each flow it maintains a sliding window of packet arrival times and volume counters and, on every update, computes a CIC-IDS-style feature set:

| Feature                | Meaning                                                |
| ---------------------- | ------------------------------------------------------ |
| `iat_mean`, `iat_std`  | Mean and standard deviation of inter-arrival time (µs) |
| `duration`             | Age of the flow (µs)                                   |
| `fwd_pkts`, `bwd_pkts` | Forward and backward packet counts                     |
| `fwd_max`, `fwd_mean`  | Maximum and mean forward packet size (bytes)           |
| `fwd_rate`             | Forward packets per second                             |
| `idle_mean`            | Mean of "idle" gaps above a ~1 s activity timeout (µs) |
| `pkt_size_avg`         | Mean packet size across the whole flow (bytes)         |

Timing features are scaled from the millisecond resolution of userspace capture into the microsecond units the models expect. The tracker is thread-safe (it is updated from the read loop and from every relay coroutine), bounds its memory by evicting long-idle flows, and is reset when the VPN stops.

### 4.3 Traffic attribution and DNS labelling

Two further native helpers enrich each packet. `AppResolver` uses Android's `ConnectivityManager.getConnectionOwnerUid` (API 29+) to map a connection to the UID, package, and label of the owning application, and to flag OS/system-owned traffic — results are cached by UID and by flow to avoid a costly lookup per packet. `DnsCache` inspects DNS responses as they pass through the tunnel and builds an IP→hostname table, so the UI can display a friendly service name (e.g. "YouTube") instead of a raw IP address. Together these let each captured event carry the owning application, the resolved service name, and a system/non-system flag.

## 5. Transparent TCP and UDP Relaying

To keep the user online while inspecting traffic, the service reimplements a minimal userspace transport proxy.

For **TCP**, which is connection-oriented and stateful, the service tracks each connection by its 4-tuple. On a SYN it opens a real protected socket to the destination, replies to the device with a crafted SYN-ACK to complete a "fake" three-way handshake, and launches a relay coroutine that reads the server's responses and injects them back into TUN as correctly sequenced TCP data segments; device data segments are written to the real socket and acknowledged. FIN/RST from the device tears the connection down. The service crafts every IP and TCP header by hand and computes the IP and TCP checksums (including the TCP pseudo-header), so the device's own kernel accepts the injected packets as genuine.

For **UDP**, which is connectionless, each packet is handled independently: a fresh protected datagram socket forwards the payload to the real destination and waits briefly for a response, which is then injected back into TUN. DNS responses (port 53) are additionally parsed into the service-name cache. ICMP (ping) is dropped, which does not affect connectivity.

Both relay paths also emit a _backward_ event to Flutter and record the response as a backward packet on the same flow, so the models see complete bidirectional flow statistics.

## 6. On-Device Machine-Learning Inference

Detection runs **entirely on the device** through the `MlDataSource`, which loads five TensorFlow Lite models at startup and scores each packet through whichever models are currently enabled.

The five shipped models specialise in different attack families. Each has its own ordered feature list and standardisation parameters (mean/scale) stored in a single `scaler_params.json` file, so models with different feature counts all work through one common call:

| Model (catalog id)               | Specialisation                                   | Features | Reported accuracy |
| -------------------------------- | ------------------------------------------------ | -------- | ----------------- |
| Brute Force Guard (`bruteForce`) | Repeated password-guessing / credential-stuffing | 4        | 98%               |
| DoS Shield (`dos`)               | Generic denial-of-service floods                 | 5        | 97%               |
| HULK Defender (`dosHulk`)        | HULK rapid-fire web-request storms               | 10       | 96%               |
| Flood Cannon Detector (`loic`)   | LOIC coordinated flood tool                      | 10       | 95%               |
| Heavy Storm Detector (`hoic`)    | HOIC high-volume multi-source DDoS               | 12       | 95%               |

For each packet the traffic repository assembles a superset feature map (protocol plus the flow features computed natively) and passes it to every enabled model. Each model builds its own standardised input vector in its own feature order — any feature it was not supplied defaults to that model's mean, which standardises to a neutral zero — runs inference, and returns a 0–1 threat probability. Because features are matched by name (with alias support), a single feature map serves all five models regardless of which are enabled.

## 7. Threat Decision, Enforcement, and Persistence

The traffic repository turns the per-model scores into a single verdict using an **argmax-with-thresholds** rule. Only models whose features the live pipeline can actually supply are allowed to _drive_ a decision (others may display a score but cannot block normal traffic). The highest-scoring eligible model is selected, and its score is compared against the user-configurable thresholds:

- **Safe** — every eligible model scored below the warn threshold.
- **Warn** — the top score falls between the warn and block thresholds.
- **AI Block** — the top score meets or exceeds the block threshold.

Before ML even runs, two fast paths short-circuit the pipeline: traffic to an already-blacklisted remote IP is immediately marked as blocked, and benign system-owned traffic to well-known ports (DNS, NTP, web, push, discovery) is bypassed to save battery and reduce UI noise — but guarded by a cheap per-destination rate check so that a compromised system component flooding a target is still sent to full scoring. Special protocol categories (TCP handshakes, QUIC, ICMP ping) are also labelled directly.

When a flow is blocked, enforcement is multi-layered. The offending remote IP is added to the persistent blacklist, and a `blockIp` command is sent down the method channel to the native service, which (a) drops all future packets to/from that IP inside the read loop and (b) tears down any TCP connection already in flight to it. The block set is **persisted to disk** and reloaded on every service start, so a known threat stays blocked across process kills and restarts; the device's own TUN address is explicitly protected from ever being blacklisted, which would otherwise black-hole all of the device's traffic. Each verdict is finally pushed to the UI (updating the live table and threat sparkline), persisted locally, and streamed to the backend over the WebSocket described in the previous chapter.

## 8. Reliability and Performance Engineering

Several engineering measures make the engine viable as an always-on service:

- **Non-blocking fast path** — clean packets are forwarded before any AI work, so inference never adds latency to the user's traffic.
- **Survives process death** — `START_STICKY` plus a disk-persisted block list plus `VpnCubit.restore()` mean the firewall resumes protection automatically after a kill or restart, reattaching the UI to the live session.
- **Bounded memory** — flow, UID, and DNS caches are all size-bounded with eviction, and the in-memory log queue and sparkline are capped.
- **Coalesced I/O** — local log persistence is debounced (one write every two seconds), and backend transmission is batched and rate-paced.
- **Performance visibility** — the hardware-metrics module continuously samples CPU, RAM, and battery, letting the team verify that continuous capture and on-device inference stay within an acceptable budget.
- **Enforcement kill-switch** — the native layer exposes a compile-time flag that can drop it to a detection-only ("observe and label") mode without disabling tracking, useful for testing and evaluation.

## 9. Conclusion

In conclusion, this chapter presented the on-device packet-interception and real-time detection engine that gives Sentri its identity as a true mobile firewall. Using Android's VpnService to create a virtual TUN interface, the native Kotlin layer routes all device traffic through the application, parses each raw IP packet, transparently relays TCP and UDP flows so the user never loses connectivity, and extracts a rich CIC-IDS-style set of flow features while attributing every flow to its owning application and resolving human-readable service names.

Those features are scored **entirely on the device** by five specialised TensorFlow Lite models, and an argmax-with-thresholds decision classifies each flow as safe, warning, or a block. Malicious sources are enforced at the network level and persisted so they remain blocked across process death, while every verdict is surfaced live in the UI and streamed to the backend for centralised threat intelligence.

The chapter also highlighted the reliability and performance engineering — a non-blocking fast path, sticky always-on operation, bounded caches, coalesced and rate-paced I/O, and continuous performance monitoring — that allows this engine to run continuously on an unrooted consumer device. Together with the application layer of the previous chapter, this engine completes the mobile side of the Sentri Neural Firewall: a self-sufficient, privacy-preserving, real-time intrusion-detection and prevention client that protects the device on its own and is made stronger by the centralised backend.
