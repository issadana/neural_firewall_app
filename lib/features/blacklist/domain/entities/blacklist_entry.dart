class BlacklistEntry {
  /// Server-assigned id. Null for purely-local entries that haven't synced yet
  /// (e.g. offline auto-blocks). Needed to DELETE the entry server-side.
  final int? id;
  final String ip;
  final DateTime addedAt;
  final String reason;
  final double? bruteForceScore;
  final double? dosScore;
  final String? notes;

  const BlacklistEntry({
    this.id,
    required this.ip,
    required this.addedAt,
    required this.reason,
    this.bruteForceScore,
    this.dosScore,
    this.notes,
  });

  BlacklistEntry copyWith({
    int? id,
    String? ip,
    DateTime? addedAt,
    String? reason,
    double? bruteForceScore,
    double? dosScore,
    String? notes,
  }) =>
      BlacklistEntry(
        id: id ?? this.id,
        ip: ip ?? this.ip,
        addedAt: addedAt ?? this.addedAt,
        reason: reason ?? this.reason,
        bruteForceScore: bruteForceScore ?? this.bruteForceScore,
        dosScore: dosScore ?? this.dosScore,
        notes: notes ?? this.notes,
      );

  // ── Local persistence (SharedPreferences) — camelCase keys ──────────────────

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'ip': ip,
        'addedAt': addedAt.toIso8601String(),
        'reason': reason,
        if (bruteForceScore != null) 'bruteForceScore': bruteForceScore,
        if (dosScore != null) 'dosScore': dosScore,
        if (notes != null) 'notes': notes,
      };

  factory BlacklistEntry.fromJson(Map<String, dynamic> json) => BlacklistEntry(
        id: (json['id'] as num?)?.toInt(),
        ip: json['ip'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
        reason: json['reason'] as String,
        bruteForceScore: (json['bruteForceScore'] as num?)?.toDouble(),
        dosScore: (json['dosScore'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  // ── Backend API — snake_case keys ───────────────────────────────────────────

  /// Parses a `/blacklist` entry from the server. Tolerant of int-or-double
  /// scores and a missing/invalid timestamp.
  factory BlacklistEntry.fromApi(Map<String, dynamic> json) => BlacklistEntry(
        id: (json['id'] as num?)?.toInt(),
        ip: json['ip'] as String,
        addedAt: DateTime.tryParse(json['added_at'] as String? ?? '') ??
            DateTime.now(),
        reason: json['reason'] as String? ?? 'manual',
        bruteForceScore: (json['bf_score'] as num?)?.toDouble(),
        dosScore: (json['dos_score'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  /// The request body for POST /blacklist (server generates id + added_at).
  ///
  /// The backend caps `reason` at 20 chars and `notes` at 255. Our auto-block
  /// reasons are full sentences, so when [reason] is too long we send a short
  /// `auto-ml` category and preserve the descriptive text in `notes`.
  Map<String, dynamic> toApiJson() {
    const maxReason = 20;
    const maxNotes = 255;

    final reasonFits = reason.length <= maxReason;
    final apiReason = reasonFits ? reason : 'auto-ml';

    String? apiNotes = reasonFits
        ? notes
        : [reason, notes].where((e) => e != null && e.isNotEmpty).join(' — ');
    if (apiNotes != null && apiNotes.isEmpty) apiNotes = null;
    if (apiNotes != null && apiNotes.length > maxNotes) {
      apiNotes = apiNotes.substring(0, maxNotes);
    }

    return {
      'ip': ip,
      'reason': apiReason,
      if (bruteForceScore != null) 'bf_score': bruteForceScore,
      if (dosScore != null) 'dos_score': dosScore,
      if (apiNotes != null) 'notes': apiNotes,
    };
  }
}
