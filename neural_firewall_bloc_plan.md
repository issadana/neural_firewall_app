# Flutter AI Neural Firewall — Complete Implementation Plan (Bloc/Cubit Edition)

---

## 1. PACKAGE LIST (`pubspec.yaml`)

```yaml
name: neural_firewall
description: AI-powered Network Intrusion Detection System
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter

  # ── State Management ──────────────────────────────────────────────
  flutter_bloc: ^8.1.4              # Primary state management (Bloc + Cubit)
  bloc: ^8.1.4                      # Core bloc library
  equatable: ^2.0.5                 # Value equality for states/events

  # ── Native Bridge (VPN / MethodChannel) ──────────────────────────
  flutter_foreground_task: ^6.1.3   # Keep VPN service alive in foreground

  # ── ML Inference ─────────────────────────────────────────────────
  tflite_flutter: ^0.10.4           # On-device TFLite inference
  tflite_flutter_helper: ^0.4.2     # Tensor pre/post processing

  # ── Persistence ──────────────────────────────────────────────────
  shared_preferences: ^2.2.2        # Simple key-value (UI prefs, thresholds)
  flutter_secure_storage: ^9.0.0    # Encrypted JWT token storage

  # ── Networking / HTTP Client ──────────────────────────────────────
  dio: ^5.4.0                       # HTTP client for backend API calls

  # ── Utilities ────────────────────────────────────────────────────
  intl: ^0.19.0                     # Date/time formatting
  collection: ^1.18.0               # ListQueue, sorted collections

  # ── UI Components ─────────────────────────────────────────────────
  flutter_animate: ^4.3.0           # Animated threat indicators
  fl_chart: ^0.66.2                 # Live traffic sparkline chart
  auto_size_text: ^3.0.0            # Adaptive text in traffic table
  shimmer: ^3.0.0                   # Loading skeleton screens
  badges: ^3.1.2                    # Notification badges on nav items
  percent_indicator: ^4.2.3         # Circular threat % gauges

  # ── Permissions ──────────────────────────────────────────────────
  permission_handler: ^11.2.0       # Runtime permissions (VPN consent)

  # ── Logging / Dev ────────────────────────────────────────────────
  logger: ^2.0.2                    # Structured debug logging
  freezed_annotation: ^2.4.1        # Immutable data classes

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  freezed: ^2.4.6
  bloc_test: ^9.1.5                 # Unit testing for Blocs/Cubits
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.1
```

---

## 2. PROJECT STRUCTURE

```
neural_firewall/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/neuralfw/
│   │   │   │   ├── MainActivity.kt              ← MethodChannel host
│   │   │   │   ├── vpn/
│   │   │   │   │   ├── NeuralVpnService.kt       ← Core VpnService
│   │   │   │   │   ├── PacketParser.kt           ← Packet byte parser
│   │   │   │   │   ├── FlowTracker.kt            ← TCP state + flow timing
│   │   │   │   │   └── VpnEventSink.kt           ← EventChannel bridge
│   │   │   │   └── utils/
│   │   │   │       └── IpUtils.kt
│   │   │   ├── res/xml/
│   │   │   │   └── network_security_config.xml
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle
│   └── build.gradle
│
├── assets/
│   ├── models/
│   │   ├── bruteforce_detector.tflite
│   │   └── dos_specialist.tflite
│   └── icons/
│       └── shield.png
│
├── lib/
│   ├── main.dart                                ← App entry, BlocProviders
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   └── utils/
│   │       ├── protocol_helper.dart
│   │       └── format_utils.dart
│   │
│   ├── api/                                     ← Backend API layer
│   │   ├── api_client.dart                      ← Dio singleton + interceptors (auth header, refresh)
│   │   ├── auth_api.dart                        ← /auth endpoints
│   │   ├── blacklist_api.dart                   ← /blacklist CRUD endpoints
│   │   ├── acl_api.dart                         ← /acl CRUD endpoints
│   │   ├── settings_api.dart                    ← /settings endpoints
│   │   └── predict_api.dart                     ← /predict endpoint
│   │
│   ├── models/
│   │   ├── packet_record.dart                   ← Freezed: live table row
│   │   ├── packet_record.freezed.dart
│   │   ├── flow_features.dart
│   │   ├── blacklist_entry.dart                 ← Plain Dart model (no Hive)
│   │   ├── acl_entry.dart
│   │   ├── detection_result.dart
│   │   ├── auth_token.dart                      ← JWT access + refresh tokens
│   │   └── dashboard_stats.dart
│   │
│   ├── services/
│   │   ├── vpn_bridge_service.dart
│   │   ├── ml_inference_service.dart
│   │   ├── blacklist_service.dart               ← Calls blacklist_api.dart
│   │   ├── acl_service.dart                     ← Calls acl_api.dart
│   │   ├── auth_service.dart                    ← Token storage (flutter_secure_storage)
│   │   ├── heuristic_service.dart
│   │   └── packet_processor_service.dart
│   │
│   ├── blocs/
│   │   ├── auth/
│   │   │   ├── auth_cubit.dart                  ← login / register / logout
│   │   │   └── auth_state.dart
│   │   ├── vpn/
│   │   │   ├── vpn_cubit.dart                   ← VPN start/stop state
│   │   │   └── vpn_state.dart
│   │   ├── traffic/
│   │   │   ├── traffic_bloc.dart                ← Listens to packet stream
│   │   │   ├── traffic_event.dart
│   │   │   └── traffic_state.dart
│   │   ├── dashboard/
│   │   │   ├── dashboard_cubit.dart             ← Derived stats (listens to traffic)
│   │   │   └── dashboard_state.dart
│   │   ├── blacklist/
│   │   │   ├── blacklist_cubit.dart             ← CRUD via backend API
│   │   │   └── blacklist_state.dart
│   │   ├── acl/
│   │   │   ├── acl_cubit.dart
│   │   │   └── acl_state.dart
│   │   └── settings/
│   │       ├── settings_cubit.dart              ← SharedPreferences + backend sync
│   │       └── settings_state.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── stats_row.dart
│   │   │       ├── control_bar.dart
│   │   │       ├── traffic_table.dart
│   │   │       ├── traffic_row.dart
│   │   │       └── threat_sparkline.dart
│   │   ├── blacklist/
│   │   │   ├── blacklist_screen.dart
│   │   │   └── widgets/
│   │   │       ├── blacklist_tile.dart
│   │   │       └── add_ip_dialog.dart
│   │   ├── acl/
│   │   │   ├── acl_screen.dart
│   │   │   └── widgets/
│   │   │       └── acl_tile.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── splash/
│   │       └── splash_screen.dart
│   │
│   └── app.dart                                 ← MaterialApp + router + MultiBlocProvider
│
├── test/
│   ├── blocs/
│   │   ├── vpn_cubit_test.dart
│   │   ├── traffic_bloc_test.dart
│   │   ├── blacklist_cubit_test.dart
│   │   └── dashboard_cubit_test.dart
│   ├── ml_inference_test.dart
│   ├── heuristic_service_test.dart
│   └── packet_parser_test.dart
│
└── pubspec.yaml
```

---

## 3. SCREEN-BY-SCREEN BREAKDOWN

