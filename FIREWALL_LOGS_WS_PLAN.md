# Firewall Logs — Secure WebSocket Implementation Plan

> **Part of:** Neural Firewall Full Implementation Plan  
> **Last Updated:** 2026-06-07  
> **Replaces:** `POST /firewall-logs` (REST) for the write path  
> **Keeps:** `GET /firewall-logs` (REST) for the read/query path (unchanged)

---

## Table of Contents

1. [Why WebSocket Instead of REST POST](#1-why-websocket-instead-of-rest-post)
2. [Full Data Flow](#2-full-data-flow)
3. [Message Protocol](#3-message-protocol)
4. [Security Design](#4-security-design)
5. [Backend Implementation](#5-backend-implementation)
6. [Flutter Implementation](#6-flutter-implementation)
7. [Offline Resilience — Local SQLite Queue](#7-offline-resilience--local-sqlite-queue)
8. [Implementation Order](#8-implementation-order)
9. [Summary of New Files](#9-summary-of-new-files)

---

## 1. Why WebSocket Instead of REST POST

| Concern | REST `POST /firewall-logs` | Secure WebSocket `wss://.../ws/logs` |
|---|---|---|
| **Connection cost** | New TCP + TLS handshake per request | One handshake, reused for entire session |
| **Throughput** | ~1 req/packet → hundreds of HTTP calls/min under load | Batched: 1 message per flush window (every 2s or 50 logs) |
| **Latency** | Round-trip per packet | Near-zero overhead per message after handshake |
| **Server push** | Impossible — client must poll | Server can push `blacklist_update`, `settings_update` in real-time |
| **Battery / data** | High overhead from repeated TLS + HTTP headers | Minimal framing overhead (2–10 bytes per WS frame) |
| **Offline handling** | Each failed POST must be retried individually | Buffer drains as one batch on reconnect |

**Decision:** The write path (Flutter → backend) moves to WebSocket. The read path (`GET /firewall-logs` with filters and pagination) stays as REST — it's queried on-demand and has no frequency problem.

---

## 2. Full Data Flow

```
Android Kernel (netfilter)
        │  raw packets
        ▼
NeuralVpnService.kt  (VPN TUN interface)
  • parses IP/TCP/UDP headers
  • builds enriched packet map (IP, ports, protocol, size, service label, appName, appPackage, isSystem)
        │  EventChannel (Kotlin → Flutter)
        ▼
TrafficBloc / ProcessPacketUseCase  (Flutter isolate)
  • calls MlDataSource.predictAll() → Map<model, score>
  • applies competition logic → action (blocked / warned / allowed)
  • builds FirewallLog entity
        │
        ├──→  emit to LiveTrafficScreen  (real-time UI list)
        │
        ├──→  if action == 'blocked': AddToBlacklistUseCase (local cache + WS flush)
        │
        └──→  FirewallLogWsService.enqueue(log)
                    │
                    ▼
            ┌─── LogBuffer ───────────────────────┐
            │  accumulates logs in memory          │
            │  flush trigger:                      │
            │    • every 2 seconds (Timer)         │
            │    • OR when buffer reaches 50 items │
            └─────────────────────────────────────┘
                    │  if WS connected
                    │  JSON batch → wss://host/ws/logs?token=<jwt>
                    │
                    ▼
            Backend WebSocket handler
              • validates JWT (already done at handshake)
              • validates each log payload
              • bulk INSERT into firewall_logs table
              • auto-INSERT blocked IPs into blacklist (if not present)
              • auto-INSERT ambiguous logs into unknown_events
              • sends ACK back: {"type":"ack","ids":[...]}
              • optionally pushes back: {"type":"blacklist_update","ip":"x.x.x.x"}
              • optionally pushes back: {"type":"settings_update", ...}
                    │
                    ▼
              PostgreSQL / SQLite  (firewall_logs table)
```

**If WebSocket is disconnected** (network drop, app background, token expired):
```
FirewallLogWsService.enqueue(log)
        │
        └──→  LocalLogQueue (sqflite)
                  • persists log to pending_logs table
                  • on next successful WS connect → drains queue first, then resumes live buffering
```

---

## 3. Message Protocol

All messages are UTF-8 JSON. The WebSocket connection is established over TLS (`wss://`).

### Flutter → Backend

#### `log_batch` — submit a batch of processed logs

```json
{
  "type": "log_batch",
  "logs": [
    {
      "src_ip":           "185.220.101.5",
      "src_port":         52341,
      "dst_port":         443,
      "protocol":         6,
      "size_bytes":       1460,
      "flow_iat_mean":    12.3,
      "tot_fwd_pkts":     8,
      "pkt_size_avg":     800.5,
      "flow_duration":    0.45,
      "selected_model":   "BF_v1",
      "selected_score":   0.92,
      "all_model_scores": { "BF_v1": 0.92, "DoS_Hulk": 0.12, "Model3": 0.03 },
      "action":           "blocked",
      "threat_type":      "brute_force",
      "service_name":     "Unknown",
      "app_name":         "Chrome",
      "app_package":      "com.android.chrome",
      "is_system":        false,
      "created_at":       "2026-06-07T14:23:01.000Z"
    }
  ]
}
```

Constraints enforced by the backend:
- Max 100 logs per batch (excess → `error: batch_too_large`)
- Max message size: 128 KB
- `action` must be one of: `blocked`, `warned`, `allowed`
- `selected_score` must be in `[0.0, 1.0]`
- `src_ip` must be a valid IPv4 or IPv6 string when present

#### `ping` — keepalive

```json
{ "type": "ping" }
```

---

### Backend → Flutter

#### `ack` — confirms a batch was saved

```json
{
  "type": "ack",
  "count": 3,
  "ids": [101, 102, 103]
}
```

#### `pong` — keepalive response

```json
{ "type": "pong" }
```

#### `blacklist_update` — server auto-added an IP to blacklist

Sent immediately after processing a batch that contained a new blocked IP. Flutter updates its local blacklist cache without an extra REST call.

```json
{
  "type": "blacklist_update",
  "action": "added",
  "ip": "185.220.101.5",
  "reason": "brute_force",
  "bf_score": 0.92,
  "dos_score": 0.08
}
```

#### `settings_update` — admin changed thresholds remotely

If the admin changes `block_threshold` or `warn_threshold` via the admin panel while the user is connected, the backend pushes the new values immediately. Flutter applies them to the next ML decision without the user having to restart.

```json
{
  "type": "settings_update",
  "block_threshold": 0.85,
  "warn_threshold": 0.60,
  "log_system_traffic": false
}
```

#### `error` — validation or server error on a batch

```json
{
  "type": "error",
  "code": "batch_too_large",
  "message": "Max 100 logs per batch. Received 134."
}
```

Possible `code` values: `batch_too_large`, `invalid_log`, `rate_limited`, `token_expired`, `server_error`.

---

## 4. Security Design

### 4.1 Transport: WSS (TLS)

- All connections use `wss://` — plain `ws://` connections are rejected with HTTP 403.
- The server certificate must be signed by a trusted CA (Let's Encrypt or similar).
- Flutter's `web_socket_channel` uses the OS TLS stack — no custom certificate pinning needed for MVP; can be added later via `SecurityContext` if required.

### 4.2 Authentication: JWT in Connection Header

Flutter sends the access JWT as a standard HTTP header during the WebSocket upgrade handshake:

```
GET /ws/logs HTTP/1.1
Upgrade: websocket
Authorization: Bearer <access_token>
```

The server validates the JWT **before accepting the connection** (`await websocket.accept()` is called only after verification). If the token is missing or invalid, the server returns HTTP 401 and closes the socket — no WebSocket connection is established.

> **Token refresh:** If the JWT expires mid-session, the server pushes `{"type":"error","code":"token_expired"}` and closes with code 4001. Flutter catches this, refreshes the token via `POST /auth/refresh`, and reconnects.

### 4.3 Rate Limiting

Per-connection limits enforced on the backend:

| Limit | Value | Action on breach |
|---|---|---|
| Max batches per second | 5 | `error: rate_limited`, connection closed |
| Max logs per batch | 100 | `error: batch_too_large`, batch rejected |
| Max message size | 128 KB | Connection closed with code 1009 |
| Max idle time (no ping) | 5 minutes | Connection closed with code 1000 |

### 4.4 Input Validation

Every field of every log entry is validated server-side before touching the database:

- `src_ip` — regex for IPv4/IPv6 or null
- `action` — enum check (`blocked` / `warned` / `allowed`)
- `selected_score` — float in `[0.0, 1.0]`
- `protocol` — one of: 1, 6, 17 or null
- String fields — stripped and max-length enforced (no raw SQL exposure; ORM used for all inserts)
- `all_model_scores` — validated as a flat `string → float` JSON object, each value in `[0.0, 1.0]`

---

## 5. Backend Implementation

### 5.1 File Structure

```
app/
├── websockets/
│   ├── __init__.py
│   ├── connection_manager.py       ← tracks active connections per user
│   ├── logs_handler.py             ← WebSocket endpoint + message routing
│   └── schemas.py                  ← Pydantic models for WS message validation
├── services/
│   └── log_persistence_service.py  ← bulk insert + auto-blacklist logic
└── routers/
    └── firewall_logs.py            ← existing GET /firewall-logs (unchanged)
```

---

### 5.2 `connection_manager.py`

Tracks all active WebSocket connections, keyed by `user_id`. Supports multiple simultaneous connections per user (the same account on two devices).

```python
from fastapi import WebSocket
import asyncio

class ConnectionManager:
    def __init__(self):
        # user_id → set of active WebSocket connections
        self._connections: dict[int, set[WebSocket]] = {}
        self._lock = asyncio.Lock()

    async def connect(self, websocket: WebSocket, user_id: int) -> None:
        await websocket.accept()
        async with self._lock:
            self._connections.setdefault(user_id, set()).add(websocket)

    async def disconnect(self, websocket: WebSocket, user_id: int) -> None:
        async with self._lock:
            conns = self._connections.get(user_id, set())
            conns.discard(websocket)
            if not conns:
                self._connections.pop(user_id, None)

    async def push_to_user(self, user_id: int, message: dict) -> None:
        """Push a server-initiated message to all connections for a user."""
        for ws in list(self._connections.get(user_id, set())):
            try:
                await ws.send_json(message)
            except Exception:
                await self.disconnect(ws, user_id)

manager = ConnectionManager()  # singleton, imported by handler
```

---

### 5.3 `schemas.py`

```python
from pydantic import BaseModel, Field, field_validator
from typing import Optional
import re

IPV4_RE = re.compile(r'^(\d{1,3}\.){3}\d{1,3}$')
IPV6_RE = re.compile(r'^[0-9a-fA-F:]+$')

class LogEntry(BaseModel):
    src_ip:           Optional[str]        = None
    src_port:         Optional[int]        = None
    dst_port:         Optional[int]        = None
    protocol:         Optional[int]        = None
    size_bytes:       Optional[int]        = None
    flow_iat_mean:    Optional[float]      = None
    tot_fwd_pkts:     Optional[int]        = None
    pkt_size_avg:     Optional[float]      = None
    flow_duration:    Optional[float]      = None
    selected_model:   Optional[str]        = None
    selected_score:   Optional[float]      = Field(None, ge=0.0, le=1.0)
    all_model_scores: Optional[dict[str, float]] = None
    action:           str                  = Field(..., pattern=r'^(blocked|warned|allowed)$')
    threat_type:      Optional[str]        = None
    service_name:     Optional[str]        = Field(None, max_length=100)
    app_name:         Optional[str]        = Field(None, max_length=100)
    app_package:      Optional[str]        = Field(None, max_length=200)
    is_system:        bool                 = False
    created_at:       str                  = ""  # ISO-8601 from device

    @field_validator("src_ip")
    @classmethod
    def validate_ip(cls, v):
        if v is None:
            return v
        if IPV4_RE.match(v) or IPV6_RE.match(v):
            return v
        raise ValueError(f"Invalid IP address: {v}")

    @field_validator("protocol")
    @classmethod
    def validate_protocol(cls, v):
        if v is not None and v not in (1, 6, 17):
            raise ValueError(f"Unsupported protocol: {v}")
        return v

class LogBatchMessage(BaseModel):
    type:  str       = "log_batch"
    logs:  list[LogEntry] = Field(..., max_length=100)
```

---

### 5.4 `log_persistence_service.py`

Single function responsible for bulk insert and side effects. Runs inside a single DB transaction per batch.

```python
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models import FirewallLog, Blacklist, UnknownEvent
from app.websockets.schemas import LogEntry
from datetime import datetime, timezone

async def persist_log_batch(
    db: AsyncSession,
    user_id: int,
    logs: list[LogEntry],
    block_threshold: float,
    warn_threshold: float,
) -> tuple[list[int], list[dict]]:
    """
    Bulk-inserts a validated log batch.
    Returns (saved_ids, blacklist_additions).
    blacklist_additions is a list of dicts ready to push back to the client.
    """

    # 1. Build ORM rows
    log_rows = []
    for entry in logs:
        recorded_at = _parse_dt(entry.created_at)
        log_rows.append(FirewallLog(
            user_id=user_id,
            src_ip=entry.src_ip,
            src_port=entry.src_port,
            dst_port=entry.dst_port,
            protocol=entry.protocol,
            size_bytes=entry.size_bytes,
            flow_iat_mean=entry.flow_iat_mean,
            tot_fwd_pkts=entry.tot_fwd_pkts,
            pkt_size_avg=entry.pkt_size_avg,
            flow_duration=entry.flow_duration,
            selected_model=entry.selected_model,
            selected_score=entry.selected_score,
            all_model_scores=entry.all_model_scores,
            action=entry.action,
            threat_type=entry.threat_type,
            service_name=entry.service_name,
            app_name=entry.app_name,
            app_package=entry.app_package,
            is_system=entry.is_system,
            created_at=recorded_at,
        ))

    db.add_all(log_rows)
    await db.flush()  # populate IDs without committing yet
    saved_ids = [row.id for row in log_rows]

    # 2. Auto-blacklist: collect unique blocked IPs not already blacklisted
    blocked_ips = {
        e.src_ip for e in logs
        if e.action == "blocked" and e.src_ip
    }
    blacklist_additions = []

    for ip in blocked_ips:
        result = await db.execute(
            select(Blacklist).where(
                Blacklist.user_id == user_id,
                Blacklist.ip == ip
            )
        )
        if result.scalar_one_or_none() is None:
            # Pick the log with the highest score for this IP for metadata
            best = max(
                (e for e in logs if e.src_ip == ip),
                key=lambda e: e.selected_score or 0.0,
            )
            bf_score  = (best.all_model_scores or {}).get("BF_v1")
            dos_score = (best.all_model_scores or {}).get("DoS_Hulk")
            db.add(Blacklist(
                user_id=user_id,
                ip=ip,
                reason=best.threat_type or "blocked",
                bf_score=bf_score,
                dos_score=dos_score,
            ))
            blacklist_additions.append({
                "type":      "blacklist_update",
                "action":    "added",
                "ip":        ip,
                "reason":    best.threat_type or "blocked",
                "bf_score":  bf_score,
                "dos_score": dos_score,
            })

    # 3. Auto-unknown-events: ambiguous scores (between warn and block thresholds)
    for entry, row in zip(logs, log_rows):
        score = entry.selected_score or 0.0
        if warn_threshold < score <= block_threshold:
            db.add(UnknownEvent(
                user_id=user_id,
                firewall_log_id=row.id,
                status="pending",
            ))

    await db.commit()
    return saved_ids, blacklist_additions


def _parse_dt(iso_str: str) -> datetime:
    try:
        return datetime.fromisoformat(iso_str.replace("Z", "+00:00"))
    except Exception:
        return datetime.now(timezone.utc)
```

---

### 5.5 `logs_handler.py` — WebSocket Endpoint

```python
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
import asyncio, json

from app.core.security import decode_access_token   # raises if invalid/expired
from app.core.deps import get_db, get_user_settings
from app.websockets.connection_manager import manager
from app.websockets.schemas import LogBatchMessage
from app.services.log_persistence_service import persist_log_batch

router = APIRouter()

PING_INTERVAL   = 30      # seconds between server-side pings
IDLE_TIMEOUT    = 300     # seconds before closing an unresponsive connection
MAX_BATCH_RATE  = 5       # max log_batch messages per second

@router.websocket("/ws/logs")
async def firewall_logs_ws(
    websocket: WebSocket,
    token: str = Query(..., description="Valid JWT access token"),
    db: AsyncSession = Depends(get_db),
):
    # ── 1. Authenticate before accepting ──────────────────────────────────
    try:
        user_id = decode_access_token(token)
    except Exception:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    # ── 2. Load user settings (thresholds needed for unknown_events logic) ─
    settings = await get_user_settings(db, user_id)

    # ── 3. Accept & register ───────────────────────────────────────────────
    await manager.connect(websocket, user_id)

    rate_window: list[float] = []  # timestamps of recent log_batch messages
    last_seen = asyncio.get_event_loop().time()

    try:
        while True:
            try:
                raw = await asyncio.wait_for(
                    websocket.receive_text(),
                    timeout=IDLE_TIMEOUT,
                )
            except asyncio.TimeoutError:
                # Client went silent — close cleanly
                await websocket.close(code=1000)
                break

            last_seen = asyncio.get_event_loop().time()
            data = json.loads(raw)
            msg_type = data.get("type")

            # ── Keepalive ─────────────────────────────────────────────────
            if msg_type == "ping":
                await websocket.send_json({"type": "pong"})
                continue

            # ── Log batch ─────────────────────────────────────────────────
            if msg_type == "log_batch":
                now = asyncio.get_event_loop().time()

                # Rate limiting: max MAX_BATCH_RATE batches per second
                rate_window = [t for t in rate_window if now - t < 1.0]
                if len(rate_window) >= MAX_BATCH_RATE:
                    await websocket.send_json({
                        "type":    "error",
                        "code":    "rate_limited",
                        "message": f"Max {MAX_BATCH_RATE} batches/sec exceeded.",
                    })
                    await websocket.close(code=1008)
                    break
                rate_window.append(now)

                # Validate with Pydantic
                try:
                    batch = LogBatchMessage(**data)
                except Exception as exc:
                    await websocket.send_json({
                        "type":    "error",
                        "code":    "invalid_log",
                        "message": str(exc),
                    })
                    continue

                # Persist
                saved_ids, bl_additions = await persist_log_batch(
                    db,
                    user_id,
                    batch.logs,
                    settings.block_threshold,
                    settings.warn_threshold,
                )

                # ACK
                await websocket.send_json({
                    "type":  "ack",
                    "count": len(saved_ids),
                    "ids":   saved_ids,
                })

                # Push blacklist updates
                for update in bl_additions:
                    await websocket.send_json(update)

    except WebSocketDisconnect:
        pass
    finally:
        await manager.disconnect(websocket, user_id)
```

---

### 5.6 Registering the WebSocket Router

In `main.py` (or wherever FastAPI app is built):

```python
from app.websockets.logs_handler import router as ws_logs_router
app.include_router(ws_logs_router, tags=["websocket"])
```

---

### 5.7 Pushing Settings Updates (Admin → Connected Users)

When an admin updates `user_settings` via `PUT /settings`, the settings router calls:

```python
await manager.push_to_user(user_id, {
    "type":               "settings_update",
    "block_threshold":    new_settings.block_threshold,
    "warn_threshold":     new_settings.warn_threshold,
    "log_system_traffic": new_settings.log_system_traffic,
})
```

This reaches the user's open WebSocket connection immediately — no polling needed.

---

## 6. Flutter Implementation

### 6.1 File Structure

```
lib/features/firewall_logs/
├── data/
│   ├── datasources/
│   │   ├── firewall_log_remote_datasource.dart   ← GET /firewall-logs (REST, unchanged)
│   │   └── firewall_log_ws_datasource.dart       ← NEW: WebSocket write path
│   ├── local/
│   │   └── pending_log_queue.dart                ← NEW: sqflite offline queue
│   └── repositories/
│       └── firewall_log_repository_impl.dart     ← updated to delegate write to WS
├── domain/
│   ├── entities/
│   │   └── firewall_log.dart
│   ├── repositories/
│   │   └── firewall_log_repository.dart
│   └── usecases/
│       ├── get_firewall_logs_usecase.dart         ← REST read (unchanged)
│       └── enqueue_firewall_log_usecase.dart      ← NEW: replaces post_firewall_log_usecase
└── presentation/  (unchanged)
```

**New standalone service** (not inside a feature folder — it's infrastructure):

```
lib/core/websocket/
├── ws_connection_service.dart     ← manages the WebSocket lifecycle
├── ws_status.dart                 ← enum: connected / connecting / disconnected / error
└── ws_server_message.dart         ← sealed class for typed server push messages
```

---

### 6.2 `ws_status.dart`

```dart
enum WsStatus { connecting, connected, disconnected, error }
```

---

### 6.3 `ws_server_message.dart`

Sealed class — pattern-matched in the cubit to handle each push type:

```dart
sealed class WsServerMessage {}

class WsAck extends WsServerMessage {
  final List<int> ids;
  WsAck(this.ids);
}

class WsBlacklistUpdate extends WsServerMessage {
  final String ip;
  final String reason;
  final double? bfScore;
  final double? dosScore;
  WsBlacklistUpdate({required this.ip, required this.reason, this.bfScore, this.dosScore});
}

class WsSettingsUpdate extends WsServerMessage {
  final double blockThreshold;
  final double warnThreshold;
  final bool logSystemTraffic;
  WsSettingsUpdate({required this.blockThreshold, required this.warnThreshold, required this.logSystemTraffic});
}

class WsError extends WsServerMessage {
  final String code;
  final String message;
  WsError({required this.code, required this.message});
}
```

---

### 6.4 `ws_connection_service.dart`

The core service. Manages connection lifecycle, buffer, flush timer, reconnection, and routing of server-push messages.

```dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsConnectionService {
  final String _baseWsUrl;   // e.g. "wss://api.example.com"
  final PendingLogQueue _queue;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _flushTimer;
  Timer? _pingTimer;

  final _buffer = <Map<String, dynamic>>[];
  static const _maxBufferSize   = 50;    // flush immediately when full
  static const _flushIntervalMs = 2000;  // flush every 2 seconds
  static const _pingIntervalSec = 25;    // send ping every 25s (server idles at 30s)
  static const _maxBatchSize    = 100;   // hard cap matching server limit

  int _reconnectDelaySec = 1;
  String? _currentToken;
  bool _disposed = false;

  // Streams for the rest of the app to observe
  final _statusCtrl  = StreamController<WsStatus>.broadcast();
  final _pushCtrl    = StreamController<WsServerMessage>.broadcast();

  Stream<WsStatus>        get statusStream => _statusCtrl.stream;
  Stream<WsServerMessage> get pushStream   => _pushCtrl.stream;

  WsConnectionService(this._baseWsUrl, this._queue);

  // ── Connect ────────────────────────────────────────────────────────────

  Future<void> connect(String token) async {
    if (_disposed) return;
    _currentToken = token;
    _statusCtrl.add(WsStatus.connecting);

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse('$_baseWsUrl/ws/logs?token=$token'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone:  ()  => _scheduleReconnect(),
      );

      _statusCtrl.add(WsStatus.connected);
      _reconnectDelaySec = 1; // reset backoff on success

      await _drainOfflineQueue();   // send any queued-while-offline logs first
      _startFlushTimer();
      _startPingTimer();

    } catch (_) {
      _statusCtrl.add(WsStatus.error);
      _scheduleReconnect();
    }
  }

  // ── Enqueue a log (called from ML pipeline) ────────────────────────────

  void enqueue(Map<String, dynamic> logJson) {
    _buffer.add(logJson);
    if (_buffer.length >= _maxBufferSize) {
      _flush();
    }
  }

  // ── Flush buffer → WebSocket ───────────────────────────────────────────

  void _flush() {
    if (_buffer.isEmpty) return;

    if (_channel == null) {
      // Offline: persist to SQLite queue
      _queue.saveAll(List.from(_buffer));
      _buffer.clear();
      return;
    }

    // Split into chunks of _maxBatchSize to respect server limit
    final chunks = <List<Map<String, dynamic>>>[];
    for (var i = 0; i < _buffer.length; i += _maxBatchSize) {
      chunks.add(_buffer.sublist(i, i + _maxBatchSize > _buffer.length
          ? _buffer.length
          : i + _maxBatchSize));
    }
    _buffer.clear();

    for (final chunk in chunks) {
      try {
        _channel!.sink.add(jsonEncode({'type': 'log_batch', 'logs': chunk}));
      } catch (_) {
        // Put back and trigger reconnect
        _buffer.insertAll(0, chunk);
        _scheduleReconnect();
        break;
      }
    }
  }

  // ── Drain offline queue on reconnect ──────────────────────────────────

  Future<void> _drainOfflineQueue() async {
    final pending = await _queue.getAll();
    if (pending.isEmpty) return;

    for (var i = 0; i < pending.length; i += _maxBatchSize) {
      final chunk = pending.sublist(i, (i + _maxBatchSize).clamp(0, pending.length));
      try {
        _channel!.sink.add(jsonEncode({'type': 'log_batch', 'logs': chunk}));
      } catch (_) {
        break; // will retry on next connect
      }
    }
    await _queue.clear();
  }

  // ── Handle incoming server messages ───────────────────────────────────

  void _onMessage(dynamic raw) {
    final data = jsonDecode(raw as String) as Map<String, dynamic>;

    switch (data['type']) {
      case 'ack':
        _pushCtrl.add(WsAck(List<int>.from(data['ids'] as List)));

      case 'pong':
        break; // keepalive confirmed — nothing to do

      case 'blacklist_update':
        _pushCtrl.add(WsBlacklistUpdate(
          ip:       data['ip']     as String,
          reason:   data['reason'] as String,
          bfScore:  (data['bf_score']  as num?)?.toDouble(),
          dosScore: (data['dos_score'] as num?)?.toDouble(),
        ));

      case 'settings_update':
        _pushCtrl.add(WsSettingsUpdate(
          blockThreshold:    (data['block_threshold']    as num).toDouble(),
          warnThreshold:     (data['warn_threshold']     as num).toDouble(),
          logSystemTraffic:  data['log_system_traffic']  as bool,
        ));

      case 'error':
        final code = data['code'] as String;
        _pushCtrl.add(WsError(code: code, message: data['message'] as String));
        if (code == 'token_expired') {
          _channel = null;
          // Signal to AuthBloc to refresh the token and call connect() again
        }
    }
  }

  // ── Timers ────────────────────────────────────────────────────────────

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      const Duration(milliseconds: _flushIntervalMs),
      (_) => _flush(),
    );
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: _pingIntervalSec),
      (_) {
        try {
          _channel?.sink.add(jsonEncode({'type': 'ping'}));
        } catch (_) {}
      },
    );
  }

  // ── Reconnection (exponential backoff) ────────────────────────────────

  void _scheduleReconnect() {
    if (_disposed || _currentToken == null) return;
    _statusCtrl.add(WsStatus.disconnected);
    _channel = null;
    _flushTimer?.cancel();
    _pingTimer?.cancel();
    _sub?.cancel();

    Future.delayed(Duration(seconds: _reconnectDelaySec), () {
      if (!_disposed) connect(_currentToken!);
    });

    _reconnectDelaySec = (_reconnectDelaySec * 2).clamp(1, 30);
  }

  // ── Cleanup ───────────────────────────────────────────────────────────

  void dispose() {
    _disposed = true;
    _flushTimer?.cancel();
    _pingTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _statusCtrl.close();
    _pushCtrl.close();
  }
}
```

---

### 6.5 `pending_log_queue.dart` — Local SQLite Offline Queue

```dart
import 'package:sqflite/sqflite.dart';

class PendingLogQueue {
  static const _table = 'pending_logs';
  final Database _db;

  PendingLogQueue(this._db);

  static Future<PendingLogQueue> init() async {
    final db = await openDatabase(
      'firewall_offline.db',
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id      INTEGER PRIMARY KEY AUTOINCREMENT,
          payload TEXT NOT NULL,
          queued_at TEXT NOT NULL
        )
      '''),
    );
    return PendingLogQueue(db);
  }

  Future<void> saveAll(List<Map<String, dynamic>> logs) async {
    final batch = _db.batch();
    final now = DateTime.now().toIso8601String();
    for (final log in logs) {
      batch.insert(_table, {'payload': jsonEncode(log), 'queued_at': now});
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final rows = await _db.query(_table, orderBy: 'id ASC');
    return rows.map((r) => jsonDecode(r['payload'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> clear() => _db.delete(_table);
}
```

---

### 6.6 Integration with the ML Pipeline

The `WsConnectionService` is injected as a singleton via GetIt. After the ML pipeline decides an action, a single call enqueues the log — no `await`, no blocking:

```dart
// In ProcessPacketUseCase or TrafficBloc, after predictAll():

final log = FirewallLog.fromDetectionResult(result, packet);

// 1. Update live traffic UI
emit(state.copyWith(latestLog: log));

// 2. Enqueue for WebSocket transmission — non-blocking
_wsService.enqueue(log.toJson());

// 3. If blocked, update local blacklist cache immediately
//    (server will also confirm via WsBlacklistUpdate push)
if (result.action == 'blocked') {
  await _addToBlacklistUseCase(result.srcIp);
}
```

---

### 6.7 Reacting to Server Push Messages

Listen to `_wsService.pushStream` in the relevant cubits (registered once in `main.dart`):

```dart
// In BlacklistCubit (or a top-level AppBloc):
_wsService.pushStream.listen((msg) {
  switch (msg) {
    case WsBlacklistUpdate():
      // Add the new IP to the local blacklist state immediately
      addLocalEntry(msg.ip, msg.reason, msg.bfScore, msg.dosScore);

    case WsSettingsUpdate():
      // Hot-update thresholds — next ML inference uses new values
      _settingsService.applyRemoteUpdate(
        blockThreshold:   msg.blockThreshold,
        warnThreshold:    msg.warnThreshold,
        logSystemTraffic: msg.logSystemTraffic,
      );

    case WsError():
      if (msg.code == 'token_expired') {
        // Trigger token refresh flow
        _authBloc.add(TokenExpiredEvent());
      }

    case WsAck():
      break; // ACK is informational — no UI change needed
  }
});
```

---

### 6.8 WebSocket Status Indicator in UI

Show a small status chip on the Dashboard or Live Traffic screen so the user can see whether logs are being saved:

```dart
// In DashboardScreen or HomeScreen app bar:
StreamBuilder<WsStatus>(
  stream: _wsService.statusStream,
  builder: (context, snapshot) {
    final status = snapshot.data ?? WsStatus.disconnected;
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: switch (status) {
          WsStatus.connected    => Colors.green,
          WsStatus.connecting   => Colors.orange,
          WsStatus.disconnected => Colors.grey,
          WsStatus.error        => Colors.red,
        },
        radius: 6,
      ),
      label: Text(status.name, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
    );
  },
)
```

---

### 6.9 GetIt Registration (`main.dart`)

```dart
// Singletons registered once at startup:
final queue      = await PendingLogQueue.init();
final wsService  = WsConnectionService(ApiConstants.baseWsUrl, queue);

getIt.registerSingleton<PendingLogQueue>(queue);
getIt.registerSingleton<WsConnectionService>(wsService);

// Connect after auth:
final token = await getIt<AuthRepository>().getAccessToken();
if (token != null) await wsService.connect(token);

// Reconnect after token refresh (in AuthBloc):
// getIt<WsConnectionService>().connect(newToken);
```

---

## 7. Offline Resilience — Local SQLite Queue

The offline queue ensures **zero log loss** even when the device is on a flaky mobile network or the app is temporarily backgrounded.

```
Normal flow:
  enqueue(log) → _buffer → flush() → WebSocket → backend DB

Network drop detected (onError / onDone on the stream):
  enqueue(log) → _buffer → flush() → [WS null] → PendingLogQueue.saveAll()

On reconnect:
  connect() succeeds
    → drainOfflineQueue()
        → reads all rows from pending_logs (oldest first)
        → sends as batches of 100
        → on ack: PendingLogQueue.clear()
    → resume live buffering
```

**Queue size management:** The queue is not unbounded. If the device is offline for a very long time and `pending_logs` grows past `max_log_entries` (from `user_settings`), the oldest entries are deleted:

```dart
Future<void> saveAll(List<Map<String, dynamic>> logs) async {
  // ... insert new rows ...
  
  // Trim to max_log_entries to prevent unbounded growth
  final maxEntries = getIt<SettingsService>().maxLogEntries;
  await _db.execute('''
    DELETE FROM $_table WHERE id NOT IN (
      SELECT id FROM $_table ORDER BY id DESC LIMIT $maxEntries
    )
  ''');
}
```

---

## 8. Implementation Order

| Step | What | Why first |
|---|---|---|
| 1 | Add `web_socket_channel` and `sqflite` to `pubspec.yaml` | Dependencies required before any WS code |
| 2 | Backend: `connection_manager.py` | Needed by the WS handler |
| 3 | Backend: `schemas.py` (Pydantic validation models) | Needed by persistence service |
| 4 | Backend: `log_persistence_service.py` | Core DB logic independent of transport |
| 5 | Backend: `logs_handler.py` (WebSocket endpoint) | Wires manager + service into FastAPI |
| 6 | Backend: register WS router in `main.py` | Exposes the endpoint |
| 7 | Backend: update `PUT /settings` to call `manager.push_to_user()` | Enables remote settings push |
| 8 | Flutter: `PendingLogQueue` (sqflite) | Needed before WS service (offline path) |
| 9 | Flutter: `WsConnectionService` | Core Flutter WS client |
| 10 | Flutter: `ws_status.dart` + `ws_server_message.dart` | Typed stream models |
| 11 | Flutter: GetIt registration + connect on startup | Wires service into app lifecycle |
| 12 | Flutter: Update `ProcessPacketUseCase` to call `wsService.enqueue()` | Plugs ML output into WS |
| 13 | Flutter: Listen to `pushStream` in `BlacklistCubit` + `SettingsCubit` | React to server pushes |
| 14 | Flutter: WS status chip on DashboardScreen | Surface connection health to user |
| 15 | Remove old `PostFirewallLogUseCase` + `POST /firewall-logs` handler | Clean up REST write path |

---

## 9. Summary of New Files

### Backend
- `app/websockets/__init__.py`
- `app/websockets/connection_manager.py`
- `app/websockets/schemas.py`
- `app/websockets/logs_handler.py`
- `app/services/log_persistence_service.py`

### Flutter — New Files
- `lib/core/websocket/ws_connection_service.dart`
- `lib/core/websocket/ws_status.dart`
- `lib/core/websocket/ws_server_message.dart`
- `lib/features/firewall_logs/data/datasources/firewall_log_ws_datasource.dart`
- `lib/features/firewall_logs/data/local/pending_log_queue.dart`

### Flutter — Modified Files
- `lib/features/firewall_logs/domain/usecases/` — replace `post_firewall_log_usecase.dart` with `enqueue_firewall_log_usecase.dart`
- `lib/features/firewall_logs/data/repositories/firewall_log_repository_impl.dart` — delegate write to `WsConnectionService`
- `lib/features/traffic/domain/usecases/process_packet_usecase.dart` — call `wsService.enqueue()` after ML decision
- `lib/features/blacklist/presentation/bloc/blacklist_cubit.dart` — listen to `WsBlacklistUpdate`
- `lib/features/settings/presentation/bloc/settings_cubit.dart` — listen to `WsSettingsUpdate`
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart` — add WS status chip
- `lib/main.dart` — init `PendingLogQueue`, register `WsConnectionService`, call `connect()`
- `pubspec.yaml` — add `web_socket_channel`, `sqflite`

### Removed
- `lib/features/firewall_logs/domain/usecases/post_firewall_log_usecase.dart`
- Backend: `POST /firewall-logs` handler (the `GET /firewall-logs` read endpoint is kept)
