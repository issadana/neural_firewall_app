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
  hive_flutter: ^1.1.0              # Fast local NoSQL for blacklist/logs
  hive: ^2.2.3
  shared_preferences: ^2.2.2        # Simple key-value (settings, thresholds)

  # ── Networking / Utilities ────────────────────────────────────────
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
  hive_generator: ^2.0.1
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
│   ├── main.dart                                ← App entry, Hive init, BlocProviders
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── hive_boxes.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   └── utils/
│   │       ├── protocol_helper.dart
│   │       └── format_utils.dart
│   │
│   ├── models/
│   │   ├── packet_record.dart                   ← Freezed: live table row
│   │   ├── packet_record.freezed.dart
│   │   ├── flow_features.dart
│   │   ├── blacklist_entry.dart                 ← Hive model
│   │   ├── blacklist_entry.g.dart
│   │   ├── acl_entry.dart
│   │   ├── detection_result.dart
│   │   └── dashboard_stats.dart
│   │
│   ├── services/
│   │   ├── vpn_bridge_service.dart
│   │   ├── ml_inference_service.dart
│   │   ├── blacklist_service.dart
│   │   ├── acl_service.dart
│   │   ├── heuristic_service.dart
│   │   └── packet_processor_service.dart
│   │
│   ├── blocs/                                   ← Replaces providers/
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
│   │   │   ├── blacklist_cubit.dart             ← CRUD + Hive
│   │   │   └── blacklist_state.dart
│   │   ├── acl/
│   │   │   ├── acl_cubit.dart
│   │   │   └── acl_state.dart
│   │   └── settings/
│   │       ├── settings_cubit.dart              ← SharedPreferences persistence
│   │       └── settings_state.dart
│   │
│   ├── screens/
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
class BlacklistCubit extends Cubit<BlacklistState> {
  final BlacklistService _service;

  BlacklistCubit(this._service) : super(const BlacklistState(entries: []));

  Future<void> load() async {
    final entries = await _service.getAll();
    emit(BlacklistState(entries: entries));
  }

  Future<void> addAutoMl(String ip, {required double bfScore, required double dosScore}) async {
    await _service.add(ip, BlacklistReason.autoMl, bfScore: bfScore, dosScore: dosScore);
    await load();
  }

  Future<void> addManual(String ip) async {
    await _service.add(ip, BlacklistReason.manual);
    await load();
  }

  Future<void> remove(String ip) async {
    await _service.remove(ip);
    await load();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    emit(const BlacklistState(entries: []));
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
  await Hive.initFlutter();
  Hive.registerAdapter(BlacklistEntryAdapter());
  await Hive.openBox<BlacklistEntry>(AppConstants.blacklistBox);
  await Hive.openBox<AclEntry>(AppConstants.aclBox);

  final prefs = await SharedPreferences.getInstance();
  final mlService = MlInferenceService();
  await mlService.init();

  final blacklistService = BlacklistService();
  final aclService = AclService();
  final heuristicService = HeuristicService();
  final vpnBridgeService = VpnBridgeService();

  final blacklistCubit = BlacklistCubit(blacklistService)..load();
  final aclCubit = AclCubit(aclService)..load();
  final settingsCubit = SettingsCubit(prefs);

  final packetProcessor = PacketProcessorService(
    blacklist: blacklistService,
    acl: aclService,
    heuristics: heuristicService,
    ml: mlService,
    blockThreshold: settingsCubit.state.blockThreshold,
    warnThreshold: settingsCubit.state.warnThreshold,
  );

  final trafficBloc = TrafficBloc(vpnBridgeService, packetProcessor);
  final vpnCubit = VpnCubit(vpnBridgeService);
  final dashboardCubit = DashboardCubit(
    trafficBloc: trafficBloc,
    blacklistCubit: blacklistCubit,
  );

  runApp(
    MultiBlocProvider(
      providers: [
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
- `MlInferenceService` — TFLite dual-model inference
- `BlacklistService` — Hive CRUD + in-memory `Set<String>`
- `AclService` — Pre-blocked IP management
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
| iOS out of scope for PoC | Add `// TODO: iOS NetworkExtension stub`; deliver Android only |
| `.pkl` ONNX conversion edge cases | Use fallback JSON decision tree reconstruction if ONNX fails |

---

*This plan covers every component needed to exactly replicate the Python Neural Firewall as a Flutter Android app using Bloc/Cubit state management. Total estimated code: ~2,600 lines Dart + ~600 lines Kotlin + conversion scripts. Start Phase 2 (model conversion) in parallel with Phase 3 (VPN native layer) — these are the two highest-risk components.*