### Screen 1: Splash Screen (`splash_screen.dart`)
- Animated shield logo (`flutter_animate` scale + fade)
- Loads Hive boxes, initialises TFLite models, checks VPN permission
- Navigates to Home on completion
- Shows error snackbar if TFLite assets missing

### Screen 2: Home Dashboard (`home_screen.dart`)

**Top Section — Control Bar**
- `NetworkInterfacePicker` dropdown (populated from `VpnBridgeService.getInterfaces()`)
- START / STOP `ElevatedButton` (green/red) — dispatches `VpnCubit.start()` / `stop()`
- VPN status indicator dot (animated pulse via `BlocBuilder<VpnCubit, VpnState>`)
- CLEAR LOGS `TextButton` — dispatches `TrafficBloc.add(ClearLogsEvent())`

**Stats Row — 3 Cards**

| PACKETS | IPs BLACKLISTED | MAX THREAT |
|---|---|---|
| 1,482 Analyzed | 3 Auto-blocked | 94.2% Highest detected |

Each card reads from `BlocBuilder<DashboardCubit, DashboardState>`. MAX THREAT uses `percent_indicator` circular gauge.

**Live Threat Sparkline**
- `fl_chart` `LineChart` showing last 60 samples of `max(BF%, DoS%)` over time
- Red line, dark background, auto-scrolling
- Driven by `BlocBuilder<TrafficBloc, TrafficState>`

**Traffic Table**

Scrollable `ListView.builder` driven by `BlocBuilder<TrafficBloc, TrafficState>`:

| Status | Time | Src IP:Port | Dst IP:Port | Protocol | Size | BF% | DoS% |
|---|---|---|---|---|---|---|---|
| 🚫 AI BLOCK | 14:32:01 | 192.168.1.5:4421 | 10.0.0.1:22 | TCP | 128B | 87% | 12% |
| ⚠️ WARN | 14:32:02 | 10.0.1.3:9001 | 10.0.0.1:80 | TCP | 64B | 52% | 8% |
| ✅ SAFE | 14:32:03 | 10.0.2.1:443 | 10.0.0.1:443 | TCP | 256B | 3% | 1% |

**Status Logic (identical to Python app)**

| Status | Condition |
|---|---|
| 🚫 AI BLOCK | BF% ≥ 20 OR DoS% ≥ 20 (ML triggered) |
| ⚠️ WARN | BF% ≥ 10 OR DoS% ≥ 10 (below block threshold) |
| ✅ SAFE | All scores < 10% |
| 🔵 TCP | TCP handshake packet (SYN without data) |
| 🟣 QUIC | UDP port 443 |
| 🟡 PING | ICMP echo |
| ❌ ERR | Parse error / unknown protocol |

Row colors: RED bg for BLOCK, YELLOW bg for WARN, transparent for others.

**Bottom Navigation Bar**

`[🏠 Dashboard] [🚫 Blacklist] [🛡 ACL] [⚙️ Settings]`

Badge on Blacklist tab reads count from `BlocBuilder<BlacklistCubit, BlacklistState>`.

### Screen 3: Blacklist Screen (`blacklist_screen.dart`)
- Header: "Dynamic Blacklist" + count chip
- `ListView` of `BlacklistTile`, driven by `BlocBuilder<BlacklistCubit, BlacklistState>`
- Swipe-to-delete dispatches `BlacklistCubit.remove(ip)`
- FAB: `+` opens `AddIpDialog` → dispatches `BlacklistCubit.addManual(ip)`
- CLEAR ALL dispatches `BlacklistCubit.clearAll()`

### Screen 4: ACL Screen (`acl_screen.dart`)
- Same tile layout as Blacklist, backed by `AclCubit`
- FAB to add manual ACL entry
- ACL entries are permanent blocks checked before ML inference

### Screen 5: Settings Screen (`settings_screen.dart`)
- **Detection Thresholds**: "Block Threshold (%)" slider (default 20), "Warn Threshold (%)" slider (default 10) — dispatches `SettingsCubit.setBlockThreshold(value)`
- **Heuristics**: Flood Detection toggle, SYN Flood Detection toggle, packet/SYN rate text fields
- **ML Models**: Brute Force Detector toggle, DoS Specialist toggle
- **Log Settings**: Max Log Entries field
- **About**: App version, model feature counts

---

## 4. ARCHITECTURE

### State Management: Bloc / Cubit

```
                 ┌─────────────────────────────────────┐
                 │         Flutter UI Layer             │
                 │  HomeScreen  BlacklistScreen  etc.   │
                 │   (BlocBuilder / BlocListener)       │
                 └──────────────┬──────────────────────┘
                                │ watch / read
                 ┌──────────────▼──────────────────────┐
                 │         Bloc / Cubit Layer           │
                 │  TrafficBloc  (Bloc<Event, State>)   │
                 │  DashboardCubit (listens to Traffic) │
                 │  BlacklistCubit (CRUD + Hive)        │
                 │  VpnCubit   (start/stop/status)      │
                 │  AclCubit   (pre-blocked list)       │
                 │  SettingsCubit (SharedPrefs)         │
                 └──────────────┬──────────────────────┘
                                │ calls
                 ┌──────────────▼──────────────────────┐
                 │           Services Layer             │
                 │  PacketProcessorService (orchestrat.)│
                 │  VpnBridgeService  MlInferenceService│
                 │  BlacklistService  HeuristicService  │
                 └──────────────┬──────────────────────┘
                                │
                 ┌──────────────▼──────────────────────┐
                 │        Native Android Layer          │
                 │  NeuralVpnService (Kotlin)           │
                 │  PacketParser  FlowTracker           │
                 │  VpnEventSink (EventChannel)         │
                 └─────────────────────────────────────┘
```

**Rule of thumb:**
- Use **Cubit** for simple state machines with no complex event branching (VPN on/off, blacklist CRUD, settings sliders).
- Use **Bloc** for the traffic stream — it has multiple event types (`PacketReceived`, `ClearLogs`, `ToggleCapture`) and async stream subscription logic.

### Data Flow (per packet)

```
Network Packet
    │
    ▼ (TUN interface read loop)
NeuralVpnService.kt
    │  raw bytes → PacketParser
    ▼
PacketParser.kt ──► FlowTracker.kt (update flow state)
    │                     │
    │  ParsedPacket DTO    │ FlowStats (IAT, duration)
    └──────────┬───────────┘
               ▼
    EventChannel (JSON string)
               │
               ▼ (Dart side)
    VpnBridgeService (Stream<Map<String,dynamic>>)
               │
               ▼
    TrafficBloc receives PacketReceived event
               │
               ▼
    PacketProcessorService.process(raw)
       ├── blacklistService.isBlocked(srcIp)?  → AI BLOCK (skip ML)
       ├── aclService.isBlocked(srcIp)?        → AI BLOCK (skip ML)
       ├── heuristicService.check(packet)      → heuristic flags
       ├── mlInferenceService.runBruteForce()  → bfScore (0.0–1.0)
       ├── mlInferenceService.runDos()         → dosScore (0.0–1.0)
       ├── applyThresholds()                   → PacketStatus enum
       └── if status==BLOCK → BlacklistCubit.addAutoMl(srcIp)
               │
               ▼
    TrafficState emitted (new ListQueue<PacketRecord>)
               │
               ├─▶  DashboardCubit.onTrafficUpdated(state) → DashboardState
               │
               ▼
    Flutter UI rebuilds via BlocBuilder
```

