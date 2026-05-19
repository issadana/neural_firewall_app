import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            title: const Text('Settings'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: AppColors.borderColor),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const BouncingScrollPhysics(),
            children: [
              _SectionHeader(label: 'Detection Thresholds'),
              _ThresholdSlider(
                label: 'Block Threshold',
                description:
                    'Packets scoring above this are blocked and the source IP auto-blacklisted.',
                value: state.blockThreshold,
                color: AppColors.statusDanger,
                onChanged: (v) => context.read<SettingsCubit>().setBlockThreshold(v),
              ),
              _ThresholdSlider(
                label: 'Warn Threshold',
                description:
                    'Packets between warn and block threshold are flagged as warnings.',
                value: state.warnThreshold,
                color: AppColors.statusWarning,
                onChanged: (v) => context.read<SettingsCubit>().setWarnThreshold(v),
              ),
              const _Divider(),
              _SectionHeader(label: 'Heuristics'),
              _ToggleTile(
                icon: Icons.speed_rounded,
                label: 'Packet Flood Detection',
                subtitle: 'Block sources exceeding packet/sec limit',
                value: state.floodDetection,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleFloodDetection(v),
              ),
              if (state.floodDetection)
                _NumberField(
                  label: 'Flood Packet/sec limit',
                  value: state.floodPktPerSec,
                  onSubmitted: (v) =>
                      context.read<SettingsCubit>().setFloodPktPerSec(v),
                ),
              _ToggleTile(
                icon: Icons.sync_alt_rounded,
                label: 'SYN Flood Detection',
                subtitle: 'Detect TCP SYN flood attacks',
                value: state.synFloodDetection,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleSynFloodDetection(v),
              ),
              if (state.synFloodDetection)
                _NumberField(
                  label: 'SYN Flood Packet/sec limit',
                  value: state.synFloodPerSec,
                  onSubmitted: (v) =>
                      context.read<SettingsCubit>().setSynFloodPerSec(v),
                ),
              const _Divider(),
              _SectionHeader(label: 'ML Models'),
              _ToggleTile(
                icon: Icons.psychology_rounded,
                label: 'Brute Force Detector',
                subtitle: 'On-device model for brute force attack detection',
                value: state.bfModelEnabled,
                onChanged: (v) => context.read<SettingsCubit>().toggleBfModel(v),
              ),
              _ToggleTile(
                icon: Icons.bolt_rounded,
                label: 'DoS Specialist',
                subtitle: 'On-device model for denial-of-service detection',
                value: state.dosModelEnabled,
                onChanged: (v) => context.read<SettingsCubit>().toggleDosModel(v),
              ),
              const _Divider(),
              _SectionHeader(label: 'Log Settings'),
              _NumberField(
                label: 'Max Log Entries',
                value: state.maxLogEntries,
                onSubmitted: (v) =>
                    context.read<SettingsCubit>().setMaxLogEntries(v),
              ),
              const _Divider(),
              _SectionHeader(label: 'About'),
              _AboutTile(state: state),
              const _Divider(),
              _SectionHeader(label: 'Account'),
              const _LogoutTile(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5A8BFF), AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.borderColor,
    );
  }
}

// ── Threshold Slider ──────────────────────────────────────────────────────────

class _ThresholdSlider extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ThresholdSlider({
    required this.label,
    required this.description,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: 0.05,
              max: 0.95,
              divisions: 18,
              onChanged: onChanged,
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: SwitchListTile(
        secondary: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.borderColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value ? AppColors.primary : AppColors.textDisabled,
            size: 18,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: value ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

// ── Number Field ──────────────────────────────────────────────────────────────

class _NumberField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onSubmitted;

  const _NumberField({required this.label, required this.value, required this.onSubmitted});

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null && parsed > 0) {
      widget.onSubmitted(parsed);
    } else {
      _controller.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) => _submit(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── About Tile ────────────────────────────────────────────────────────────────

class _AboutTile extends StatelessWidget {
  final SettingsState state;
  const _AboutTile({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.navyLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'v1.0.0  ·  AI-Powered NIDS',
                    style: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 0.5, color: AppColors.borderColor),
          const SizedBox(height: 12),
          _AboutRow(label: 'BF Model features', value: '4'),
          _AboutRow(label: 'DoS Model features', value: '5'),
          _AboutRow(
            label: 'Block threshold',
            value: '${(state.blockThreshold * 100).toStringAsFixed(0)}%',
          ),
          _AboutRow(
            label: 'Warn threshold',
            value: '${(state.warnThreshold * 100).toStringAsFixed(0)}%',
          ),
          _AboutRow(label: 'Max log entries', value: '${state.maxLogEntries}'),
        ],
      ),
    );
  }
}

// ── Logout Tile ───────────────────────────────────────────────────────────────

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusDanger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout_rounded, color: AppColors.statusDanger, size: 18),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.statusDanger,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            context.read<AuthCubit>().signOut();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ── About Row ─────────────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
