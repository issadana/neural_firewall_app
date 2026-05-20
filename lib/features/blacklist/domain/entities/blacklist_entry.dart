class BlacklistEntry {
  final String ip;
  final DateTime addedAt;
  final String reason;
  final double? bruteForceScore;
  final double? dosScore;
  final String? notes;

  const BlacklistEntry({
    required this.ip,
    required this.addedAt,
    required this.reason,
    this.bruteForceScore,
    this.dosScore,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'addedAt': addedAt.toIso8601String(),
        'reason': reason,
        if (bruteForceScore != null) 'bruteForceScore': bruteForceScore,
        if (dosScore != null) 'dosScore': dosScore,
        if (notes != null) 'notes': notes,
      };

  factory BlacklistEntry.fromJson(Map<String, dynamic> json) => BlacklistEntry(
        ip: json['ip'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
        reason: json['reason'] as String,
        bruteForceScore: json['bruteForceScore'] as double?,
        dosScore: json['dosScore'] as double?,
        notes: json['notes'] as String?,
      );
}
