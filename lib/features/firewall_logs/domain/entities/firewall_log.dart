class FirewallLog {
  final int id;
  final String srcIp;
  final String dstIp;
  final int srcPort;
  final int dstPort;
  final int protocol;
  final int sizeBytes;
  final double duration;
  final int fwdPkts;
  final int bwdPkts;
  final double fwdRate;
  final String selectedModel;
  final double selectedScore;
  final Map<String, double> allModelScores;
  final String action;
  final String threatType;
  final String serviceName;
  final String appName;
  final String appPackage;
  final bool isSystem;
  final DateTime createdAt;

  const FirewallLog({
    required this.id,
    required this.srcIp,
    required this.dstIp,
    required this.srcPort,
    required this.dstPort,
    required this.protocol,
    required this.sizeBytes,
    required this.duration,
    required this.fwdPkts,
    required this.bwdPkts,
    required this.fwdRate,
    required this.selectedModel,
    required this.selectedScore,
    required this.allModelScores,
    required this.action,
    required this.threatType,
    required this.serviceName,
    required this.appName,
    required this.appPackage,
    required this.isSystem,
    required this.createdAt,
  });

  factory FirewallLog.fromJson(Map<String, dynamic> json) => FirewallLog(
    id: json['id'] as int,
    srcIp: json['src_ip'] as String? ?? '',
    dstIp: json['dst_ip'] as String? ?? '',
    srcPort: json['src_port'] as int? ?? 0,
    dstPort: json['dst_port'] as int? ?? 0,
    protocol: json['protocol'] as int? ?? 0,
    sizeBytes: json['size_bytes'] as int? ?? 0,
    duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
    fwdPkts: json['fwd_pkts'] as int? ?? 0,
    bwdPkts: json['bwd_pkts'] as int? ?? 0,
    fwdRate: (json['fwd_rate'] as num?)?.toDouble() ?? 0.0,
    selectedModel: json['selected_model'] as String? ?? '',
    selectedScore: (json['selected_score'] as num?)?.toDouble() ?? 0.0,
    allModelScores: (json['all_model_scores'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num).toDouble())),
    action: json['action'] as String? ?? 'allowed',
    threatType: json['threat_type'] as String? ?? '',
    serviceName: json['service_name'] as String? ?? '',
    appName: json['app_name'] as String? ?? '',
    appPackage: json['app_package'] as String? ?? '',
    isSystem: json['is_system'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'src_ip': srcIp,
    'dst_ip': dstIp,
    'src_port': srcPort,
    'dst_port': dstPort,
    'protocol': protocol,
    'size_bytes': sizeBytes,
    'duration': duration,
    'fwd_pkts': fwdPkts,
    'bwd_pkts': bwdPkts,
    'fwd_rate': fwdRate,
    'selected_model': selectedModel,
    'selected_score': selectedScore,
    'all_model_scores': allModelScores,
    'action': action,
    'threat_type': threatType,
    'service_name': serviceName,
    'app_name': appName,
    'app_package': appPackage,
    'is_system': isSystem,
  };
}