---

## 5. BLOC / CUBIT DEFINITIONS (Dart)

### VpnCubit

```dart
// blocs/vpn/vpn_state.dart
enum VpnStatus { stopped, starting, running, error }

class VpnState extends Equatable {
  final VpnStatus status;
  final String? errorMessage;
  const VpnState({required this.status, this.errorMessage});

  @override List<Object?> get props => [status, errorMessage];
}
```

```dart
// blocs/vpn/vpn_cubit.dart
class VpnCubit extends Cubit<VpnState> {
  final VpnBridgeService _bridge;

  VpnCubit(this._bridge) : super(const VpnState(status: VpnStatus.stopped));

  Future<void> start() async {
    emit(const VpnState(status: VpnStatus.starting));
    try {
      await _bridge.startVpn();
      emit(const VpnState(status: VpnStatus.running));
    } catch (e) {
      emit(VpnState(status: VpnStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> stop() async {
    await _bridge.stopVpn();
    emit(const VpnState(status: VpnStatus.stopped));
  }
}
```

---

### TrafficBloc

```dart
// blocs/traffic/traffic_event.dart
abstract class TrafficEvent extends Equatable {}

class PacketReceived extends TrafficEvent {
  final Map<String, dynamic> rawPacket;
  const PacketReceived(this.rawPacket);
  @override List<Object> get props => [rawPacket];
}

class ClearLogsEvent extends TrafficEvent {
  @override List<Object> get props => [];
}

class StartListeningEvent extends TrafficEvent {
  @override List<Object> get props => [];
}

class StopListeningEvent extends TrafficEvent {
  @override List<Object> get props => [];
}
```

```dart
// blocs/traffic/traffic_state.dart
class TrafficState extends Equatable {
  final ListQueue<PacketRecord> records;   // max 200
  final List<double> sparklineData;        // last 60 max-threat values
  const TrafficState({required this.records, required this.sparklineData});

  @override List<Object> get props => [records, sparklineData];
}
```

```dart
// blocs/traffic/traffic_bloc.dart
class TrafficBloc extends Bloc<TrafficEvent, TrafficState> {
  final VpnBridgeService _bridge;
  final PacketProcessorService _processor;
  static const int _maxEntries = 200;
  static const int _sparklineLength = 60;

  StreamSubscription<Map<String, dynamic>>? _packetSub;

  TrafficBloc(this._bridge, this._processor)
      : super(TrafficState(
          records: ListQueue(),
          sparklineData: [],
        )) {
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<PacketReceived>(_onPacketReceived);
    on<ClearLogsEvent>(_onClearLogs);
  }

  void _onStartListening(StartListeningEvent event, Emitter<TrafficState> emit) {
    _packetSub = _bridge.packetStream.listen(
      (raw) => add(PacketReceived(raw)),
    );
  }

  void _onStopListening(StopListeningEvent event, Emitter<TrafficState> emit) {
    _packetSub?.cancel();
    _packetSub = null;
  }

  void _onPacketReceived(PacketReceived event, Emitter<TrafficState> emit) {
    final record = _processor.process(event.rawPacket);
    final newQueue = ListQueue<PacketRecord>.from(state.records);

    newQueue.addFirst(record);
    if (newQueue.length > _maxEntries) newQueue.removeLast();

    final maxThreat = max(record.bruteForceScore, record.dosScore);
    final newSparkline = [...state.sparklineData, maxThreat * 100];
    if (newSparkline.length > _sparklineLength) newSparkline.removeAt(0);

    emit(TrafficState(records: newQueue, sparklineData: newSparkline));
  }

  void _onClearLogs(ClearLogsEvent event, Emitter<TrafficState> emit) {
    emit(TrafficState(records: ListQueue(), sparklineData: []));
  }

  @override
  Future<void> close() {
    _packetSub?.cancel();
    return super.close();
  }
}
```

---

### DashboardCubit

```dart
// blocs/dashboard/dashboard_state.dart
class DashboardState extends Equatable {
  final int packetsAnalyzed;
  final int ipsBlacklisted;
  final double maxThreatPercent;
  final int blockedCount;
  final int warnCount;
  final int safeCount;

  const DashboardState({
    this.packetsAnalyzed = 0,
    this.ipsBlacklisted = 0,
    this.maxThreatPercent = 0.0,
    this.blockedCount = 0,
    this.warnCount = 0,
    this.safeCount = 0,
  });

  @override List<Object> get props =>
      [packetsAnalyzed, ipsBlacklisted, maxThreatPercent, blockedCount, warnCount, safeCount];
}
```

```dart
// blocs/dashboard/dashboard_cubit.dart
// Listens to TrafficBloc and BlacklistCubit streams — derives stats
class DashboardCubit extends Cubit<DashboardState> {
  late final StreamSubscription _trafficSub;
  late final StreamSubscription _blacklistSub;

  DashboardCubit({
    required TrafficBloc trafficBloc,
    required BlacklistCubit blacklistCubit,
  }) : super(const DashboardState()) {
    _trafficSub = trafficBloc.stream.listen(_onTrafficUpdated);
    _blacklistSub = blacklistCubit.stream.listen(_onBlacklistUpdated);
  }

  int _blacklistedCount = 0;

  void _onTrafficUpdated(TrafficState traffic) {
    final records = traffic.records;
    if (records.isEmpty) return;

    final maxThreat = records
        .map((r) => max(r.bruteForceScore, r.dosScore) * 100)
        .reduce(max);

    emit(DashboardState(
      packetsAnalyzed: records.length,
      ipsBlacklisted: _blacklistedCount,
      maxThreatPercent: maxThreat,
      blockedCount: records.where((r) => r.status == PacketStatus.aiBlock).length,
      warnCount: records.where((r) => r.status == PacketStatus.warn).length,
      safeCount: records.where((r) => r.status == PacketStatus.safe).length,
    ));
  }

  void _onBlacklistUpdated(BlacklistState bl) {
    _blacklistedCount = bl.entries.length;
    // Re-emit with updated blacklist count
    emit(state.copyWith(ipsBlacklisted: _blacklistedCount));
  }

  @override
  Future<void> close() {
    _trafficSub.cancel();
    _blacklistSub.cancel();
    return super.close();
  }
}
```

---

### BlacklistCubit

```dart
// blocs/blacklist/blacklist_state.dart
class BlacklistState extends Equatable {
  final List<BlacklistEntry> entries;
  const BlacklistState({required this.entries});
  @override List<Object> get props => [entries];
}
```

```dart
// blocs/blacklist/blacklist_cubit.dart
// BlacklistService maintains an in-memory Set<String> cache and syncs to backend.
class BlacklistCubit extends Cubit<BlacklistState> {
  final BlacklistService _service;

  BlacklistCubit(this._service) : super(const BlacklistState(entries: [], isLoading: false));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final entries = await _service.getAll(); // GET /blacklist
    emit(BlacklistState(entries: entries, isLoading: false));
  }

  Future<void> addAutoMl(String ip, {required double bfScore, required double dosScore}) async {
    await _service.add(ip, BlacklistReason.autoMl, bfScore: bfScore, dosScore: dosScore); // POST /blacklist
    await load();
  }

  Future<void> addManual(String ip) async {
    await _service.add(ip, BlacklistReason.manual); // POST /blacklist
    await load();
  }

  Future<void> remove(String ip) async {
    await _service.remove(ip); // DELETE /blacklist/{ip}
    await load();
  }

  Future<void> clearAll() async {
    await _service.clearAll(); // DELETE /blacklist
    emit(const BlacklistState(entries: [], isLoading: false));
  }
}
```

