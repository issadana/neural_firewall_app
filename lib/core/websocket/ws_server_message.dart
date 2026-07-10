/// Typed representation of every message the backend can push down the
/// firewall-log WebSocket. Pattern-match these off
/// [FirewallLogWsService.pushStream] to react (update blacklist cache,
/// apply new thresholds, handle errors, etc.).
///
/// Wire format is documented in `FIREWALL_LOGS_WS_PLAN.md` §3.
sealed class WsServerMessage {
  const WsServerMessage();

  /// Parses a decoded JSON map into the matching subtype, or `null` if the
  /// `type` field is unknown (forward-compatible: new server types are
  /// ignored rather than throwing).
  static WsServerMessage? fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'ack':
        return WsAck(
          count: (json['count'] as num?)?.toInt() ?? 0,
          ids:
              (json['ids'] as List?)?.map((e) => (e as num).toInt()).toList() ??
              const [],
        );
      case 'pong':
        return const WsPong();
      case 'blacklist_update':
        return WsBlacklistUpdate(
          action: json['action'] as String? ?? 'added',
          ip: json['ip'] as String? ?? '',
          reason: json['reason'] as String? ?? 'blocked',
          selectedModel: json['selected_model'] as String?,
          selectedScore: (json['selected_score'] as num?)?.toDouble(),
          allModelScores:
              (json['all_model_scores'] as Map<String, dynamic>? ?? const {})
                  .map((k, v) => MapEntry(k, (v as num).toDouble())),
        );
      case 'settings_update':
        return WsSettingsUpdate(
          blockThreshold: (json['block_threshold'] as num?)?.toDouble(),
          warnThreshold: (json['warn_threshold'] as num?)?.toDouble(),
          logSystemTraffic: json['log_system_traffic'] as bool?,
        );
      case 'error':
        return WsError(
          code: json['code'] as String? ?? 'server_error',
          message: json['message'] as String? ?? '',
        );
      default:
        return null;
    }
  }
}

/// Backend confirmed a batch was persisted. [ids] are the DB row ids.
class WsAck extends WsServerMessage {
  final int count;
  final List<int> ids;
  const WsAck({required this.count, required this.ids});
}

/// Keepalive reply to a client `ping`.
class WsPong extends WsServerMessage {
  const WsPong();
}

/// Server auto-added (or removed) an IP from the user's blacklist. Apply to
/// the local blacklist cache without a REST round-trip.
class WsBlacklistUpdate extends WsServerMessage {
  final String action; // "added" | "removed"
  final String ip;
  final String reason;
  final String? selectedModel;
  final double? selectedScore;
  final Map<String, double> allModelScores;
  const WsBlacklistUpdate({
    required this.action,
    required this.ip,
    required this.reason,
    this.selectedModel,
    this.selectedScore,
    this.allModelScores = const {},
  });
}

/// Admin changed detection thresholds remotely — apply to the live pipeline.
/// Any field may be null if the server omitted it.
class WsSettingsUpdate extends WsServerMessage {
  final double? blockThreshold;
  final double? warnThreshold;
  final bool? logSystemTraffic;
  const WsSettingsUpdate({
    this.blockThreshold,
    this.warnThreshold,
    this.logSystemTraffic,
  });
}

/// Validation / policy error from the backend. When [code] is
/// `token_expired` the connection was closed and the client will reconnect
/// with a freshly-read token.
class WsError extends WsServerMessage {
  final String
  code; // batch_too_large | invalid_log | rate_limited | token_expired | server_error
  final String message;
  const WsError({required this.code, required this.message});
}
