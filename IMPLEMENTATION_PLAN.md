# Neural Firewall — Full Implementation Plan

> **Last Updated:** 2026-06-07  
> **Covers:** Backend DB + API, Flutter frontend, Kotlin VPN changes  
> **Architecture:** Clean Architecture (Domain / Data / Presentation), BLoC/Cubit, Dio, GetIt

---

## Table of Contents

1. [Database Changes](#1-database-changes)
2. [Backend API Endpoints](#2-backend-api-endpoints)
3. [Kotlin VPN Changes](#3-kotlin-vpn-changes)
4. [Flutter — Entities to Update](#4-flutter--entities-to-update)
5. [Flutter — Features: Local → API Migration](#5-flutter--features-local--api-migration)
6. [Flutter — Traffic: 5-Model AI Competition](#6-flutter--traffic-5-model-ai-competition)
7. [Flutter — New Features](#7-flutter--new-features)
8. [Flutter — Navigation Update](#8-flutter--navigation-update)
9. [Implementation Order](#9-implementation-order)
10. [AI Firewall Assistant (Chatbot)](#10-ai-firewall-assistant-chatbot)

---

## 1. Database Changes

### 1.1 Modify `users` Table

Add one column:

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `username` | String(100) | Not Null, Unique | Display name |

Updated `POST /auth/register` and `PUT /users/me` must handle this field.

---

### 1.3 New Table: `hardware_metrics`

Periodic device health snapshots sent every 2 minutes from the app.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | Integer | Primary Key | |
| `user_id` | Integer | FK → users.id | |
| `cpu_usage` | Float | Not Null | CPU usage % (0–100) |
| `ram_used_mb` | Integer | Not Null | Used RAM in MB |
| `ram_total_mb` | Integer | Not Null | Total RAM in MB |
| `battery_level` | Float | Nullable | Battery % (0–100) |
| `recorded_at` | DateTime | Default: UTC Now | When snapshot was taken |

**Indexes:** `user_id`, `recorded_at`

---

### 1.4 New Table: `firewall_logs`

One row per packet that has been evaluated by the AI model pipeline.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | Integer | Primary Key | |
| `user_id` | Integer | FK → users.id | |
| `src_ip` | String(45) | Nullable | Source IP address |
| `src_port` | Integer | Nullable | Source port |
| `dst_port` | Integer | Nullable | Destination port |
| `protocol` | Integer | Nullable | TCP=6, UDP=17, ICMP=1 |
| `size_bytes` | Integer | Nullable | Packet size in bytes |
| `flow_iat_mean` | Float | Nullable | Inter-arrival time mean (ms) |
| `tot_fwd_pkts` | Integer | Nullable | Total forward packets in flow |
| `pkt_size_avg` | Float | Nullable | Average packet size |
| `flow_duration` | Float | Nullable | Flow duration in seconds |
| `selected_model` | String(100) | Nullable | Name of the model with highest score |
| `selected_score` | Float | Nullable | Winning model's score (0–1) |
| `all_model_scores` | Text/JSON | Nullable | `{"BF_v1":0.12,"DoS_Hulk":0.91,...}` |
| `action` | String(20) | Not Null | `blocked` / `warned` / `allowed` |
| `threat_type` | String(50) | Nullable | `brute_force` / `dos` / `normal` / etc. |
| `service_name` | String(100) | Nullable | Destination service from DNS: `YouTube`, `WhatsApp`, `""` |
| `app_name` | String(100) | Nullable | Source app on device: `Chrome`, `WhatsApp`, `System` |
| `app_package` | String(200) | Nullable | Package name: `com.android.chrome` |
| `is_system` | Boolean | Default: False | True if Android UID < 10000 |
| `created_at` | DateTime | Default: UTC Now | When log entry was created |

**Indexes:** `user_id`, `created_at`, `action`, `service_name`, `app_name`

---

## 2. Backend API Endpoints

### 2.1 Auth

| Method | Endpoint | Request Body | Notes |
|--------|----------|-------------|-------|
| POST | `/auth/register` | `{ email, username, password }` | Returns user + tokens |
| POST | `/auth/login` | `{ email, password }` | Returns access + refresh tokens |
| POST | `/auth/refresh` | `{ refresh_token }` | Rotates JWT |
| PUT | `/users/me` | `{ username?, new_password?, current_password }` | `current_password` required when changing password |

---

### 2.2 Blacklist

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/blacklist` | Returns entries with `bf_score`, `dos_score`, `reason` |
| POST | `/blacklist` | `{ ip, reason?, notes? }` — manual add |
| DELETE | `/blacklist/{id}` | Remove entry |

Backend also auto-inserts when a firewall log with `action = "blocked"` is posted (if IP not already present).

---

### 2.3 ACL

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/acl` | Returns whitelisted IPs |
| POST | `/acl` | `{ ip, notes? }` |
| DELETE | `/acl/{id}` | |

---

### 2.4 Settings

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/settings` | Returns full `user_settings` row |
| PUT | `/settings` | Update any combination of fields |

Fields: `block_threshold`, `warn_threshold`, `flood_detection`, `syn_flood_detection`, `flood_pkt_per_sec`, `syn_flood_per_sec`, `bf_model_enabled`, `dos_model_enabled`, `max_log_entries`

---

### 2.5 Firewall Logs

> **Write path (log submission) has been redesigned as a secure WebSocket.** Full detail in **[FIREWALL_LOGS_WS_PLAN.md](FIREWALL_LOGS_WS_PLAN.md)**.

| Method / Protocol | Endpoint | Notes |
|--------|----------|-------|
| `WSS` | `/ws/logs?token=<jwt>` | **Write path** — Flutter streams log batches; server sends ACK + pushes `blacklist_update` / `settings_update` back |
| `GET` | `/firewall-logs` | **Read path** — paginated query; params: `action`, `threat_type`, `service_name`, `app_name`, `from_date`, `to_date`, `limit`, `offset` |

---

### 2.6 Hardware Metrics

| Method | Endpoint | Notes |
|--------|----------|-------|
| POST | `/hardware-metrics` | `{ cpu_usage, ram_used_mb, ram_total_mb, battery_level }` |
| GET | `/hardware-metrics` | Returns history for admin dashboard charts; supports `from_date`, `to_date` |

---

### 2.7 Unknown Events

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/unknown-events` | Admin review list; filter by `status` |
| POST | `/unknown-events` | App posts ambiguous packets (score between warn and block threshold) |
| PATCH | `/unknown-events/{id}` | Admin labels event → auto-creates `training_samples` row |

---

### 2.8 Model Versions (Admin)

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/model-versions` | Lists all versions with `accuracy`, `samples`, `is_active` |
| PATCH | `/model-versions/{id}/activate` | Sets model as active (deactivates previous) |

---

## 3. Kotlin VPN Changes

### 3.1 `NeuralVpnService.kt` — UID-Based App Identification

Add two private methods to get the source app for each packet:

```kotlin
// Reads /proc/net/tcp or /proc/net/udp to find the UID that owns srcPort.
// Returns -1 if not found or on any error.
private fun getUidForPort(srcPort: Int, isTcp: Boolean): Int {
    val path = if (isTcp) "/proc/net/tcp" else "/proc/net/udp"
    return try {
        java.io.File(path).useLines { lines ->
            lines.drop(1).firstOrNull { line ->
                val parts = line.trim().split("\\s+".toRegex())
                parts.size > 7 &&
                    parts[1].split(":").getOrNull(1)?.toInt(16) == srcPort
            }?.trim()?.split("\\s+".toRegex())?.getOrNull(7)?.toInt() ?: -1
        }
    } catch (_: Exception) { -1 }
}

// Maps UID → (appLabel, packageName).
// UIDs 0–9999 are Android system processes → labelled "System".
private fun appNameForUid(uid: Int): Pair<String, String> {
    if (uid < 0)     return Pair("", "")
    if (uid < 10000) return Pair("System", "android.system")
    return try {
        val pkg = packageManager.getNameForUid(uid) ?: return Pair("", "")
        val label = packageManager.getApplicationLabel(
            packageManager.getApplicationInfo(pkg, 0)
        ).toString()
        Pair(label, pkg)
    } catch (_: Exception) { Pair("", "") }
}
```

Update the enriched map in `readPacketLoop()` (currently line 282–297):

```kotlin
val uid = getUidForPort(parsed.srcPort, parsed.protocol == 6)
val (appName, appPkg) = appNameForUid(uid)

val enriched = mapOf(
    // ... all existing fields unchanged ...
    "label"      to dnsCache.serviceLabel(parsed.dstIp), // already present
    "appName"    to appName,    // NEW — e.g. "WhatsApp", "Chrome", "System"
    "appPackage" to appPkg,     // NEW — e.g. "com.whatsapp"
    "isSystem"   to (uid in 0..9999) // NEW
)
```

Apply the same addition to the inbound event maps inside `handleTcp()` relay coroutine and `handleUdp()`.

### 3.2 No Changes Needed to `DnsCache.kt`

`serviceLabel()` already returns friendly names for 70+ services. The `"label"` field is already emitted per packet. No changes needed.

---

## 4. Flutter — Entities to Update

### 4.1 `DetectionResult`

**File:** `lib/features/traffic/domain/entities/detection_result.dart`

Replace hardcoded `bruteForceScore` / `dosScore` with dynamic map:

```dart
class DetectionResult {
  final String flowId;
  final Map<String, double> modelScores; // {"BF_v1": 0.12, "DoS_Hulk": 0.91}
  final String selectedModel;            // model with highest score
  final double selectedScore;            // that model's score
  final String action;                   // "blocked" / "warned" / "allowed"
  final String threatType;               // "brute_force" / "dos" / "normal"
  final DateTime timestamp;
  final List<String>? flaggedReasons;
}
```

### 4.2 `PacketRecord`

**File:** `lib/features/traffic/domain/entities/packet_record.dart`

Add fields for the new VPN-emitted data:

```dart
// Add to existing fields:
final String serviceName;  // from "label" key — e.g. "YouTube"
final String appName;      // from "appName" key — e.g. "Chrome"
final String appPackage;   // from "appPackage" key
final bool isSystem;       // from "isSystem" key
```

### 4.3 `BlacklistEntry`

**File:** `lib/features/blacklist/domain/entities/blacklist_entry.dart`

Add fields to match backend response:

```dart
// Add to existing fields:
final double? bfScore;
final double? dosScore;
final String reason;  // "manual" / "brute_force" / "dos"
```

### 4.4 `AclEntry`

**File:** `lib/features/acl/domain/entities/acl_entry.dart`

Already matches schema. No changes needed.

---

## 5. Flutter — Features: Local → API Migration

### 5.1 Auth

**New file:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`

- `signIn(email, password)` → `POST /auth/login`
- `signUp(email, username, password)` → `POST /auth/register`
- `refreshToken(token)` → `POST /auth/refresh`
- `updateProfile({username, newPassword, currentPassword})` → `PUT /users/me`

Update `auth_repository_impl.dart` to delegate to remote datasource.

**Screen changes (`sign_up_screen.dart`):**
- Add `username` text field between email and password

**Screen changes (`settings_screen.dart`):**
- Add "Profile" card with:
  - "Edit Username" dialog → calls `updateProfile(username: ...)`
  - "Change Password" dialog (requires current password) → calls `updateProfile(newPassword: ..., currentPassword: ...)`

---

### 5.2 Blacklist

**New file:** `lib/features/blacklist/data/datasources/blacklist_remote_datasource.dart`

- `getBlacklist()` → `GET /blacklist`
- `addToBlacklist(ip, reason, notes)` → `POST /blacklist`
- `removeFromBlacklist(id)` → `DELETE /blacklist/{id}`

Update `blacklist_repository_impl.dart` to use remote datasource.  
Update `blacklist_screen.dart` tile to show `bf_score` and `dos_score` chips.

---

### 5.3 ACL

**New file:** `lib/features/acl/data/datasources/acl_remote_datasource.dart`

- `getAcl()` → `GET /acl`
- `addToAcl(ip, notes)` → `POST /acl`
- `removeFromAcl(id)` → `DELETE /acl/{id}`

Update `acl_repository_impl.dart` to use remote datasource.

---

### 5.4 Settings

**New file:** `lib/features/settings/data/datasources/settings_remote_datasource.dart`

- `getSettings()` → `GET /settings`
- `updateSettings(settings)` → `PUT /settings`

Load settings from backend on app start. Save on any user change.

---

## 6. Flutter — Traffic: 5-Model AI Competition

### 6.1 `ai_models.dart`

**File:** `lib/core/constants/ai_models.dart`

Add the remaining 3 model paths. Each model needs its own `scaler_params.json`:

```dart
class AiModels {
  // Model 1 — already exists
  static const String bruteForceModel = 'assets/ai_models/bruteforce/bruteforce_detection_mobile.tflite';
  static const String bruteForceScaler = 'assets/ai_models/bruteforce/scaler_params.json';

  // Model 2 — already exists
  static const String dosHulkModel = 'assets/ai_models/dos_specialist_hulk_mobile.tflite';
  static const String dosHulkScaler = 'assets/ai_models/dos_hulk/scaler_params.json';

  // Models 3–5 — add paths for your remaining models
  static const String model3 = 'assets/ai_models/model3/model3_mobile.tflite';
  static const String model3Scaler = 'assets/ai_models/model3/scaler_params.json';

  static const String model4 = 'assets/ai_models/model4/model4_mobile.tflite';
  static const String model4Scaler = 'assets/ai_models/model4/scaler_params.json';

  static const String model5 = 'assets/ai_models/model5/model5_mobile.tflite';
  static const String model5Scaler = 'assets/ai_models/model5/scaler_params.json';
}
```

### 6.2 `MlDataSource` Refactor

**File:** `lib/features/traffic/data/datasources/ml_datasource.dart`

Replace single-model approach with multi-model pipeline:

```
init():
  Load all 5 TFLite interpreters.
  Load each model's own scaler_params.json.

predictAll(Map<String, dynamic> packet) → Map<String, double>:
  For each of the 5 models:
    - Scale features using that model's own mean/std
    - Run interpreter
    - Collect score
  Return {"BF_v1": 0.12, "DoS_Hulk": 0.91, "Model3": 0.07, ...}

dispose():
  Close all 5 interpreters.
```

### 6.3 Competition Logic (in use case or bloc)

After `predictAll()` returns scores, apply the decision logic:

```
selectedModel = key with max score
selectedScore = max score

if selectedScore > block_threshold  → action = "blocked"
    → also call AddToBlacklistUseCase(srcIp, reason: threat_type)
else if selectedScore > warn_threshold → action = "warned"
else → action = "allowed"

if score is between warn_threshold and block_threshold:
    → also POST /unknown-events (ambiguous packet for admin review)

→ POST /firewall-logs with full result
```

All thresholds come from `user_settings` loaded at startup via Settings remote datasource.

---

## 7. Flutter — New Features

### 7.1 Firewall Logs Feature

```
lib/features/firewall_logs/
├── domain/
│   ├── entities/
│   │   └── firewall_log.dart
│   ├── repositories/
│   │   └── firewall_log_repository.dart
│   └── usecases/
│       ├── get_firewall_logs_usecase.dart
│       └── post_firewall_log_usecase.dart
├── data/
│   ├── datasources/
│   │   └── firewall_log_remote_datasource.dart
│   └── repositories/
│       └── firewall_log_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── firewall_logs_cubit.dart
    │   └── firewall_logs_state.dart
    ├── screens/
    │   └── firewall_logs_screen.dart
    └── widgets/
        ├── log_tile.dart           ← IP · service · app name · model · score · action chip
        └── threat_filter_bar.dart  ← filter by action / service / app / date
```

**`firewall_log.dart` entity:**

```dart
class FirewallLog {
  final int id;
  final String srcIp;
  final int srcPort;
  final int dstPort;
  final int protocol;
  final int sizeBytes;
  final String selectedModel;
  final double selectedScore;
  final Map<String, double> allModelScores;
  final String action;           // "blocked" / "warned" / "allowed"
  final String threatType;
  final String serviceName;      // "YouTube", "WhatsApp", ""
  final String appName;          // "Chrome", "WhatsApp", "System"
  final String appPackage;
  final bool isSystem;
  final DateTime createdAt;
}
```

---

### 7.2 Hardware Metrics Feature

```
lib/features/hardware_metrics/
├── domain/
│   ├── entities/
│   │   └── hardware_snapshot.dart
│   ├── repositories/
│   │   └── hardware_metrics_repository.dart
│   └── usecases/
│       ├── collect_snapshot_usecase.dart   ← reads device sensors via platform channel
│       └── sync_snapshot_usecase.dart      ← POSTs to backend
├── data/
│   ├── datasources/
│   │   ├── hardware_local_datasource.dart  ← platform channel to Kotlin
│   │   └── hardware_remote_datasource.dart ← POST /hardware-metrics
│   └── repositories/
│       └── hardware_metrics_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── hardware_metrics_cubit.dart
    │   └── hardware_metrics_state.dart
    └── widgets/
        └── hardware_stats_card.dart   ← used in dashboard screen
```

**`hardware_snapshot.dart` entity:**

```dart
class HardwareSnapshot {
  final double cpuUsage;     // % 0–100
  final int ramUsedMb;
  final int ramTotalMb;
  final double? batteryLevel; // % 0–100, nullable
  final DateTime recordedAt;
}
```

**Kotlin side — new method channel handler in `MainActivity.kt`:**

```kotlin
"getHardwareSnapshot" -> {
    val actManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
    val memInfo = ActivityManager.MemoryInfo()
    actManager.getMemoryInfo(memInfo)

    // CPU from /proc/stat — read two snapshots with a short delay for delta
    val battery = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val level = battery?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
    val scale = battery?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
    val batteryPct = if (level >= 0 && scale > 0) level * 100f / scale else null

    result.success(mapOf(
        "ramUsedMb"    to ((memInfo.totalMem - memInfo.availMem) / 1_048_576L).toInt(),
        "ramTotalMb"   to (memInfo.totalMem / 1_048_576L).toInt(),
        "batteryLevel" to batteryPct,
        "cpuUsage"     to readCpuUsage() // helper reading /proc/stat
    ))
}
```

**Background collection:** Use `flutter_foreground_task` (already in `pubspec.yaml`) to run `SyncSnapshotUseCase` every 2 minutes. Register the task in `main.dart` after VPN initialization.

---

### 7.3 Dashboard Screen

**New file:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

The `DashboardCubit` already exists. Wire the screen to it plus `HardwareMetricsCubit` and `FirewallLogsCubit`.

**Layout:**

```
┌─────────────────────────────────────┐
│  Hardware Stats Card                │
│  [CPU %]  [RAM bar]  [Battery %]    │
├─────────────────────────────────────┤
│  Threats (last 24h) — fl_chart      │
│  Line chart: blocked / warned       │
├─────────────────────────────────────┤
│  Recent Blocked IPs (last 5)        │
│  [IP]  [Service]  [App]  [Model]    │
├─────────────────────────────────────┤
│  Active AI Models                   │
│  [BF_v1 ✓]  [DoS_Hulk ✓]  ...     │
└─────────────────────────────────────┘
```

Data sources:
- Hardware card → `GET /hardware-metrics` (latest entry)
- Threat chart → `GET /firewall-logs?from_date=24h_ago`
- Recent blocked → `GET /firewall-logs?action=blocked&limit=5`
- Active models → `GET /model-versions?is_active=true`

---

## 8. Flutter — Navigation Update

Replace the current 4-tab `_AppShell` with 6 tabs:

| # | Tab Label | Icon | Screen | Primary Data Source |
|---|-----------|------|--------|---------------------|
| 1 | Dashboard | `bar_chart` | `DashboardScreen` | hardware_metrics + firewall_logs |
| 2 | Live Traffic | `wifi` | `HomeScreen` | VPN EventChannel + local ML |
| 3 | Firewall Logs | `shield` | `FirewallLogsScreen` | `GET /firewall-logs` |
| 4 | Blacklist | `block` | `BlacklistScreen` | `GET /blacklist` |
| 5 | Assistant | `chat_bubble` | `ChatScreen` | `POST /chat/stream` (SSE) |
| 6 | Settings | `settings` | `SettingsScreen` | user_settings + profile |

> **ACL** moves inside `SettingsScreen` as a sub-page ("Whitelist" section) to keep the nav bar clean.  
> **Assistant** tab shows an unread-dot badge when the backend greeting digest contains new insights.

---

## 9. Implementation Order

Work in this order to minimize blocked dependencies:

| Step | What | Why first |
|------|------|-----------|
| 1 | Backend DB migrations | Everything else depends on the schema |
| 2 | Backend auth endpoints (with username) | JWT needed for all other API calls |
| 3 | Flutter auth remote datasource | Unblocks all other API features |
| 4 | Backend settings endpoint | Thresholds needed for ML decision logic |
| 5 | Flutter settings remote datasource | Loads thresholds before ML runs |
| 6 | Backend blacklist + ACL endpoints | |
| 7 | Flutter blacklist + ACL remote datasources | |
| 8 | Kotlin UID lookup addition to VPN service | Enriches packet data before ML |
| 9 | Flutter ML refactor (5 models + predictAll) | Core IDS logic |
| 10 | Backend WebSocket endpoint + persistence service (`FIREWALL_LOGS_WS_PLAN.md` steps 2–6) | Receives ML results via WSS |
| 11 | Flutter `WsConnectionService` + `PendingLogQueue` + screen (`FIREWALL_LOGS_WS_PLAN.md` steps 8–14) | Streams logs; offline resilience |
| 12 | Backend hardware_metrics endpoint | |
| 13 | Flutter hardware metrics service + Kotlin channel | Background collection |
| 14 | Flutter dashboard screen | Combines all data sources |
| 15 | Backend unknown_events + model_versions | Admin features, non-blocking |
| 16 | DB migrations: `chat_sessions`, `chat_messages` | Chatbot persistence |
| 17 | Backend: Claude API integration + context builder | Core LLM brain before exposing endpoint |
| 18 | Backend: `POST /chat/stream` SSE endpoint + session CRUD | Exposes chatbot to Flutter |
| 19 | Flutter: `chatbot_remote_datasource.dart` (Dio SSE stream) | Wire SSE chunks to domain |
| 20 | Flutter: `ChatCubit` + streaming state | Drives UI updates chunk by chunk |
| 21 | Flutter: `ChatScreen` + all widgets | Full chat UI |
| 22 | Flutter: Update nav shell to 6 tabs | Surface new feature |

---

## Summary of All New Files

### Backend
- DB migration: add `username` to `users`
- DB migration: create `hardware_metrics`
- DB migration: create `firewall_logs`
- Endpoints: `PUT /users/me`, `POST/GET /hardware-metrics`, `POST/GET /firewall-logs`

### Kotlin
- `NeuralVpnService.kt` — add `getUidForPort()`, `appNameForUid()`, update enriched map

### Flutter — New Files
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/blacklist/data/datasources/blacklist_remote_datasource.dart`
- `lib/features/acl/data/datasources/acl_remote_datasource.dart`
- `lib/features/settings/data/datasources/settings_remote_datasource.dart`
- `lib/features/firewall_logs/` — full feature folder (6 files)
- `lib/features/hardware_metrics/` — full feature folder (7 files)
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

### Flutter — Modified Files
- `lib/core/constants/ai_models.dart` — add 3 model paths
- `lib/features/traffic/data/datasources/ml_datasource.dart` — 5-model refactor
- `lib/features/traffic/domain/entities/detection_result.dart` — dynamic score map
- `lib/features/traffic/domain/entities/packet_record.dart` — add serviceName, appName, appPackage, isSystem
- `lib/features/blacklist/domain/entities/blacklist_entry.dart` — add bfScore, dosScore, reason
- `lib/features/auth/presentation/screens/sign_up_screen.dart` — add username field
- `lib/features/settings/presentation/screens/settings_screen.dart` — profile edit
- `lib/app.dart` — update navigation to 6 tabs (add Assistant)
- `lib/main.dart` — register hardware metrics background task, inject new cubits

---

## 10. AI Firewall Assistant (Chatbot)

> Full detail has been extracted to **[CHATBOT_IMPLEMENTATION_PLAN.md](CHATBOT_IMPLEMENTATION_PLAN.md)**.

**Summary:** A conversational assistant grounded in the user's own firewall logs, blacklist, and hardware metrics. Responses are streamed via SSE (`POST /chat/stream`). Adds two DB tables (`chat_sessions`, `chat_messages`), a Claude API context builder on the backend, and a `lib/features/chatbot/` Clean-Architecture feature on Flutter with a Dio-stream SSE client and a streaming bubble UI.

**Implementation steps:** see steps 16–22 in [Section 9](#9-implementation-order).
