import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/traffic/domain/entities/packet_record.dart';

final _timeFmt   = DateFormat('h:mm a');
final _timeFmtMs = DateFormat('h:mm:ss a');

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
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderColor, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
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
          _StatusBadge(record.status),
          const Spacer(),
          Text(
            _timeFmt.format(record.timestamp),
            style: TextStyle(
              fontSize: 11,
              color: colors.textDisabled,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );

  Widget _addressRow(AppThemeColors colors) => Row(
        children: [
          Expanded(
            child: Text(
              '${record.srcIp}:${record.srcPort}',
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
                fontFamily: 'monospace',
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
              style: TextStyle(
                fontSize: 12,
                color: colors.textDisabled,
                fontFamily: 'monospace',
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
            style: TextStyle(fontSize: 11, color: colors.textDisabled),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: colors.borderColor, width: 0.5),
      ),
      builder: (_) => _PacketDetailSheet(record: record),
    );
  }

  Color _statusColor(PacketStatus status, AppThemeColors colors) => switch (status) {
        PacketStatus.aiBlock => AppColors.statusDanger,
        PacketStatus.warn    => AppColors.statusWarning,
        PacketStatus.safe    => AppColors.statusNormal,
        PacketStatus.tcp     => AppColors.accentBlue,
        PacketStatus.quic    => const Color(0xFFAA77FF),
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

class _StatusBadge extends StatelessWidget {
  final PacketStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      PacketStatus.aiBlock => ('BLOCK',  AppColors.statusDanger),
      PacketStatus.warn    => ('WARN',   AppColors.statusWarning),
      PacketStatus.safe    => ('SAFE',   AppColors.statusNormal),
      PacketStatus.tcp     => ('TCP',    AppColors.accentBlue),
      PacketStatus.quic    => ('QUIC',   const Color(0xFFAA77FF)),
      PacketStatus.ping    => ('PING',   AppColors.statusWarning),
      PacketStatus.err     => ('ERR',    context.appColors.textDisabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ProtoChip extends StatelessWidget {
  final String label;
  const _ProtoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
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
        Text('$label:', style: TextStyle(fontSize: 10, color: colors.textDisabled)),
        const SizedBox(width: 2),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: pct >= 10 ? FontWeight.w700 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PacketDetailSheet extends StatelessWidget {
  final PacketRecord record;
  const _PacketDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatusBadge(record.status),
              const Spacer(),
              Text(
                _timeFmtMs.format(record.timestamp),
                style: TextStyle(
                  color: colors.textDisabled,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailSection('CONNECTION', [
            _DetailRow('Source', '${record.srcIp}:${record.srcPort}'),
            _DetailRow('Destination', '${record.dstIp}:${record.dstPort}'),
          ], colors),
          const SizedBox(height: 12),
          _DetailSection('PACKET INFO', [
            _DetailRow('Protocol', _protocolName(record.protocol)),
            _DetailRow('Size', _formatSize(record.sizeBytes)),
          ], colors),
          const SizedBox(height: 12),
          _DetailSection('THREAT SCORES', [
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
          ], colors),
          if (record.isBlacklisted || record.isAclBlocked) ...[
            const SizedBox(height: 12),
            _DetailSection('BLOCKS', [
              if (record.isBlacklisted)
                _DetailRow('Blacklisted', 'Yes', valueColor: AppColors.statusDanger),
              if (record.isAclBlocked)
                _DetailRow('ACL Blocked', 'Yes', valueColor: AppColors.statusDanger),
            ], colors),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Color _scoreColor(double pct, AppThemeColors colors) => pct >= 20
      ? AppColors.statusDanger
      : pct >= 10
          ? AppColors.statusWarning
          : colors.textDisabled;

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
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.textDisabled,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.borderColor, width: 0.5),
          ),
          child: Column(
            children: rows
                .expand((row) => [
                      row,
                      if (row != rows.last)
                        Container(
                          height: 0.5,
                          color: colors.borderColor,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                    ])
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
  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? colors.textPrimary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
