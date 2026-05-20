class AclEntry {
  final String ip;
  final DateTime addedAt;
  final String? notes;

  const AclEntry({
    required this.ip,
    required this.addedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'addedAt': addedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  factory AclEntry.fromJson(Map<String, dynamic> json) => AclEntry(
        ip: json['ip'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
        notes: json['notes'] as String?,
      );
}