---

### AclCubit

```dart
// blocs/acl/acl_cubit.dart — mirrors BlacklistCubit but uses AclService
class AclCubit extends Cubit<AclState> {
  final AclService _service;

  AclCubit(this._service) : super(const AclState(entries: []));

  Future<void> load() async {
    emit(AclState(entries: await _service.getAll()));
  }

  Future<void> add(String ip, {String? notes}) async {
    await _service.add(ip, notes: notes);
    await load();
  }

  Future<void> remove(String ip) async {
    await _service.remove(ip);
    await load();
  }
}
```

---

### SettingsCubit

```dart
// blocs/settings/settings_state.dart
class SettingsState extends Equatable {
  final double blockThreshold;    // default 0.20
  final double warnThreshold;     // default 0.10
  final bool floodDetection;
  final bool synFloodDetection;
  final int floodPktPerSec;
  final int synFloodPerSec;
  final bool bfModelEnabled;
  final bool dosModelEnabled;
  final int maxLogEntries;

  const SettingsState({
    this.blockThreshold = 0.20,
    this.warnThreshold = 0.10,
    this.floodDetection = true,
    this.synFloodDetection = true,
    this.floodPktPerSec = 1000,
    this.synFloodPerSec = 100,
    this.bfModelEnabled = true,
    this.dosModelEnabled = true,
    this.maxLogEntries = 200,
  });

  SettingsState copyWith({...}) => ...;  // standard copyWith pattern
  @override List<Object> get props => [...];
}
```

```dart
// blocs/settings/settings_cubit.dart
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    emit(SettingsState(
      blockThreshold: _prefs.getDouble('blockThreshold') ?? 0.20,
      warnThreshold: _prefs.getDouble('warnThreshold') ?? 0.10,
      floodDetection: _prefs.getBool('floodDetection') ?? true,
      synFloodDetection: _prefs.getBool('synFloodDetection') ?? true,
      floodPktPerSec: _prefs.getInt('floodPktPerSec') ?? 1000,
      synFloodPerSec: _prefs.getInt('synFloodPerSec') ?? 100,
      bfModelEnabled: _prefs.getBool('bfModelEnabled') ?? true,
      dosModelEnabled: _prefs.getBool('dosModelEnabled') ?? true,
      maxLogEntries: _prefs.getInt('maxLogEntries') ?? 200,
    ));
  }

  Future<void> setBlockThreshold(double v) async {
    await _prefs.setDouble('blockThreshold', v);
    emit(state.copyWith(blockThreshold: v));
  }

  Future<void> setWarnThreshold(double v) async {
    await _prefs.setDouble('warnThreshold', v);
    emit(state.copyWith(warnThreshold: v));
  }

  Future<void> toggleFloodDetection(bool v) async {
    await _prefs.setBool('floodDetection', v);
    emit(state.copyWith(floodDetection: v));
  }

  // ... similar methods for all other settings
}
```

---

