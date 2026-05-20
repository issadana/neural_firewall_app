class FlowFeatures {
  final String srcIp;
  final int srcPort;
  final String dstIp;
  final int dstPort;
  final int packetCount;
  final int totalBytes;
  final double iatMean;
  final double iatStd;
  final double duration;
  final bool tcpSynFlag;
  final bool tcpFinFlag;
  final bool tcpResetFlag;

  const FlowFeatures({
    required this.srcIp,
    required this.srcPort,
    required this.dstIp,
    required this.dstPort,
    required this.packetCount,
    required this.totalBytes,
    required this.iatMean,
    required this.iatStd,
    required this.duration,
    required this.tcpSynFlag,
    required this.tcpFinFlag,
    required this.tcpResetFlag,
  });
}
