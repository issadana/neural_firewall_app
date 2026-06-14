enum VpnStatus { stopped, starting, running, error }

enum PacketStatus {
  aiBlock,
  warn,
  safe,
  system,
  tcp,
  quic,
  ping,
  err,
}

enum Protocol { tcp, udp, icmp, unknown }

enum BlacklistReason {
  manual,
  autoMl,
  autoHeuristic,
}

extension PacketStatusDisplay on PacketStatus {
  String get icon {
    switch (this) {
      case PacketStatus.aiBlock:
        return '🚫';
      case PacketStatus.warn:
        return '⚠️';
      case PacketStatus.safe:
        return '✅';
      case PacketStatus.system:
        return '⚙️';
      case PacketStatus.tcp:
        return '🔵';
      case PacketStatus.quic:
        return '🟣';
      case PacketStatus.ping:
        return '🟡';
      case PacketStatus.err:
        return '❌';
    }
  }

  String get label {
    switch (this) {
      case PacketStatus.aiBlock:
        return 'AI BLOCK';
      case PacketStatus.warn:
        return 'WARN';
      case PacketStatus.safe:
        return 'SAFE';
      case PacketStatus.system:
        return 'SYSTEM';
      case PacketStatus.tcp:
        return 'TCP';
      case PacketStatus.quic:
        return 'QUIC';
      case PacketStatus.ping:
        return 'PING';
      case PacketStatus.err:
        return 'ERR';
    }
  }
}