### App Entry Point (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs        = await SharedPreferences.getInstance();
  final authService  = AuthService();          // flutter_secure_storage wrapper
  final apiClient    = ApiClient(authService); // Dio + interceptors
  final mlService    = MlInferenceService();
  await mlService.init();

  final blacklistService = BlacklistService(BlacklistApi(apiClient));
  final aclService       = AclService(AclApi(apiClient));
  final heuristicService = HeuristicService();
  final vpnBridgeService = VpnBridgeService();

  final authCubit      = AuthCubit(AuthApi(apiClient), authService);
  final settingsCubit  = SettingsCubit(prefs, SettingsApi(apiClient));
  final blacklistCubit = BlacklistCubit(blacklistService);
  final aclCubit       = AclCubit(aclService);

  final packetProcessor = PacketProcessorService(
    blacklist: blacklistService,
    acl: aclService,
    heuristics: heuristicService,
    ml: mlService,
    blockThreshold: settingsCubit.state.blockThreshold,
    warnThreshold: settingsCubit.state.warnThreshold,
  );

  final trafficBloc   = TrafficBloc(vpnBridgeService, packetProcessor);
  final vpnCubit      = VpnCubit(vpnBridgeService);
  final dashboardCubit = DashboardCubit(
    trafficBloc: trafficBloc,
    blacklistCubit: blacklistCubit,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider.value(value: vpnCubit),
        BlocProvider.value(value: trafficBloc),
        BlocProvider.value(value: dashboardCubit),
        BlocProvider.value(value: blacklistCubit),
        BlocProvider.value(value: aclCubit),
        BlocProvider.value(value: settingsCubit),
      ],
      child: const NeuralFirewallApp(),
    ),
  );
}
```

---

### UI Consumption Pattern

```dart
// Example: HomeScreen reading multiple blocs
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Stats row — derived stats from DashboardCubit
          BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, stats) => StatsRow(stats: stats),
          ),

          // Control bar — VPN status from VpnCubit
          BlocBuilder<VpnCubit, VpnState>(
            builder: (context, vpn) => ControlBar(
              isRunning: vpn.status == VpnStatus.running,
              onStart: () {
                context.read<VpnCubit>().start();
                context.read<TrafficBloc>().add(StartListeningEvent());
              },
              onStop: () {
                context.read<VpnCubit>().stop();
                context.read<TrafficBloc>().add(StopListeningEvent());
              },
              onClear: () => context.read<TrafficBloc>().add(ClearLogsEvent()),
            ),
          ),

          // Sparkline — traffic stream
          BlocBuilder<TrafficBloc, TrafficState>(
            builder: (context, traffic) =>
                ThreatSparkline(data: traffic.sparklineData),
          ),

          // Traffic table — traffic stream
          Expanded(
            child: BlocBuilder<TrafficBloc, TrafficState>(
              builder: (context, traffic) => TrafficTable(
                records: traffic.records.toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. NATIVE ANDROID CODE (Kotlin)

*(Unchanged from original plan — Kotlin layer is independent of Flutter state management)*

### `AndroidManifest.xml` additions

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>

<service
    android:name=".vpn.NeuralVpnService"
    android:permission="android.permission.BIND_VPN_SERVICE"
    android:exported="false"
    android:foregroundServiceType="specialUse">
    <intent-filter>
        <action android:name="android.net.VpnService"/>
    </intent-filter>
</service>
```

### `NeuralVpnService.kt`

```kotlin
class NeuralVpnService : VpnService() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
        const val BUFFER_SIZE = 32767
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val flowTracker = FlowTracker()

    fun startCapture() {
        vpnInterface = Builder()
            .addAddress("10.0.0.2", 32)
            .addRoute("0.0.0.0", 0)
            .addDnsServer("8.8.8.8")
            .setSession("NeuralFirewall")
            .setMtu(1500)
            .establish()

        scope.launch { readPacketLoop() }
    }

    private suspend fun readPacketLoop() {
        val input = FileInputStream(vpnInterface!!.fileDescriptor)
        val output = FileOutputStream(vpnInterface!!.fileDescriptor)
        val buffer = ByteBuffer.allocate(BUFFER_SIZE)

        while (isActive) {
            buffer.clear()
            val length = input.read(buffer.array())
            if (length <= 0) continue

            buffer.limit(length)
            val rawBytes = buffer.array().copyOf(length)
            val parsed = PacketParser.parse(rawBytes, System.currentTimeMillis())

            parsed?.let {
                val flowStats = flowTracker.update(it)
                val enriched = it.copy(flowIatMean = flowStats.iatMean, flowDuration = flowStats.duration)
                withContext(Dispatchers.Main) {
                    eventSink?.success(enriched.toJson())
                }
            }

            output.write(rawBytes, 0, length)
        }
    }

    fun stopCapture() {
        scope.cancel()
        vpnInterface?.close()
        vpnInterface = null
        flowTracker.reset()
    }

    override fun onDestroy() { stopCapture(); super.onDestroy() }
}
```

### `PacketParser.kt`, `FlowTracker.kt`, `MainActivity.kt`

These are identical to the original plan. The EventChannel and MethodChannel wiring in `MainActivity.kt` is transport-layer only and completely agnostic to Flutter state management.

---

## 7. ML MODEL CONVERSION STRATEGY

*(Unchanged from original plan)*

### sklearn → ONNX → TFLite pipeline

```python
# convert_models.py
import pickle
import numpy as np
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

with open("bruteforce_detector.pkl", "rb") as f:
    bf_model = pickle.load(f)
with open("dos_specialist.pkl", "rb") as f:
    dos_model = pickle.load(f)

bf_onnx = convert_sklearn(bf_model,
    initial_types=[("float_input", FloatTensorType([None, 4]))],
    options={type(bf_model): {"zipmap": False}})
with open("bruteforce_detector.onnx", "wb") as f:
    f.write(bf_onnx.SerializeToString())

dos_onnx = convert_sklearn(dos_model,
    initial_types=[("float_input", FloatTensorType([None, 5]))],
    options={type(dos_model): {"zipmap": False}})
with open("dos_specialist.onnx", "wb") as f:
    f.write(dos_onnx.SerializeToString())

# ONNX → TFLite
import tensorflow as tf
for name in ["bruteforce_detector", "dos_specialist"]:
    converter = tf.lite.TFLiteConverter.from_saved_model(f"{name}_saved_model")
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    with open(f"assets/models/{name}.tflite", "wb") as f:
        f.write(tflite_model)
```

**Fallback**: If ONNX fails, extract trees to JSON and implement a `JsonRandomForest` walker in Dart.

---

## 8. DATA MODELS (Dart)

### `packet_record.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'packet_record.freezed.dart';

enum PacketStatus { aiBlock, warn, safe, tcp, quic, ping, err }

@freezed
class PacketRecord with _$PacketRecord {
  const factory PacketRecord({
    required String id,
    required DateTime timestamp,
    required String srcIp,
    required int srcPort,
    required String dstIp,
    required int dstPort,
    required int protocol,
    required int sizeBytes,
    required double bruteForceScore,
    required double dosScore,
    required PacketStatus status,
    @Default(false) bool isBlacklisted,
    @Default(false) bool isAcl,
  }) = _PacketRecord;

  const PacketRecord._();

  String get statusEmoji => switch (status) {
    PacketStatus.aiBlock => '🚫',
    PacketStatus.warn    => '⚠️',
    PacketStatus.safe    => '✅',
    PacketStatus.tcp     => '🔵',
    PacketStatus.quic    => '🟣',
    PacketStatus.ping    => '🟡',
    PacketStatus.err     => '❌',
  };

  String get protocolName => switch (protocol) {
    6  => 'TCP',
    17 => 'UDP',
    1  => 'ICMP',
    _  => 'OTHER',
  };
}
```

### `dashboard_stats.dart`

```dart
@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0)   int packetsAnalyzed,
    @Default(0)   int ipsBlacklisted,
    @Default(0.0) double maxThreatPercent,
    @Default(0)   int blockedCount,
    @Default(0)   int warnCount,
    @Default(0)   int safeCount,
  }) = _DashboardStats;
}
```

---

## 9. KEY SERVICES (Dart)

*(Unchanged from original plan — services are pure business logic with no Riverpod dependencies)*

- `VpnBridgeService` — `MethodChannel` + `EventChannel` wrapper
- `MlInferenceService` — TFLite dual-model inference (on-device) or delegates to `PredictApi`
- `BlacklistService` — in-memory `Set<String>` cache + calls `BlacklistApi` for persistence
- `AclService` — in-memory pre-blocked IP set + calls `AclApi` for persistence
- `AuthService` — wraps `FlutterSecureStorage`; stores/retrieves JWT access & refresh tokens
- `HeuristicService` — Flood + SYN flood detection (rate windows)
- `PacketProcessorService` — Orchestrates all services per packet

---

## 10. FLUTTER-VPN BRIDGE (Data Path)

```
Android TUN Interface
         │
         ▼
NeuralVpnService read loop
         │  Raw IPv4 bytes
         ▼
PacketParser.parse(bytes) ──► FlowTracker.update(packet)
         │                         │ FlowStats
         └──────────────────────────┘
               Enriched ParsedPacket
         │
         ▼
EventChannel.eventSink.success(jsonString)
═════════╪══════ Kotlin / Dart boundary ══════════════
         │
         ▼
VpnBridgeService.packetStream  (Stream<Map<String,dynamic>>)
         │
         ▼  (TrafficBloc.add(PacketReceived(raw)))
TrafficBloc._onPacketReceived
  → PacketProcessorService.process(raw)
  → emits TrafficState (new ListQueue<PacketRecord>)
         │
         ├─▶  DashboardCubit recomputes via stream subscription
         │
         ▼
