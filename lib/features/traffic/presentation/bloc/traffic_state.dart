import 'dart:collection';

import 'package:equatable/equatable.dart';

import '../../domain/entities/packet_record.dart';

class TrafficState extends Equatable {
  final ListQueue<PacketRecord> records;
  final List<double> sparklineData;

  const TrafficState({
    required this.records,
    required this.sparklineData,
  });

  @override
  List<Object?> get props => [records, sparklineData];
}
