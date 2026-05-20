import 'package:intl/intl.dart';

import '../enums.dart';

class ProtocolHelper {
  static Protocol parseProtocol(int protocolNumber) {
    switch (protocolNumber) {
      case 6:
        return Protocol.tcp;
      case 17:
        return Protocol.udp;
      case 1:
        return Protocol.icmp;
      default:
        return Protocol.unknown;
    }
  }

  static String protocolName(Protocol protocol) {
    return protocol.toString().split('.').last.toUpperCase();
  }

  static int protocolNumber(Protocol protocol) {
    switch (protocol) {
      case Protocol.tcp:
        return 6;
      case Protocol.udp:
        return 17;
      case Protocol.icmp:
        return 1;
      case Protocol.unknown:
        return 0;
    }
  }
}

class FormatUtils {
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatIpPort(String ip, int port) {
    return '$ip:$port';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}