BlocBuilder<TrafficBloc, TrafficState>  →  UI rebuilds
BlocBuilder<DashboardCubit, DashboardState>  →  stats cards
```

---

## 11. STEP-BY-STEP IMPLEMENTATION ORDER

### Phase 1: Project Setup (Day 1)
- `flutter create neural_firewall --org com.neuralfw`
- Add all `pubspec.yaml` dependencies (`flutter_bloc`, `equatable`, `bloc_test`), run `flutter pub get`
- Set up Android manifest permissions
- Set `minSdkVersion 21` in `android/app/build.gradle`
- Set up dark cyberpunk `ThemeData` in `app_theme.dart`
- Scaffold `MultiBlocProvider` in `main.dart` and `BottomNavigationBar` with 4 tabs

### Phase 2: ML Model Conversion (Day 2)
- Run `convert_models.py` — install `skl2onnx`, `onnx-tf`, `tensorflow`
- Verify TFLite output shapes (4 and 5 input features)
- Place `.tflite` files in `assets/models/`, declare in `pubspec.yaml`
- Write `MlInferenceService` and test with hardcoded inputs
- Validate scores match original sklearn model on same inputs

### Phase 3: Native VPN Layer (Days 3–4)
- Write `PacketParser.kt` with unit tests on captured raw bytes
- Write `FlowTracker.kt`, test IAT computation
- Write `NeuralVpnService.kt`, test minimal packet read loop
- Wire `MainActivity.kt` `MethodChannel` + `EventChannel`
- Test: start VPN, open browser, verify JSON events appear in Flutter debug console

### Phase 4: Core Dart Services (Day 5)
- Write `VpnBridgeService` (EventChannel stream wrapper)
- Write `HeuristicService` (flood detection)
- Write `BlacklistService` + Hive setup in `main.dart`
- Write `AclService`
- Write `PacketProcessorService` (full orchestration)
- Integration test: feed mock parsed packet → verify correct `PacketRecord` output

### Phase 5: Bloc/Cubit Layer (Day 6)
- Define all states, events: `VpnState`, `TrafficState/Event`, `DashboardState`, `BlacklistState`, `AclState`, `SettingsState`
- Implement `VpnCubit` → wire to `VpnBridgeService`
- Implement `TrafficBloc` → subscribe to `VpnBridgeService.packetStream`, process via `PacketProcessorService`
- Implement `DashboardCubit` → subscribe to `TrafficBloc.stream` and `BlacklistCubit.stream`
- Implement `BlacklistCubit` + `AclCubit` → back to `BlacklistService`/`AclService`
- Implement `SettingsCubit` → `SharedPreferences` persistence
- Set up `MultiBlocProvider` in `main.dart`
- Write `bloc_test` unit tests for each Bloc/Cubit

### Phase 6: UI — Home Screen (Days 7–8)
- Build `StatsRow` with `BlocBuilder<DashboardCubit>`
- Build `ControlBar` with `BlocBuilder<VpnCubit>` (start/stop dispatching)
- Build `TrafficRow` (status color logic, all columns)
- Build `TrafficTable` with `BlocBuilder<TrafficBloc>`
- Add `ThreatSparkline` chart driven by `TrafficBloc`

### Phase 7: UI — Supporting Screens (Day 9)
- Build `BlacklistScreen` with `BlocBuilder<BlacklistCubit>` (swipe-to-delete + FAB)
- Build `AclScreen` with `BlocBuilder<AclCubit>`
- Build `SettingsScreen` with `BlocBuilder<SettingsCubit>` (sliders → dispatch `SettingsCubit` methods)

### Phase 8: End-to-End Test & Refinement (Day 10)
- Full device test: start capture, generate traffic (ping, curl, browser)
- Verify status labels match Python app on same traffic patterns
- Test blacklist auto-add (craft repeated connections to trigger BF score)
- Test heuristic flood detection (1000+ packets/sec script)
- Performance profile: < 5ms per packet in Dart, < 1ms TFLite inference
- Fix UI jank (ensure `ListQueue` mutations never block the main thread)

### Phase 9: Polish (Day 11)
- Add `flutter_animate` pulse animation to VPN status dot
- Add `shimmer` loading skeleton while models initialise
- Add `badges` count on blacklist nav tab from `BlocBuilder<BlacklistCubit>`
- Confirmation dialogs before clear-log / clear-blacklist actions (using `BlocListener`)
- Test on Android API 21, 28, 33

---

## APPENDIX: Critical Thresholds & Constants

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const double blockThreshold  = 0.20;
  static const double warnThreshold   = 0.10;
  static const int    floodPktPerSec  = 1000;
  static const int    synFloodPerSec  = 100;
  static const int    maxLogEntries   = 200;
  static const int    sparklineHistory = 60;
  static const String methodChannel   = 'com.neuralfw/vpn_control';
  static const String eventChannel    = 'com.neuralfw/packet_stream';
  static const String blacklistBox    = 'blacklist';
  static const String aclBox          = 'acl';
  // Feature indices (must match model training order exactly)
  // BF model:  [0]=Protocol [1]=FlowIATMean [2]=TotFwdPkts [3]=PktSizeAvg
  // DoS model: [0]=Protocol [1]=FlowIATMean [2]=TotFwdPkts [3]=PktSizeAvg [4]=FlowDuration
}
```

---

## KNOWN RISKS & MITIGATIONS

| Risk | Mitigation |
|---|---|
| TFLite conversion changes model accuracy | Validate against Python sklearn on 100 test vectors before shipping |
| VpnService battery drain | Process packets in batches; Kotlin coroutines with `Dispatchers.IO`; stop when backgrounded |
| High packet volume (>500 pkt/s) causes UI lag | `TrafficBloc` uses `transformer: droppable()` or throttle; UI only rebuilds on frame tick |
| Bloc state leaks across screens | Use `BlocProvider.value` in `MultiBlocProvider` at root; never create Blocs inside `build()` |
| `DashboardCubit` stream subscription leaks | Always cancel `StreamSubscription` in `close()` override |
| Android 12+ foreground service restrictions | Declare `foregroundServiceType="specialUse"` + user-visible notification |
| iOS out of scope for PoC | Deliver Android only |
| `.pkl` ONNX conversion edge cases | Use fallback JSON decision tree reconstruction if ONNX fails |
| JWT access token expired mid-session | Dio interceptor auto-refreshes on 401 before retrying; `AuthCubit` emits `unauthenticated` if refresh also fails |
| Refresh token stolen from device | Stored in `flutter_secure_storage` (Android Keystore-backed); rotate on every use |
| Backend API unreachable (WireGuard down) | All `BlacklistCubit` / `AclCubit` calls wrapped in try/catch; emit error state and keep in-memory cache valid |
| Settings sync conflict (local vs server) | Server is source of truth; local `SharedPreferences` acts as cache, overwritten on every `/settings` GET |
| Blacklist auto-add floods backend | Debounce: batch `addAutoMl` calls, send at most one POST per unique IP per session |

---

*This plan covers every component needed to exactly replicate the Python Neural Firewall as a Flutter Android app using Bloc/Cubit state management. Total estimated code: ~2,600 lines Dart + ~600 lines Kotlin + conversion scripts. Start Phase 2 (model conversion) in parallel with Phase 3 (VPN native layer) — these are the two highest-risk components.*

---

## 12. BACKEND API PLAN

### 12.1 API Overview

All endpoints require a JWT `Authorization: Bearer <token>` header except `/auth/register` and `/auth/login`.

Base URL (inside WireGuard tunnel): `https://10.0.0.1:5000`

---

### 12.2 Authentication Endpoints

| Method | Endpoint | Body | Response | Description |
|---|---|---|---|---|
| POST | `/auth/register` | `{email, password}` | `{user}` | Create account |
| POST | `/auth/login` | `{email, password}` | `{access_token, refresh_token}` | Sign in |
| POST | `/auth/refresh` | `{refresh_token}` | `{access_token}` | Rotate access token |
| POST | `/auth/logout` | — | `204` | Invalidate refresh token |

**Token strategy:**
- Access token: short-lived (15 min), sent in `Authorization` header on every request
- Refresh token: long-lived (30 days), stored in `flutter_secure_storage`, sent only to `/auth/refresh`
- Dio interceptor automatically calls `/auth/refresh` on 401, then retries the original request

---

### 12.3 Blacklist CRUD Endpoints

