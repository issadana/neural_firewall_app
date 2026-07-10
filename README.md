<div align="center">

# Sentri — Neural Firewall

**AI-powered, on-device Network Intrusion Detection & Prevention System for Android**

Sentri is not a security dashboard — it _is_ the firewall. It captures every packet leaving and
entering the device through an Android VPN tunnel, scores each network flow with five specialised
TensorFlow Lite models running **entirely on-device**, and blocks malicious sources at the network
level in real time — then streams the results to a backend for long-term history and cross-device sync.

Built with Flutter (Dart) + a native Kotlin Android `VpnService`, on a Clean Architecture / BLoC foundation.

</div>

---

## Table of Contents

- [Features](#features)
- [Architecture at a Glance](#architecture-at-a-glance)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Detailed Installation](#detailed-installation)
- [Configuration](#configuration)
- [Building for Release](#building-for-release)
- [Project Structure](#project-structure)
- [Detection Models](#detection-models)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)

---

## Features

- **True on-device firewall** — routes all traffic through a virtual TUN interface (`VpnService`), inspects every IPv4 packet, and enforces blocking at the network layer.
- **On-device ML detection** — five TensorFlow Lite models (Brute Force, DoS, HULK, LOIC, HOIC) score CIC-IDS-style flow features locally; traffic never leaves the phone for classification.
- **Real-time enforcement** — malicious sources are auto-blocked, in-flight TCP connections are torn down, and the block list survives process death (`START_STICKY` + disk persistence).
- **Never breaks connectivity** — a userspace TCP/UDP proxy relays clean traffic to the internet _before_ AI runs, so detection never adds latency.
- **Offline-first** — traffic history, blacklist, and settings all persist locally; the backend is a best-effort mirror.
- **Nova AI assistant** — a streaming conversational assistant that answers natural-language questions about your own traffic.
- **Live dashboard & analytics** — session stats, threat sparkline, verdict breakdown, top source IPs, protocol mix, and hardware telemetry (CPU/RAM/battery).
- **Light & dark themes**, fully responsive, built on a centralised design-token system.

## Architecture at a Glance

```
Device apps → TUN interface → Native read loop → (fast path) → real Internet
                                     │
                                     └ (AI path, async) → EventChannel → TrafficBloc
                                                              → TFLite models → verdict
                                                              → auto-block (MethodChannel) + WebSocket → backend
```

- **Native Kotlin layer** (`NeuralVpnService` + helpers) — owns the TUN interface, parses packets, relays TCP/UDP, computes flow features, attributes flows to apps, resolves DNS names, and enforces IP blocking.
- **Dart layer** (Clean Architecture + BLoC) — receives packet metadata, runs the ML models, applies thresholds, auto-blocks, updates the UI, and streams events to the backend.

Each feature is a vertical slice with strict `presentation → domain → data` layering. See [MOBILE_REPORT.md](MOBILE_REPORT.md) for a full architectural deep-dive.

---

## Requirements

| Tool                      | Version                                                                            |
| ------------------------- | ---------------------------------------------------------------------------------- |
| Flutter SDK               | 3.41.0 or newer (Dart SDK `^3.11.0`)                                               |
| Android SDK               | `minSdk 26` (Android 8.0) or higher — API 29+ recommended for full app-attribution |
| JDK                       | 17 (bundled with recent Android Studio)                                            |
| A physical Android device | **Required** — the VPN packet-capture engine does not work on emulators            |

> ⚠️ **Android only.** The `ios/`, `macos/`, `windows/`, `linux/`, and `web/` folders are scaffolding from `flutter create`. The firewall engine is Android-specific (`VpnService`), so the app is only functional on Android.

Verify your toolchain:

```bash
flutter doctor
```

---

## Quick Start

```bash
# 1. Clone
git clone <your-repo-url> neural_firewall_app
cd neural_firewall_app

# 2. Install dependencies
flutter pub get

# 3. Generate code (Freezed models, injectable DI, JSON serializers)
dart run build_runner build --delete-conflicting-outputs

# 4. Connect a physical Android device (USB debugging on), then run
flutter run
```

On first launch the app asks you to sign in / register, then requests the **VPN permission**. Grant it, then toggle protection **on** from the Home screen.

---

## Detailed Installation

### 1. Install Flutter

Follow the official guide: <https://docs.flutter.dev/get-started/install>. Confirm with `flutter --version` (expect 3.41.0+).

### 2. Fetch dependencies

```bash
flutter pub get
```

### 3. Run code generation

This project uses `freezed`, `json_serializable`, and `injectable`, which require generated files (`*.freezed.dart`, `*.g.dart`, `injection.config.dart`). **The app will not compile without them.**

```bash
# One-off build
dart run build_runner build --delete-conflicting-outputs

# Or, watch mode while developing
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Connect a physical device

- Enable **Developer Options** and **USB debugging** on the phone.
- Connect via USB and confirm it appears:

```bash
flutter devices
```

### 5. Run

```bash
flutter run
```

---

## Configuration

### Backend endpoint

The backend base URL is defined in **[lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart)**:

```dart
static const String baseUrl = 'https://api.sentri-security.cloud/';
```

- **Production:** the default deployed backend (HTTPS, TLS enforced).
- **Local development:** replace it with the LAN IP of your dev machine running the backend, e.g. `https://192.168.10.92:8000/`. The device must be able to reach that IP. In `kDebugMode`, a self-signed certificate is accepted automatically (`badCertificateCallback` in `DioConsumer` and the WebSocket service), so a local TLS dev server works without extra setup.

The firewall-log WebSocket URL (`wss://.../ws/logs?token=`) is derived from `baseUrl` automatically.

> **Note:** All runtime configuration lives in code (`ApiConstants` / `AppConstants`), not in a `.env` file. There is no environment-file loader wired up.

### Tunable defaults

Detection thresholds and pipeline limits live in **[lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)** (block/warn thresholds, max traffic entries, flood limits, TUN address). Most of these are also adjustable at runtime from the in-app **Settings** screen.

---

## Building for Release

Generate a signed release build (configure signing in `android/app/build.gradle.kts` and `android/key.properties` first):

```bash
# APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

Regenerate the launcher icon / splash screen if you change branding assets:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Project Structure

```
lib/
├── main.dart                  # Composition root — wires the whole DI graph & BLoC providers
├── core/
│   ├── api/                   # DioConsumer HTTP client
│   ├── bootstrap/             # AppBootstrap — cross-cubit wiring, VPN restore, socket lifecycle
│   ├── constants/             # api_constants.dart, app_constants.dart
│   ├── errors/                # NetworkExceptions sealed union
│   ├── injection/             # get_it + injectable setup
│   ├── interceptors/          # RefreshTokenInterceptor (transparent JWT refresh)
│   ├── resources/             # ColorManager, PaddingManager, SpacesManager, etc. (design tokens)
│   ├── session/               # Secure token/session storage
│   ├── theme/                 # Material 3 light/dark themes
│   ├── websocket/             # FirewallLogWsService (rate-paced, auto-reconnecting)
│   └── widgets/               # Nav bar, toasts, pressable buttons
└── features/                  # Vertical slices, each: presentation / domain / data
    ├── auth/                  # Register, login, session restore, profile
    ├── traffic/               # Core: packet stream → ML → verdict → live table (TrafficBloc)
    ├── vpn/                   # Dart bridge over the native VPN service
    ├── firewall_logs/         # Paginated server-backed verdict history
    ├── blacklist/             # Local-first blocked-IP list
    ├── hardware_metrics/      # CPU / RAM / battery telemetry
    ├── settings/              # Live-tunable thresholds & model toggles
    ├── dashboard/             # Aggregated session overview
    ├── analytics/             # Deeper threat analytics
    └── chatbot/               # Nova streaming AI assistant

android/app/src/main/kotlin/.../vpn/
├── NeuralVpnService.kt        # The VpnService: TUN interface, read loop, relays, enforcement
├── PacketParser.kt            # Raw IPv4 → structured packet
├── FlowTracker.kt             # CIC-IDS-style flow feature extraction
├── AppResolver.kt             # Attribute flows to owning apps (getConnectionOwnerUid)
└── DnsCache.kt                # IP → hostname labelling

assets/ai_models/              # 5 TFLite models + scaler_params.json
```

## Detection Models

Five specialised TensorFlow Lite models ship in `assets/ai_models/`. Each has its own feature order and standardisation params in a shared `scaler_params.json`:

| Model (catalog id)               | Specialisation                          | Features | Reported accuracy |
| -------------------------------- | --------------------------------------- | -------- | ----------------- |
| Brute Force Guard (`bruteForce`) | Password-guessing / credential-stuffing | 4        | 98%               |
| DoS Shield (`dos`)               | Generic denial-of-service floods        | 5        | 97%               |
| HULK Defender (`dosHulk`)        | HULK rapid-fire web-request storms      | 10       | 96%               |
| Flood Cannon (`loic`)            | LOIC coordinated flood tool             | 10       | 95%               |
| Heavy Storm (`hoic`)             | HOIC high-volume multi-source DDoS      | 12       | 95%               |

A per-flow feature map is scored by every enabled model; an **argmax-with-thresholds** rule turns the scores into a `safe` / `warn` / `AI block` verdict.

---

## Troubleshooting

| Symptom                                                                          | Fix                                                                                                               |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Build fails on `*.g.dart` / `*.freezed.dart` / `injection.config.dart` not found | Run `dart run build_runner build --delete-conflicting-outputs`                                                    |
| No packets appear / firewall does nothing                                        | You're on an emulator — use a **physical device**; and grant the VPN permission when prompted                     |
| VPN permission dialog never appears                                              | Uninstall and reinstall; ensure no other active VPN app holds the tunnel                                          |
| Can't reach a local backend                                                      | Use the machine's LAN IP (not `localhost`) in `api_constants.dart`; ensure device and dev machine share a network |
| TLS / certificate error against local backend                                    | Confirm you're running a **debug** build (self-signed certs are only bypassed in `kDebugMode`)                    |
| Stale generated code after pulling changes                                       | Re-run `build_runner build --delete-conflicting-outputs`                                                          |
| App loses internet when VPN is on                                                | Restart protection; the tunnel excludes the app's own package to avoid a forwarding loop                          |

---

## Documentation

- **[USER_MANUAL.md](USER_MANUAL.md)** — end-user guide: setup, screens, and how to operate the firewall.
- **[MOBILE_REPORT.md](MOBILE_REPORT.md)** — full technical / academic report on the mobile architecture and detection engine.

---

<div align="center">
<sub>Sentri Neural Firewall · v1.0.0 · Flutter + Kotlin · Android</sub>
</div>
