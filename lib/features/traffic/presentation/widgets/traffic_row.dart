import 'package:Sentri/features/traffic/presentation/widgets/packet_detail_sheet.dart';
import 'package:Sentri/features/traffic/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:Sentri/features/settings/presentation/models/ai_model_catalog.dart';
import 'package:Sentri/features/traffic/domain/entities/packet_record.dart';

final _timeFmt   = DateFormat('h:mm a');

/// Compact tag labels for the traffic-log row, keyed by catalog model id.
const _kModelShortLabels = <String, String>{
  'bruteForce': 'BF',
  'dos': 'DoS',
  'dosHulk': 'HULK',
  'loic': 'LOIC',
  'hoic': 'HOIC',
};

class TrafficRow extends StatelessWidget {
  final PacketRecord record;
  const TrafficRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = _statusColor(record.status, colors);
    final bgColor     = _cardBackground(record.status, colors);

    return AppPressable(
      onPressed: () => _showDetail(context),
      child: Container(
        margin: PaddingManager.paddingH12V3,
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
                  padding: PaddingManager.paddingH12V9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _headerRow(colors),
                      SpacesManager.h5,
                      _addressRow(colors),
                      SpacesManager.h5,
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
            SpacesManager.w6,
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
            padding: PaddingManager.paddingHorizontal8,
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
          SpacesManager.w8,
          Text(
            _formatSize(record.sizeBytes),
            style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textDisabled),
          ),
          SpacesManager.w8,
          // Show a score tag for every enabled model that ran on this packet,
          // right-aligned and horizontally scrollable so 5 tags never overflow.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(children: _scoreTags(colors)),
            ),
          ),
        ],
      );

  /// One score tag per model that scored this packet, in catalog (display)
  /// order. Falls back to the legacy Brute Force / DoS pair for records
  /// captured before per-model scores were tracked.
  List<Widget> _scoreTags(AppThemeColors colors) {
    final scores = record.modelScores;

    final entries = <MapEntry<String, double>>[];
    if (scores.isEmpty) {
      entries.add(MapEntry('bruteForce', record.bruteForceScore));
      entries.add(MapEntry('dos', record.dosScore));
    } else {
      for (final model in kAiModelCatalog) {
        if (scores.containsKey(model.id)) {
          entries.add(MapEntry(model.id, scores[model.id]!));
        }
      }
    }

    final tags = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) tags.add(SpacesManager.w8);
      tags.add(_ScoreTag(
        _kModelShortLabels[entries[i].key] ?? entries[i].key,
        entries[i].value * 100,
        colors,
        emphasize: entries[i].key == record.selectedModel,
      ));
    }
    return tags;
  }

  void _showDetail(BuildContext context) {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
        PacketStatus.system  => ColorManager.serviceCyan,
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
      padding: PaddingManager.paddingH6V1,
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
      padding: PaddingManager.paddingH6V1,
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

  /// Whether this model drove the block/warn decision for the packet.
  final bool emphasize;
  const _ScoreTag(this.label, this.pct, this.colors, {this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final color = pct >= 20
        ? AppColors.statusDanger
        : pct >= 10
            ? AppColors.statusWarning
            : colors.textDisabled;

    final labelColor = emphasize ? colors.textPrimary : colors.textDisabled;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: emphasize
              ? getBoldTextStyle(fontSize: FontSizesManager.s10, color: labelColor)
              : getRegularTextStyle(fontSize: FontSizesManager.s10, color: labelColor),
        ),
        SpacesManager.w2,
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: pct >= 10 || emphasize
              ? getBoldTextStyle(fontSize: FontSizesManager.s10, color: color)
              : getRegularTextStyle(fontSize: FontSizesManager.s10, color: color),
        ),
      ],
    );
  }
}
