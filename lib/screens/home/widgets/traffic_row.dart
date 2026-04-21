import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/packet_record/packet_record.dart';

final _timeFmt = DateFormat('HH:mm:ss');

class TrafficRow extends StatelessWidget {
  final PacketRecord record;
  const TrafficRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bg = _rowBackground(record.status);

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          _statusCell(record.status),
          _cell(_timeFmt.format(record.timestamp), 60),
          _cell('${record.srcIp}:${record.srcPort}', 125),
          _cell('${record.dstIp}:${record.dstPort}', 125),
          _cell(_protocolName(record.protocol), 80),
          _cell(_formatSize(record.sizeBytes), 44),
          _scoreCell(record.bruteForceScore * 100),
          _scoreCell(record.dosScore * 100),
        ],
      ),
    );
  }

  Color? _rowBackground(PacketStatus status) => switch (status) {
        PacketStatus.aiBlock => AppColors.statusDanger.withValues(alpha: 0.12),
        PacketStatus.warn => AppColors.statusWarning.withValues(alpha: 0.08),
        _ => null,
      };

  Widget _statusCell(PacketStatus status) {
    final (text, color) = switch (status) {
      PacketStatus.aiBlock => ('🚫 BLOCK', AppColors.statusDanger),
      PacketStatus.warn => ('⚠️ WARN', AppColors.statusWarning),
      PacketStatus.safe => ('✅ SAFE', AppColors.statusNormal),
      PacketStatus.tcp => ('🔵 TCP', AppColors.accentBlue),
      PacketStatus.quic => ('🟣 QUIC', const Color(0xFFAA77FF)),
      PacketStatus.ping => ('🟡 PING', AppColors.statusWarning),
      PacketStatus.err => ('❌ ERR', AppColors.textDisabled),
    };

    return SizedBox(
      width: 80,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _cell(String text, double width) {
    return SizedBox(
      width: width,
      child: AutoSizeText(
        text,
        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
        maxLines: 1,
        minFontSize: 12,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _scoreCell(double pct) {
    final color = pct >= 20
        ? AppColors.statusDanger
        : pct >= 10
            ? AppColors.statusWarning
            : AppColors.textDisabled;

    return SizedBox(
      width: 38,
      child: Text(
        '${pct.toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 15,
          fontWeight: pct >= 10 ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  String _protocolName(Protocol protocol) => switch (protocol) {
        Protocol.tcp => 'TCP',
        Protocol.udp => 'UDP',
        Protocol.icmp => 'ICMP',
        Protocol.unknown => 'OTHER',
      };

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    return '${(bytes / 1024).toStringAsFixed(1)}K';
  }
}
