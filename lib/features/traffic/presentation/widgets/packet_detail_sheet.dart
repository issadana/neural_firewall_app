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
import 'package:Sentri/features/settings/presentation/models/ai_model_catalog.dart';
import 'package:Sentri/features/traffic/domain/entities/packet_record.dart';

final _timeFmtMs = DateFormat('h:mm:ss a');

class PacketDetailSheet extends StatelessWidget {
  final PacketRecord record;
  const PacketDetailSheet({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SingleChildScrollView(
      padding: PaddingManager.paddingLTRB20_12_20_32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: DecorationManager.sheetHandle(colors),
            ),
          ),
          SpacesManager.h20,
          Row(
            children: [
              StatusBadge(record.status),
              const Spacer(),
              Text(
                _timeFmtMs.format(record.timestamp),
                style: getRegularTextStyle(
                  fontSize: FontSizesManager.s12,
                  color: colors.textDisabled,
                  family: 'monospace',
                ),
              ),
            ],
          ),
          SpacesManager.h20,
          _DetailSection('CONNECTION', [
            _DetailRow('Source', '${record.srcIp}:${record.srcPort}'),
            _DetailRow('Destination', '${record.dstIp}:${record.dstPort}'),
            if (record.label.isNotEmpty)
              _DetailRow(
                'Service',
                record.label,
                valueColor: ColorManager.serviceCyan,
              ),
          ], colors),
          SpacesManager.h12,
          _DetailSection('PACKET INFO', [
            _DetailRow('Protocol', _protocolName(record.protocol)),
            _DetailRow('Size', _formatSize(record.sizeBytes)),
          ], colors),
          SpacesManager.h12,
          _DetailSection('THREAT SCORES', _scoreRows(colors), colors),
          if (record.isBlacklisted) ...[
            SpacesManager.h12,
            _DetailSection('BLOCKS', [
              _DetailRow(
                'Blacklisted',
                'Yes',
                valueColor: AppColors.statusDanger,
              ),
            ], colors),
          ],
          SpacesManager.h30,
        ],
      ),
    );
  }

  /// One row per model that scored this packet, in catalog (display) order.
  /// The model that drove the block/warn decision is emphasized. Falls back to
  /// the legacy Brute Force / DoS rows for records captured before per-model
  /// scores were tracked.
  List<Widget> _scoreRows(AppThemeColors colors) {
    final scores = record.modelScores;

    if (scores.isEmpty) {
      return [
        _DetailRow(
          'Brute Force',
          '${(record.bruteForceScore * 100).toStringAsFixed(1)}%',
          valueColor: _scoreColor(record.bruteForceScore * 100, colors),
        ),
        _DetailRow(
          'DoS / DDoS',
          '${(record.dosScore * 100).toStringAsFixed(1)}%',
          valueColor: _scoreColor(record.dosScore * 100, colors),
        ),
      ];
    }

    return [
      for (final model in kAiModelCatalog)
        if (scores.containsKey(model.id))
          _DetailRow(
            model.name,
            '${(scores[model.id]! * 100).toStringAsFixed(1)}%',
            valueColor: _scoreColor(scores[model.id]! * 100, colors),
            emphasize: model.id == record.selectedModel,
          ),
    ];
  }

  Color _scoreColor(double pct, AppThemeColors colors) => pct >= 20
      ? AppColors.statusDanger
      : pct >= 10
      ? AppColors.statusWarning
      : colors.textDisabled;

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

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  final AppThemeColors colors;
  const _DetailSection(this.title, this.rows, this.colors);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getBoldTextStyle(
            fontSize: FontSizesManager.s10,
            color: colors.textDisabled,
            letterSpacing: 1.4,
          ),
        ),
        SpacesManager.h8,
        Container(
          decoration: DecorationManager.surfaceCardBare(
            colors,
            radius: BorderRadiusManager.radiusAll12,
          ),
          child: Column(
            children: rows
                .expand(
                  (row) => [
                    row,
                    if (row != rows.last)
                      Container(
                        height: 0.5,
                        color: colors.borderColor,
                        margin: PaddingManager.paddingHorizontal12,
                      ),
                  ],
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  /// When true the row is highlighted as the decisive one (e.g. the model that
  /// triggered the block): the label is shown in the value's accent colour with
  /// a leading dot.
  final bool emphasize;

  const _DetailRow(
    this.label,
    this.value, {
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final labelColor = emphasize
        ? (valueColor ?? colors.textPrimary)
        : colors.textSecondary;
    return Padding(
      padding: PaddingManager.paddingH14V10,
      child: Row(
        children: [
          if (emphasize) ...[
            Icon(Icons.circle, size: 7, color: labelColor),
            SpacesManager.w6,
          ],
          Text(
            label,
            style: emphasize
                ? getSemiBoldTextStyle(
                    fontSize: FontSizesManager.s13,
                    color: labelColor,
                  )
                : getRegularTextStyle(
                    fontSize: FontSizesManager.s13,
                    color: labelColor,
                  ),
          ),
          const Spacer(),
          Text(
            value,
            style: getSemiBoldTextStyle(
              fontSize: FontSizesManager.s13,
              color: valueColor ?? colors.textPrimary,
              family: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
