class HardwareSnapshot {
  final double cpuUsage;
  final int ramUsedMb;
  final int ramTotalMb;
  final double? batteryLevel;
  final DateTime recordedAt;

  const HardwareSnapshot({
    required this.cpuUsage,
    required this.ramUsedMb,
    required this.ramTotalMb,
    this.batteryLevel,
    required this.recordedAt,
  });

  double get ramUsedPercent =>
      ramTotalMb > 0 ? (ramUsedMb / ramTotalMb) * 100 : 0;

  factory HardwareSnapshot.fromJson(Map<String, dynamic> json) => HardwareSnapshot(
        cpuUsage: (json['cpu_usage'] as num?)?.toDouble() ?? 0.0,
        ramUsedMb: json['ram_used_mb'] as int? ?? 0,
        ramTotalMb: json['ram_total_mb'] as int? ?? 0,
        batteryLevel: (json['battery_level'] as num?)?.toDouble(),
        recordedAt: json['recorded_at'] != null
            ? DateTime.parse(json['recorded_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'cpu_usage': cpuUsage,
        'ram_used_mb': ramUsedMb,
        'ram_total_mb': ramTotalMb,
        if (batteryLevel != null) 'battery_level': batteryLevel,
      };
}
