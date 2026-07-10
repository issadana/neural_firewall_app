class BlacklistEntry {
  /// Server-assigned id. Null for purely-local entries that haven't synced yet
  /// (e.g. offline auto-blocks). Needed to DELETE the entry server-side.
  final int? id;
  final String ip;
  final DateTime addedAt;
  final String reason;

  /// Catalog id of the model that triggered the block (the max scorer), e.g.
  /// `dosHulk`. Null for manual blocks.
  final String? selectedModel;

  /// The winning model's score (0..1). Null for manual blocks.
  final double? selectedScore;

  /// Per-model scores keyed by the 5 catalog ids (`bruteForce`, `dos`,
  /// `dosHulk`, `loic`, `hoic`), values 0..1. Empty for manual blocks.
  final Map<String, double> allModelScores;

  final String? notes;

  const BlacklistEntry({
    this.id,
    required this.ip,
    required this.addedAt,
    required this.reason,
    this.selectedModel,
    this.selectedScore,
    this.allModelScores = const {},
    this.notes,
  });

  /// Manual entries carry the literal reason `manual`; everything else is an
  /// AI auto-block (the reason is a sentence locally, or `auto-ml` after it has
  /// mirrored to the backend).
  bool get isAiBlock => reason != 'manual';

  /// Matches the auto-block reason produced by the traffic pipeline:
  /// `AI flagged by "<modelId>" (score: 0.87)`.
  static final RegExp _flaggedByRe = RegExp(r'flagged by "([^"]+)"');

  /// Catalog id of the model whose score triggered this block — the max scorer.
  /// Prefers the explicit [selectedModel] field; falls back to parsing the
  /// descriptive [reason]/[notes] (older entries with no field). Null for
  /// manual entries.
  String? get flaggedModelId {
    if (selectedModel != null && selectedModel!.isNotEmpty) return selectedModel;
    for (final source in [reason, notes]) {
      if (source == null) continue;
      final match = _flaggedByRe.firstMatch(source);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// The winning model's score, if this was an AI block.
  double? get flaggedScore => selectedScore;

  BlacklistEntry copyWith({
    int? id,
    String? ip,
    DateTime? addedAt,
    String? reason,
    String? selectedModel,
    double? selectedScore,
    Map<String, double>? allModelScores,
    String? notes,
  }) => BlacklistEntry(
    id: id ?? this.id,
    ip: ip ?? this.ip,
    addedAt: addedAt ?? this.addedAt,
    reason: reason ?? this.reason,
    selectedModel: selectedModel ?? this.selectedModel,
    selectedScore: selectedScore ?? this.selectedScore,
    allModelScores: allModelScores ?? this.allModelScores,
    notes: notes ?? this.notes,
  );

  /// Tolerant parse of a per-model score map (int-or-double values).
  static Map<String, double> _parseScores(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (k, v) => MapEntry(k as String, (v as num).toDouble()),
      );
    }
    return const {};
  }

  // ── Local persistence (SharedPreferences) — camelCase keys ──────────────────

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'ip': ip,
    'addedAt': addedAt.toIso8601String(),
    'reason': reason,
    if (selectedModel != null) 'selectedModel': selectedModel,
    if (selectedScore != null) 'selectedScore': selectedScore,
    if (allModelScores.isNotEmpty) 'allModelScores': allModelScores,
    if (notes != null) 'notes': notes,
  };

  factory BlacklistEntry.fromJson(Map<String, dynamic> json) => BlacklistEntry(
    id: (json['id'] as num?)?.toInt(),
    ip: json['ip'] as String,
    addedAt: DateTime.parse(json['addedAt'] as String),
    reason: json['reason'] as String,
    selectedModel: json['selectedModel'] as String?,
    selectedScore: (json['selectedScore'] as num?)?.toDouble(),
    allModelScores: _parseScores(json['allModelScores']),
    notes: json['notes'] as String?,
  );

  // ── Backend API — snake_case keys ───────────────────────────────────────────

  /// Parses a `/blacklist` entry from the server. Tolerant of int-or-double
  /// scores and a missing/invalid timestamp. Score fields are nullable — manual
  /// blocks (and historical rows after the migration) have none.
  factory BlacklistEntry.fromApi(Map<String, dynamic> json) => BlacklistEntry(
    id: (json['id'] as num?)?.toInt(),
    ip: json['ip'] as String,
    addedAt:
        DateTime.tryParse(json['added_at'] as String? ?? '') ?? DateTime.now(),
    reason: json['reason'] as String? ?? 'manual',
    selectedModel: json['selected_model'] as String?,
    selectedScore: (json['selected_score'] as num?)?.toDouble(),
    allModelScores: _parseScores(json['all_model_scores']),
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
      if (selectedModel != null) 'selected_model': selectedModel,
      if (selectedScore != null) 'selected_score': selectedScore,
      if (allModelScores.isNotEmpty) 'all_model_scores': allModelScores,
      if (apiNotes != null) 'notes': apiNotes,
    };
  }
}
