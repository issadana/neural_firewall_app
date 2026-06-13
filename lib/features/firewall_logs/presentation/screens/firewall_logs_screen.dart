import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../bloc/firewall_logs_cubit.dart';
import '../widgets/log_tile.dart';
import '../widgets/threat_filter_bar.dart';

class FirewallLogsScreen extends StatefulWidget {
  const FirewallLogsScreen({super.key});

  @override
  State<FirewallLogsScreen> createState() => _FirewallLogsScreenState();
}

class _FirewallLogsScreenState extends State<FirewallLogsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    context.read<FirewallLogsCubit>().loadLogs(refresh: true);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<FirewallLogsCubit>().loadLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text('Firewall Logs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.borderColor),
        ),
      ),
      body: BlocBuilder<FirewallLogsCubit, FirewallLogsState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 8),
              ThreatFilterBar(
                selectedAction: state.filterAction,
                onActionChanged: (action) =>
                    context.read<FirewallLogsCubit>().applyFilters(action: action),
                onClear: () => context.read<FirewallLogsCubit>().clearFilters(),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FirewallLogsState state) {
    if (state.status == FirewallLogsStatus.initial ||
        (state.status == FirewallLogsStatus.loading && state.logs.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == FirewallLogsStatus.error && state.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.statusDanger, size: 40),
            const SizedBox(height: 12),
            Text(state.errorMessage ?? 'Failed to load logs',
                style: TextStyle(color: context.appColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<FirewallLogsCubit>().loadLogs(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, color: context.appColors.textDisabled, size: 48),
            const SizedBox(height: 12),
            Text('No logs found',
                style: getRegularTextStyle(fontSize: FontSizesManager.s15, color: context.appColors.textMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FirewallLogsCubit>().loadLogs(refresh: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: state.logs.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.logs.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return LogTile(log: state.logs[index]);
        },
      ),
    );
  }
}
