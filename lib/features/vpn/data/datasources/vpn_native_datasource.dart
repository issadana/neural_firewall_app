import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

const _vpnMethodChannel = MethodChannel('com.neuralfw/vpn');
const _packetEventChannel = EventChannel('com.neuralfw/packets');

final _log = Logger();

class VpnNativeDataSource {
  static final VpnNativeDataSource _instance = VpnNativeDataSource._internal();

  factory VpnNativeDataSource() => _instance;

  VpnNativeDataSource._internal();

  late Stream<Map<String, dynamic>> _packetStream;
  bool _isInitialized = false;

  Stream<Map<String, dynamic>> get packetStream {
    if (!_isInitialized) {
      _initializeStream();
      _isInitialized = true;
    }
    return _packetStream;
  }

  void _initializeStream() {
    _packetStream = _packetEventChannel.receiveBroadcastStream().map((event) {
      try {
        return Map<String, dynamic>.from(event as Map);
      } catch (e) {
        _log.e('Error parsing packet: $e');
        return <String, dynamic>{};
      }
    }).where((packet) => packet.isNotEmpty);
  }

  Future<void> startVpn() async {
    try {
      await _vpnMethodChannel.invokeMethod('startVPN');
    } catch (e) {
      throw Exception('Failed to start VPN: $e');
    }
  }

  Future<void> stopVpn() async {
    try {
      await _vpnMethodChannel.invokeMethod('stopVPN');
    } catch (e) {
      throw Exception('Failed to stop VPN: $e');
    }
  }

  Future<bool> isVpnRunning() async {
    try {
      return await _vpnMethodChannel.invokeMethod<bool>('isVPNRunning') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getInterfaces() async {
    try {
      final result =
          await _vpnMethodChannel.invokeMethod<List>('getNetworkInterfaces') ?? [];
      return result.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<bool> checkVpnPermission() async {
    try {
      return await _vpnMethodChannel.invokeMethod<bool>('checkVPNPermission') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> requestVpnPermission() async {
    try {
      await _vpnMethodChannel.invokeMethod('requestVPNPermission');
    } catch (e) {
      throw Exception('Failed to request VPN permission: $e');
    }
  }
}
