import 'package:Sentri/features/traffic/presentation/widgets/packet_detail_sheet.dart';
import 'package:Sentri/features/traffic/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/traffic/domain/entities/packet_record.dart';

final _timeFmt   = DateFormat('h:mm a');

class TrafficRow extends StatelessWidget {
  final PacketRecord record;
  const TrafficRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = _statusColor(record.status, colors);
    final bgColor     = _cardBackground(record.status, colors);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: DecorationManager.trafficRow(bgColor, colors),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: DecorationManager.colorBar(
                  statusColor,
                  radius: BorderRadiusManager.leftRounded12,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _headerRow(colors),
                      const SizedBox(height: 5),
                      _addressRow(colors),
                      const SizedBox(height: 5),
                      _metaRow(colors),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerRow(AppThemeColors colors) => Row(
        children: [
          StatusBadge(record.status),
          if (record.label.isNotEmpty) ...[
            const SizedBox(width: 6),
            _ServiceChip(record.label),
          ],
          const Spacer(),
          Text(
            _timeFmt.format(record.timestamp),
            style: getRegularTextStyle(
              fontSize: FontSizesManager.s11,
              color: colors.textDisabled,
              family: 'monospace',
            ),
          ),
        ],
      );

  Widget _addressRow(AppThemeColors colors) => Row(
        children: [
          Expanded(
            child: Text(
              '${record.srcIp}:${record.srcPort}',
              style: getRegularTextStyle(
                fontSize: FontSizesManager.s12,
                color: colors.textSecondary,
                family: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded, size: 11, color: colors.textDisabled),
          ),
          Expanded(
            child: Text(
              '${record.dstIp}:${record.dstPort}',
              textAlign: TextAlign.right,
              style: getRegularTextStyle(
                fontSize: FontSizesManager.s12,
                color: colors.textDisabled,
                family: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _metaRow(AppThemeColors colors) => Row(
        children: [
          _ProtoChip(_protocolName(record.protocol)),
          const SizedBox(width: 8),
          Text(
            _formatSize(record.sizeBytes),
            style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textDisabled),
          ),
          const Spacer(),
          _ScoreTag('BF', record.bruteForceScore * 100, colors),
          const SizedBox(width: 8),
          _ScoreTag('DoS', record.dosScore * 100, colors),
        ],
      );

  void _showDetail(BuildContext context) {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusManager.topRounded24,
        side: BorderSide(color: colors.borderColor, width: 0.5),
      ),
      builder: (_) => PacketDetailSheet(record: record),
    );
  }

  Color _statusColor(PacketStatus status, AppThemeColors colors) => switch (status) {
        PacketStatus.aiBlock => AppColors.statusDanger,
        PacketStatus.warn    => AppColors.statusWarning,
        PacketStatus.safe    => AppColors.statusNormal,
        PacketStatus.tcp     => AppColors.accentBlue,
        PacketStatus.quic    => ColorManager.quicPurple,
        PacketStatus.ping    => AppColors.statusWarning,
        PacketStatus.err     => colors.textDisabled,
      };

  Color _cardBackground(PacketStatus status, AppThemeColors colors) => switch (status) {
        PacketStatus.aiBlock => AppColors.statusDanger.withValues(alpha: 0.08),
        PacketStatus.warn    => AppColors.statusWarning.withValues(alpha: 0.05),
        _                    => colors.surfaceLight,
      };

  String _protocolName(Protocol protocol) => switch (protocol) {
        Protocol.tcp     => 'TCP',
        Protocol.udp     => 'UDP',
        Protocol.icmp    => 'ICMP',
        Protocol.unknown => 'OTHER',
      };

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    return '${(bytes / 1024).toStringAsFixed(1)}K';
  }
}

class _ProtoChip extends StatelessWidget {
  final String label;
  const _ProtoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: DecorationManager.protoChip,
      child: Text(
        label,
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s10,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  const _ServiceChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: DecorationManager.serviceChip,
      child: Text(
        label,
        style: getSemiBoldTextStyle(
          fontSize: FontSizesManager.s10,
          color: ColorManager.serviceCyan,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ScoreTag extends StatelessWidget {
  final String label;
  final double pct;
  final AppThemeColors colors;
  const _ScoreTag(this.label, this.pct, this.colors);

  @override
  Widget build(BuildContext context) {
    final color = pct >= 20
        ? AppColors.statusDanger
        : pct >= 10
            ? AppColors.statusWarning
            : colors.textDisabled;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:', style: getRegularTextStyle(fontSize: FontSizesManager.s10, color: colors.textDisabled)),
        const SizedBox(width: 2),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: pct >= 10
              ? getBoldTextStyle(fontSize: FontSizesManager.s10, color: color)
              : getRegularTextStyle(fontSize: FontSizesManager.s10, color: color),
        ),
      ],
    );
  }
}
