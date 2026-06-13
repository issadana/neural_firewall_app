import 'package:flutter/services.dart';
import '../../domain/entities/hardware_snapshot.dart';

class HardwareLocalDataSource {
  static const _channel = MethodChannel('com.sentri.app/hardware');

  Future<HardwareSnapshot> collectSnapshot() async {
    try {
      final result = await _channel.invokeMethod<Map>('getHardwareSnapshot');
      final map = Map<String, dynamic>.from(result ?? {});
      return HardwareSnapshot(
        cpuUsage: (map['cpuUsage'] as num?)?.toDouble() ?? 0.0,
        ramUsedMb: map['ramUsedMb'] as int? ?? 0,
        ramTotalMb: map['ramTotalMb'] as int? ?? 0,
        batteryLevel: (map['batteryLevel'] as num?)?.toDouble(),
        recordedAt: DateTime.now(),
      );
    } catch (_) {
      return HardwareSnapshot(
        cpuUsage: 0,
        ramUsedMb: 0,
        ramTotalMb: 0,
        recordedAt: DateTime.now(),
      );
    }
  }
}