| Method | Endpoint | Body | Response | Description |
|---|---|---|---|---|
| GET | `/blacklist` | — | `[{ip, reason, bf_score, dos_score, added_at}]` | Fetch all entries |
| POST | `/blacklist` | `{ip, reason, bf_score?, dos_score?}` | `{entry}` | Add entry |
| DELETE | `/blacklist/{ip}` | — | `204` | Remove single entry |
| DELETE | `/blacklist` | — | `204` | Clear all entries |

---

### 12.4 ACL CRUD Endpoints

| Method | Endpoint | Body | Response | Description |
|---|---|---|---|---|
| GET | `/acl` | — | `[{ip, notes, added_at}]` | Fetch all rules |
| POST | `/acl` | `{ip, notes?}` | `{entry}` | Add rule |
| DELETE | `/acl/{ip}` | — | `204` | Remove rule |
| DELETE | `/acl` | — | `204` | Clear all rules |

---

### 12.5 Settings Endpoints

| Method | Endpoint | Body | Response | Description |
|---|---|---|---|---|
| GET | `/settings` | — | `{block_threshold, warn_threshold, flood_detection, syn_flood_detection, flood_pkt_per_sec, syn_flood_per_sec, bf_model_enabled, dos_model_enabled, max_log_entries}` | Fetch user settings |
| PUT | `/settings` | same fields (partial OK) | `{settings}` | Update settings |

Settings are per-user and synced on login. The app reads from `SharedPreferences` for instant local access and pushes changes to `/settings` in the background.

---

### 12.6 Prediction Endpoint

| Method | Endpoint | Body | Response |
|---|---|---|---|
| POST | `/predict` | `{protocol, flow_iat_mean, tot_fwd_pkts, pkt_size_avg, flow_duration}` | `{label, bf_score, dos_score}` |

---

### 12.7 Flutter API Layer (`lib/api/`)

**`api_client.dart`** — Dio singleton with auth interceptor:

```dart
class ApiClient {
  late final Dio _dio;
  final AuthService _auth;

  ApiClient(this._auth) {
    _dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _auth.getAccessToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _auth.refreshAccessToken(_dio);
          if (refreshed) {
            // retry original request with new token
            return handler.resolve(await _dio.fetch(error.requestOptions));
          }
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
```

**`auth_api.dart`**:

```dart
class AuthApi {
  final ApiClient _client;
  AuthApi(this._client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.dio.post('/auth/login',
        data: {'email': email, 'password': password});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await _client.dio.post('/auth/register',
        data: {'email': email, 'password': password});
    return res.data as Map<String, dynamic>;
  }

  Future<String> refresh(String refreshToken) async {
    final res = await _client.dio.post('/auth/refresh',
        data: {'refresh_token': refreshToken});
    return (res.data as Map<String, dynamic>)['access_token'] as String;
  }

  Future<void> logout() => _client.dio.post('/auth/logout');
}
```

---

### 12.8 AuthCubit

```dart
// blocs/auth/auth_state.dart
enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  const AuthState({required this.status, this.errorMessage});
  @override List<Object?> get props => [status, errorMessage];
}
```

```dart
// blocs/auth/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthApi _authApi;
  final AuthService _authService;

  AuthCubit(this._authApi, this._authService)
      : super(const AuthState(status: AuthStatus.unknown)) {
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final token = await _authService.getAccessToken();
    emit(AuthState(
      status: token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    ));
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final data = await _authApi.login(email, password);
      await _authService.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      emit(const AuthState(status: AuthStatus.authenticated));
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _authApi.register(email, password);
      await login(email, password); // auto-login after register
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> logout() async {
    await _authApi.logout();
    await _authService.clearTokens();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
```

---

### 12.9 AuthService (Token Storage)

```dart
// services/auth_service.dart
class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<String?> getAccessToken()  => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey,  value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<bool> refreshAccessToken(Dio dio) async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;
    try {
      final res = await dio.post('/auth/refresh', data: {'refresh_token': refresh});
      final newToken = (res.data as Map<String, dynamic>)['access_token'] as String;
      await _storage.write(key: _accessKey, value: newToken);
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
```

---

### 12.10 App Routing with AuthCubit Guard

```dart
// app.dart — route guard based on AuthState
class NeuralFirewallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => switch (state.status) {
          AuthStatus.unknown        => const SplashScreen(),
          AuthStatus.authenticated  => const HomeScreen(),
          _                         => const LoginScreen(),
        },
      ),
    );
  }
}
```

---

### 12.11 Updated AppConstants

```dart
class AppConstants {
  // Backend
  static const String apiBaseUrl     = 'https://10.0.0.1:5000';
  // Channels
  static const String methodChannel  = 'com.neuralfw/vpn_control';
  static const String eventChannel   = 'com.neuralfw/packet_stream';
  static const String wgChannel      = 'com.neuralfw/wireguard';
  // Thresholds (local defaults — overridden by /settings response)
  static const double blockThreshold = 0.20;
  static const double warnThreshold  = 0.10;
  static const int    floodPktPerSec = 1000;
  static const int    synFloodPerSec = 100;
  static const int    maxLogEntries  = 200;
  static const int    sparklineHistory = 60;
}
```

---

## 13. WIREGUARD + HTTPS SECURE CONNECTION PLAN

### 13.1 Architecture Overview

The system uses two security layers stacked on top of each other:

| Layer | Technology | Purpose |
|---|---|---|
| Network tunnel | WireGuard | Encrypted VPN between mobile and VPS |
| API communication | HTTPS / TLS | Encrypted HTTP requests inside the tunnel |

The mobile app uses Android's `VpnService` (already implemented as `NeuralVpnService`) to capture local traffic. That captured traffic data is forwarded to a remote AI server on the VPS via a WireGuard tunnel for deep analysis. The AI server returns a verdict (Benign / Malicious) which the app uses to update its firewall rules (ACL/Blacklist).

**OPEN ARCHITECTURE DECISION — must resolve before implementing server:**

| Option | On-device TFLite | Server-side AI | Trade-off |
|---|---|---|---|
| A | Yes (current plan) | No | Works offline, limited model size |
| B | No | Yes (WireGuard plan) | Requires VPS connection, bigger/better models |
| C | Both (hybrid) | Yes | On-device for speed, server for accuracy — complex |

The current plan has both TFLite assets and a server workflow. **Choose one before building the backend.**

---

### 13.2 Network Configuration

```
Private WireGuard Network: 10.0.0.0/24
  VPS (WireGuard server + AI server): 10.0.0.1
  Mobile (WireGuard client):          10.0.0.2

AI server endpoint (inside tunnel only):
  https://10.0.0.1:5000
  NOT exposed to the public internet
```

Note: `NeuralVpnService.kt` already assigns `.addAddress("10.0.0.2", 32)` — this matches the WireGuard client IP.

---

### 13.3 WireGuard Server Setup (VPS)

```bash
# 1. Install WireGuard
sudo apt install wireguard

# 2. Generate server keys
wg genkey | tee server_private.key | wg pubkey > server_public.key

# 3. Generate mobile client keys
wg genkey | tee client_private.key | wg pubkey > client_public.key

# 4. Create /etc/wireguard/wg0.conf
[Interface]
Address    = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <server_private_key>

[Peer]
# Mobile client
PublicKey  = <client_public_key>
AllowedIPs = 10.0.0.2/32

# 5. Start and enable
sudo systemctl enable --now wg-quick@wg0
```

