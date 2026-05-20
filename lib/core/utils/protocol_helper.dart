import '../enums.dart';

class ProtocolHelper {
  static String getProtocolName(Protocol protocol) {
    switch (protocol) {
      case Protocol.tcp:
        return 'TCP';
      case Protocol.udp:
        return 'UDP';
      case Protocol.icmp:
        return 'ICMP';
      case Protocol.unknown:
        return 'Other';
    }
  }

  static Protocol fromInt(int protocolNumber) {
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

  static int toInt(Protocol protocol) {
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
