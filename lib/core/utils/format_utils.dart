class FormatUtils {
  static String formatBytes(int bytes) {
    const List<String> suffixes = ['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int suffixIndex = 0;

    while (value >= 1024 && suffixIndex < suffixes.length - 1) {
      value /= 1024;
      suffixIndex++;
    }

    return '${value.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }

  static String formatPackets(int packets) {
    if (packets >= 1000000) {
      return '${(packets / 1000000).toStringAsFixed(2)}M';
    } else if (packets >= 1000) {
      return '${(packets / 1000).toStringAsFixed(2)}K';
    }
    return packets.toString();
  }

  static String formatLatency(double ms) {
    return '${ms.toStringAsFixed(2)}ms';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  static String formatIpAddress(String ip) {
    return ip;
  }

  static String formatPort(int port) {
    return port.toString();
  }

  static String formatThreshold(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  static String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
