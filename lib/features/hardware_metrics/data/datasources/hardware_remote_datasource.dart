import 'package:Sentri/core/api/api_consumer.dart';
import '../../domain/entities/hardware_snapshot.dart';

class HardwareRemoteDataSource {
  final ApiConsumer _api;
  HardwareRemoteDataSource(this._api);

  Future<void> postSnapshot(HardwareSnapshot snapshot) async {
    await _api.post('/hardware-metrics', body: snapshot.toJson());
  }

  Future<List<HardwareSnapshot>> getHistory({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final params = <String, dynamic>{
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };
    final response = await _api.get('/hardware-metrics', queryParameters: params);
    return (response as List<dynamic>)
        .map((e) => HardwareSnapshot.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
