enum VpnStatus { connected, connecting, disconnected, reconnecting }

enum PacketStatus { normal, anomaly, flood, ddos }

enum Protocol { tcp, udp, icmp, igmp, other }

enum BlacklistReason { malicious, flood, ddos, suspicious, manual }

enum AclAction { allow, block, notify }

enum TrafficType { inbound, outbound, local }

enum DashboardView { overview, detailed, analytics }

enum AlertSeverity { low, medium, high, critical }