---

### 13.4 WireGuard Client Setup (Android / Kotlin)

**Do NOT implement WireGuard protocol manually.** Use the official `wireguard-android` library:

```kotlin
// android/app/build.gradle
dependencies {
    implementation("com.wireguard.android:tunnel:1.0.20230706")
}
```

The WireGuard tunnel configuration stored in the app (as a string asset or embedded config):

```
[Interface]
PrivateKey = <client_private_key>
Address    = 10.0.0.2/32
DNS        = 8.8.8.8

[Peer]
PublicKey    = <server_public_key>
Endpoint     = <VPS_PUBLIC_IP>:51820
AllowedIPs   = 10.0.0.1/32   # only route VPS traffic through tunnel
PersistentKeepalive = 25
```

`AllowedIPs = 10.0.0.1/32` (not `0.0.0.0/0`) — only routes AI server traffic through WireGuard, leaving normal user traffic unaffected.

---

### 13.5 Kotlin MethodChannel for WireGuard

```kotlin
// MainActivity.kt — WireGuard MethodChannel additions
private val WIREGUARD_CHANNEL = "com.neuralfw/wireguard"

// In onCreate():
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIREGUARD_CHANNEL)
    .setMethodCallHandler { call, result ->
        when (call.method) {
            "connectVPN"    -> { startWireGuardTunnel(); result.success(null) }
            "disconnectVPN" -> { stopWireGuardTunnel();  result.success(null) }
            "getVPNStatus"  -> result.success(getWireGuardStatus())
            else            -> result.notImplemented()
        }
    }
```

Flutter side (`VpnBridgeService`) calls these via `MethodChannel('com.neuralfw/wireguard')`.

---

### 13.6 HTTPS / TLS with a Private IP (Critical Detail)

Let's Encrypt does NOT issue certificates for private IPs (10.0.0.1). Use a self-signed certificate:

```bash
# On VPS — generate self-signed cert
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
  -days 365 -nodes -subj "/CN=10.0.0.1" \
  -addext "subjectAltName=IP:10.0.0.1"
```

**Android must trust this cert.** Two approaches:

**Option A — Bundle cert in app (recommended for PoC):**
Place `cert.pem` in `assets/certs/` and configure Dio/http to use it:
```dart
// In AI server HTTP client setup
final cert = await rootBundle.load('assets/certs/cert.pem');
final context = SecurityContext();
context.setTrustedCertificatesBytes(cert.buffer.asUint8List());
final client = HttpClient(context: context);
```

**Option B — network_security_config.xml (easier but less strict):**
```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="false">10.0.0.1</domain>
        <trust-anchors>
            <certificates src="@raw/server_cert"/>
        </trust-anchors>
    </domain-config>
</network-security-config>
```
Place `cert.pem` as `android/app/src/main/res/raw/server_cert.pem`.

---

### 13.7 AI Server Setup (VPS)

The AI server runs on the VPS, bound to the WireGuard private IP only:

```python
# server config — binds to WireGuard IP, not 0.0.0.0
HOST = "10.0.0.1"
PORT = 5000
# TLS cert generated in 12.6
SSL_CERT = "/etc/neural_firewall/cert.pem"
SSL_KEY  = "/etc/neural_firewall/key.pem"
```

The server receives flow feature vectors from the mobile app and returns ML inference results.

**Backend framework choice context (for framework selection):**
- Language: Python
- Task: Serve ML model inference (scikit-learn / TFLite or similar)
- Transport: HTTPS REST (JSON), private network only
- Concurrency: Multiple packets per second from one mobile client
- Deployment: Single VPS, systemd service
- Contenders: **Flask**, **FastAPI**

---

### 13.8 System Workflow (End-to-End)

```
1. User opens Flutter app
2. User taps "Connect"
3. Flutter → MethodChannel → Kotlin: connectVPN()
4. Kotlin starts WireGuard tunnel (wireguard-android library)
5. Secure WireGuard tunnel established (10.0.0.2 ↔ 10.0.0.1)
6. NeuralVpnService begins capturing device traffic via TUN interface
7. PacketParser + FlowTracker extract flow features
8. EventChannel sends JSON features to Flutter (TrafficBloc)
9. PacketProcessorService forwards features to AI server:
       POST https://10.0.0.1:5000/predict  (inside WireGuard tunnel)
       Body: { protocol, flowIatMean, totFwdPkts, pktSizeAvg, flowDuration }
10. AI server runs ML model, returns:
       { "label": "Benign" | "Malicious", "bf_score": 0.87, "dos_score": 0.12 }
11. App updates PacketStatus and emits TrafficState
12. If status == BLOCK → BlacklistCubit.addAutoMl(srcIp)
13. UI rebuilds via BlocBuilder
```

---

### 13.9 New Dart Service — AI Server Client

```dart
// lib/services/ai_server_service.dart
class AiServerService {
  static const _baseUrl = 'https://10.0.0.1:5000';
  late final Dio _dio;

  AiServerService() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    // attach self-signed cert trust (see 12.6)
  }

  Future<DetectionResult> predict(FlowFeatures features) async {
    final response = await _dio.post('/predict', data: features.toJson());
    return DetectionResult.fromJson(response.data as Map<String, dynamic>);
  }
}
```

`AiServerService` replaces or supplements `MlInferenceService` depending on the architecture decision in 12.1.

---

### 13.10 Updated Project Structure Additions

```
android/app/src/main/
  kotlin/com/neuralfw/
    wireguard/
      WireGuardManager.kt     ← wraps wireguard-android library
  res/
    raw/
      server_cert.pem         ← self-signed TLS cert (Option B)
    xml/
      network_security_config.xml  ← already exists, update for 10.0.0.1

assets/
  certs/
    server_cert.pem           ← self-signed TLS cert (Option A)
  wireguard/
    client.conf               ← WireGuard client config (keys embedded at build time)

lib/
  services/
    ai_server_service.dart    ← HTTPS client to remote AI server
```

---

### 13.11 Security Summary

| Component | Technology | What it protects |
|---|---|---|
| Network tunnel | WireGuard (UDP 51820) | All traffic between mobile and VPS is encrypted |
| API layer | HTTPS / TLS 1.3 | API payloads encrypted, server authenticated by cert |
| Server isolation | Bind to 10.0.0.1 only | AI server unreachable without WireGuard tunnel |
| Android cert trust | network_security_config / custom HttpClient | Prevents MITM against self-signed cert |

---

### 13.12 Known Issues & Mitigations (WireGuard / HTTPS)

| Risk | Mitigation |
|---|---|
| Private key exposure in APK | Store WireGuard client private key in Android Keystore, not as plain asset |
| Self-signed cert MITM | Pin the cert SHA-256 fingerprint in the app; rotate on expiry |
| WireGuard tunnel drops during background | Use `PersistentKeepalive = 25` in peer config |
| AI server port exposed if WireGuard misconfigured | Use iptables on VPS to block port 5000 from non-WireGuard interfaces |
| Architecture conflict (TFLite vs server inference) | Resolve 12.1 decision first; remove unused TFLite assets if going server-only |
