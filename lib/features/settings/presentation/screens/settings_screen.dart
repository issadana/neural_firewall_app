import 'package:Sentri/core/constants/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:Sentri/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:Sentri/features/settings/presentation/models/ai_model_catalog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            centerTitle: false,
            title: const Text('Settings'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: colors.borderColor),
            ),
          ),
          body: ListView(
            padding: PaddingManager.paddingVertical8,
            physics: const BouncingScrollPhysics(),
            children: [
              _SectionHeader(label: 'Appearance'),
              _ToggleTile(
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                subtitle: 'Switch between dark and light theme',
                value: state.darkMode,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleDarkMode(v),
              ),
              const _Divider(),
              _SectionHeader(label: 'Detection Thresholds'),
              _ThresholdSlider(
                label: 'Block Threshold',
                description:
                    'Packets scoring above this are blocked and the source IP auto-blacklisted.',
                value: state.blockThreshold,
                color: AppColors.statusDanger,
                onChanged: (v) =>
                    context.read<SettingsCubit>().setBlockThreshold(v),
              ),
              _ThresholdSlider(
                label: 'Warn Threshold',
                description:
                    'Packets between warn and block threshold are flagged as warnings.',
                value: state.warnThreshold,
                color: AppColors.statusWarning,
                onChanged: (v) =>
                    context.read<SettingsCubit>().setWarnThreshold(v),
              ),
              const _Divider(),
              _AiProtectionHeader(
                activeCount:
                    state.activeModelCount(kAiModelCatalog.map((m) => m.id)),
                total: kAiModelCatalog.length,
              ),
              for (final model in kAiModelCatalog)
                _AiModelCard(
                  model: model,
                  enabled: state.isModelEnabled(model.id),
                  onChanged: (v) =>
                      context.read<SettingsCubit>().toggleModel(model.id, v),
                  onTap: () => _showModelDetails(context, model),
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
              SpacesManager.h40,
            ],
          ),
        );
      },
    );
  }

  void _showModelDetails(BuildContext context, AiModelInfo model) {
    final cubit = context.read<SettingsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AiModelDetailSheet(model: model),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: PaddingManager.paddingLTRB16_20_16_8,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: DecorationManager.sectionAccentBar,
          ),
          SpacesManager.w8,
          Text(
            label.toUpperCase(),
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: colors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Richer header for the AI protection section, with a live "X of Y active" pill.
class _AiProtectionHeader extends StatelessWidget {
  final int activeCount;
  final int total;
  const _AiProtectionHeader({required this.activeCount, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: PaddingManager.paddingLTRB16_20_16_8,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: DecorationManager.sectionAccentBar,
          ),
          SpacesManager.w8,
          Text(
            'AI PROTECTION',
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: colors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          Container(
            padding: PaddingManager.paddingH10V4,
            decoration: DecorationManager.coloredChip(
              AppColors.accent,
              BorderRadiusManager.radiusAll20,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 12,
                  color: AppColors.accent,
                ),
                SpacesManager.w4,
                Text(
                  '$activeCount of $total active',
                  style: getBoldTextStyle(
                    fontSize: FontSizesManager.s11,
                    color: AppColors.accent,
                  ),
                ),
              ],
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
      margin: PaddingManager.paddingHorizontal16,
      color: context.appColors.borderColor,
    );
  }
}

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
    final colors = context.appColors;
    return Container(
      margin: PaddingManager.paddingH16V5,
      padding: PaddingManager.paddingLTRB16_14_16_10,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: getSemiBoldTextStyle(
                  fontSize: FontSizesManager.s14,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: PaddingManager.paddingH10V4,
                decoration: DecorationManager.tinted(
                  color,
                  BorderRadiusManager.radiusAll20,
                ),
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: getBoldTextStyle(
                    fontSize: FontSizesManager.s13,
                    color: color,
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
            style: getRegularTextStyle(
              fontSize: FontSizesManager.s12,
              color: colors.textDisabled,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final colors = context.appColors;
    return Container(
      margin: PaddingManager.paddingH16V5,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll16,
      ),
      child: SwitchListTile(
        secondary: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: DecorationManager.toggleIcon(colors, active: value),
          child: Icon(
            icon,
            color: value ? AppColors.primary : colors.textDisabled,
            size: 18,
          ),
        ),
        title: Text(
          label,
          style: getSemiBoldTextStyle(
            fontSize: FontSizesManager.s14,
            color: value ? colors.textPrimary : colors.textSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: getRegularTextStyle(
            fontSize: FontSizesManager.s12,
            color: colors.textDisabled,
          ),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: PaddingManager.paddingH16V4,
      ),
    );
  }
}

/// Catchy, tappable card representing one AI protection model. Tapping the body
/// opens a details popup; the trailing switch toggles protection on/off.
class _AiModelCard extends StatelessWidget {
  final AiModelInfo model;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;

  const _AiModelCard({
    required this.model,
    required this.enabled,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = model.accent;
    return Container(
      margin: PaddingManager.paddingH16V5,
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadiusManager.radiusAll20,
        border: Border.all(
          color: enabled ? accent.withValues(alpha: 0.45) : colors.borderColor,
          width: enabled ? 1 : 0.5,
        ),
        boxShadow: colors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadiusManager.radiusAll20,
          child: Padding(
            padding: PaddingManager.paddingH16V12,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 46,
                  height: 46,
                  decoration: DecorationManager.tinted(
                    accent,
                    BorderRadiusManager.radiusAll14,
                    alpha: enabled ? 0.18 : 0.07,
                  ),
                  child: Icon(
                    model.icon,
                    color: enabled ? accent : colors.textDisabled,
                    size: 24,
                  ),
                ),
                SpacesManager.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              model.name,
                              style: getSemiBoldTextStyle(
                                fontSize: FontSizesManager.s15,
                                color: enabled
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                          SpacesManager.w6,
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: colors.textDisabled,
                          ),
                        ],
                      ),
                      SpacesManager.h2,
                      Text(
                        model.tagline,
                        style: getRegularTextStyle(
                          fontSize: FontSizesManager.s12,
                          color: colors.textDisabled,
                          height: 1.3,
                        ),
                      ),
                      SpacesManager.h6,
                      Row(
                        children: [
                          _MiniStat(
                            icon: Icons.verified_rounded,
                            label: '${model.accuracy} accuracy',
                            color: accent,
                          ),
                          SpacesManager.w6,
                          _MiniStat(
                            icon: Icons.memory_rounded,
                            label: 'On-device',
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SpacesManager.w8,
                Switch.adaptive(
                  value: enabled,
                  onChanged: onChanged,
                  activeTrackColor: accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tiny pill used inside model cards to show a quick fact.
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PaddingManager.paddingH8V2,
      decoration: DecorationManager.tinted(
        color,
        BorderRadiusManager.radiusAll6,
        alpha: 0.1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SpacesManager.w4,
          Text(
            label,
            style: getMediumTextStyle(
              fontSize: FontSizesManager.s11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet popup with friendly, in-depth info about a single model.
class _AiModelDetailSheet extends StatelessWidget {
  final AiModelInfo model;
  const _AiModelDetailSheet({required this.model});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = model.accent;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final enabled = state.isModelEnabled(model.id);
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            borderRadius: BorderRadiusManager.topRounded24,
            border: Border.all(color: colors.borderColor, width: 0.5),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: PaddingManager.paddingLTRB20_12_20_32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: DecorationManager.sheetHandle(colors),
                    ),
                  ),
                  SpacesManager.h20,
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: DecorationManager.tinted(
                          accent,
                          BorderRadiusManager.radiusAll16,
                          alpha: 0.18,
                        ),
                        child: Icon(model.icon, color: accent, size: 28),
                      ),
                      SpacesManager.w16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.name,
                              style: getBoldTextStyle(
                                fontSize: FontSizesManager.s20,
                                color: colors.textPrimary,
                              ),
                            ),
                            SpacesManager.h2,
                            Text(
                              model.techName,
                              style: getRegularTextStyle(
                                fontSize: FontSizesManager.s12,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SpacesManager.h16,
                  Wrap(
                    spacing: PaddingManager.p8,
                    runSpacing: PaddingManager.p8,
                    children: [
                      _DetailStat(
                        icon: Icons.verified_rounded,
                        label: 'Accuracy',
                        value: model.accuracy,
                        color: accent,
                      ),
                      _DetailStat(
                        icon: Icons.tune_rounded,
                        label: 'Signals',
                        value: '${model.features}',
                        color: accent,
                      ),
                      _DetailStat(
                        icon: Icons.memory_rounded,
                        label: 'Runs',
                        value: 'On-device',
                        color: accent,
                      ),
                    ],
                  ),
                  SpacesManager.h20,
                  Text(
                    model.overview,
                    style: getRegularTextStyle(
                      fontSize: FontSizesManager.s14,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SpacesManager.h20,
                  Text(
                    'WHAT IT PROTECTS YOU FROM',
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s11,
                      color: colors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SpacesManager.h10,
                  for (final item in model.protects)
                    Padding(
                      padding: PaddingManager.paddingVertical5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: accent,
                          ),
                          SpacesManager.w8,
                          Expanded(
                            child: Text(
                              item,
                              style: getRegularTextStyle(
                                fontSize: FontSizesManager.s14,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SpacesManager.h24,
                  _SheetToggleButton(
                    enabled: enabled,
                    accent: accent,
                    onTap: () => context
                        .read<SettingsCubit>()
                        .toggleModel(model.id, !enabled),
                  ),
                  SpacesManager.h8,
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: getSemiBoldTextStyle(
                          fontSize: FontSizesManager.s14,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: PaddingManager.paddingH12V9,
      decoration: DecorationManager.tinted(
        color,
        BorderRadiusManager.radiusAll12,
        alpha: 0.1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          SpacesManager.w6,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: getBoldTextStyle(
                  fontSize: FontSizesManager.s13,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                label,
                style: getRegularTextStyle(
                  fontSize: FontSizesManager.s10,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-width enable/disable button inside the details sheet.
class _SheetToggleButton extends StatelessWidget {
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;
  const _SheetToggleButton({
    required this.enabled,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: PaddingManager.paddingVertical16,
        decoration: BoxDecoration(
          color: enabled
              ? accent.withValues(alpha: 0.15)
              : colors.surfaceDark,
          borderRadius: BorderRadiusManager.radiusAll16,
          border: Border.all(
            color: enabled ? accent : colors.borderColor,
            width: enabled ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              enabled
                  ? Icons.shield_rounded
                  : Icons.shield_outlined,
              size: 18,
              color: enabled ? accent : colors.textSecondary,
            ),
            SpacesManager.w8,
            Text(
              enabled ? 'Protection on · Tap to turn off' : 'Turn on protection',
              style: getSemiBoldTextStyle(
                fontSize: FontSizesManager.s14,
                color: enabled ? accent : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onSubmitted;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

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
    if (old.value != widget.value &&
        _controller.text != widget.value.toString()) {
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
    final colors = context.appColors;
    return Container(
      margin: PaddingManager.paddingH16V5,
      padding: PaddingManager.paddingH16V12,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: getSemiBoldTextStyle(
                fontSize: FontSizesManager.s14,
                color: colors.textPrimary,
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
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s15,
                color: AppColors.primary,
              ),
              decoration: DecorationManager.inputField(
                colors,
                radius: BorderRadiusManager.radiusAll10,
                isDense: true,
                contentPadding: PaddingManager.paddingH8V8,
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

class _AboutTile extends StatelessWidget {
  final SettingsState state;
  const _AboutTile({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final activeModels =
        state.activeModelCount(kAiModelCatalog.map((m) => m.id));
    return Container(
      margin: PaddingManager.paddingH16V5,
      padding: PaddingManager.paddingAll16,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: DecorationManager.aboutLogo(colors),
                child: ClipRRect(
                  borderRadius: BorderRadiusManager.radiusAll11,
                  child: Image.asset(AssetsManager.logo, fit: BoxFit.contain),
                ),
              ),
              SpacesManager.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s16,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'v${AppConstants.appVersion}  ·  AI-Powered NIDS',
                    style: getRegularTextStyle(
                      fontSize: FontSizesManager.s12,
                      color: colors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SpacesManager.h16,
          Container(height: 0.5, color: colors.borderColor),
          SpacesManager.h12,
          _AboutRow(
            label: 'AI models active',
            value: '$activeModels / ${kAiModelCatalog.length}',
          ),
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

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: PaddingManager.paddingH16V5,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll16,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: DecorationManager.tinted(
            AppColors.statusDanger,
            BorderRadiusManager.radiusAll10,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: AppColors.statusDanger,
            size: 18,
          ),
        ),
        title: Text(
          'Sign Out',
          style: getSemiBoldTextStyle(
            fontSize: FontSizesManager.s14,
            color: AppColors.statusDanger,
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
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.statusDanger,
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            context.read<AuthCubit>().signOut();
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusManager.radiusAll16,
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingManager.paddingVertical5,
      child: Row(
        children: [
          Text(
            label,
            style: getRegularTextStyle(
              fontSize: FontSizesManager.s13,
              color: context.appColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
