import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/packet_record/packet_record.dart';

final _timeFmt   = DateFormat('h:mm a');
final _timeFmtMs = DateFormat('h:mm:ss a');

class TrafficRow extends StatelessWidget {
  final PacketRecord record;
  const TrafficRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(record.status);
    final bgColor     = _cardBackground(record.status);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
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
                      _headerRow(),
                      const SizedBox(height: 5),
                      _addressRow(),
                      const SizedBox(height: 5),
                      _metaRow(),
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

  Widget _headerRow() => Row(
        children: [
          _StatusBadge(record.status),
          const Spacer(),
          Text(
            _timeFmt.format(record.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDisabled,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );

  Widget _addressRow() => Row(
        children: [
          Expanded(
            child: Text(
              '${record.srcIp}:${record.srcPort}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded, size: 11, color: AppColors.textDisabled),
          ),
          Expanded(
            child: Text(
              '${record.dstIp}:${record.dstPort}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDisabled,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _metaRow() => Row(
        children: [
          _ProtoChip(_protocolName(record.protocol)),
          const SizedBox(width: 8),
          Text(
            _formatSize(record.sizeBytes),
            style: const TextStyle(fontSize: 11, color: AppColors.textDisabled),
          ),
          const Spacer(),
          _ScoreTag('BF', record.bruteForceScore * 100),
          const SizedBox(width: 8),
          _ScoreTag('DoS', record.dosScore * 100),
        ],
      );

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderColor, width: 0.5),
      ),
      builder: (_) => _PacketDetailSheet(record: record),
    );
  }

  Color _statusColor(PacketStatus status) => switch (status) {
        PacketStatus.aiBlock => AppColors.statusDanger,
        PacketStatus.warn    => AppColors.statusWarning,
        PacketStatus.safe    => AppColors.statusNormal,
        PacketStatus.tcp     => AppColors.accentBlue,
        PacketStatus.quic    => const Color(0xFFAA77FF),
        PacketStatus.ping    => AppColors.statusWarning,
        PacketStatus.err     => AppColors.textDisabled,
      };

  Color _cardBackground(PacketStatus status) => switch (status) {
        PacketStatus.aiBlock => AppColors.statusDanger.withValues(alpha: 0.08),
        PacketStatus.warn    => AppColors.statusWarning.withValues(alpha: 0.05),
        _                    => AppColors.surfaceLight,
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

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

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
      PacketStatus.err     => ('ERR',    AppColors.textDisabled),
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
  const _ScoreTag(this.label, this.pct);

  @override
  Widget build(BuildContext context) {
    final color = pct >= 20
        ? AppColors.statusDanger
        : pct >= 10
            ? AppColors.statusWarning
            : AppColors.textDisabled;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 10, color: AppColors.textDisabled),
        ),
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

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────

class _PacketDetailSheet extends StatelessWidget {
  final PacketRecord record;
  const _PacketDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
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
                style: const TextStyle(
                  color: AppColors.textDisabled,
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
          ]),
          const SizedBox(height: 12),
          _DetailSection('PACKET INFO', [
            _DetailRow('Protocol', _protocolName(record.protocol)),
            _DetailRow('Size', _formatSize(record.sizeBytes)),
          ]),
          const SizedBox(height: 12),
          _DetailSection('THREAT SCORES', [
            _DetailRow(
              'Brute Force',
              '${(record.bruteForceScore * 100).toStringAsFixed(1)}%',
              valueColor: _scoreColor(record.bruteForceScore * 100),
            ),
            _DetailRow(
              'DoS / DDoS',
              '${(record.dosScore * 100).toStringAsFixed(1)}%',
              valueColor: _scoreColor(record.dosScore * 100),
            ),
          ]),
          if (record.isBlacklisted || record.isAclBlocked) ...[
            const SizedBox(height: 12),
            _DetailSection('BLOCKS', [
              if (record.isBlacklisted)
                _DetailRow('Blacklisted', 'Yes', valueColor: AppColors.statusDanger),
              if (record.isAclBlocked)
                _DetailRow('ACL Blocked', 'Yes', valueColor: AppColors.statusDanger),
            ]),
          ],
        ],
      ),
    );
  }

  Color _scoreColor(double pct) => pct >= 20
      ? AppColors.statusDanger
      : pct >= 10
          ? AppColors.statusWarning
          : AppColors.textDisabled;

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
  const _DetailSection(this.title, this.rows);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
          ),
          child: Column(
            children: rows
                .expand((row) => [
                      row,
                      if (row != rows.last)
                        Container(
                          height: 0.5,
                          color: AppColors.borderColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textPrimary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
