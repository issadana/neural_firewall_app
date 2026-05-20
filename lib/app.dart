import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/theme/app_theme.dart';
import 'package:Sentri/features/acl/presentation/screens/acl_screen.dart';
import 'package:Sentri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:Sentri/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:Sentri/features/blacklist/presentation/bloc/blacklist_cubit.dart';
import 'package:Sentri/features/blacklist/presentation/screens/blacklist_screen.dart';
import 'package:Sentri/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:Sentri/features/settings/presentation/screens/settings_screen.dart';
import 'package:Sentri/features/traffic/presentation/screens/home_screen.dart';

class SentriApp extends StatelessWidget {
  const SentriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.darkMode != curr.darkMode,
      builder: (context, settings) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                return const _AppShell();
              }
              if (state.status == AuthStatus.initial) {
                return const _SplashLoader();
              }
              return const SignInScreen();
            },
          ),
        );
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo/logo.png', width: 56, height: 56),
            const SizedBox(height: 24),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut),
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    BlacklistScreen(),
    AclScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<BlacklistCubit, BlacklistState>(
      builder: (context, blacklist) {
        final blockedCount = blacklist.entries.length;

        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            border: Border(top: BorderSide(color: colors.borderColor, width: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    index: 0,
                    currentIndex: currentIndex,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Dashboard',
                    onTap: onTap,
                  ),
                  _NavItemWithBadge(
                    index: 1,
                    currentIndex: currentIndex,
                    icon: Icons.block_outlined,
                    activeIcon: Icons.block_rounded,
                    label: 'Blacklist',
                    badgeCount: blockedCount,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: 2,
                    currentIndex: currentIndex,
                    icon: Icons.shield_outlined,
                    activeIcon: Icons.shield_rounded,
                    label: 'ACL',
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: 3,
                    currentIndex: currentIndex,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: onTap,
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

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return _NavItemBase(
      isActive: isActive,
      icon: isActive ? activeIcon : icon,
      label: label,
      onTap: () => onTap(index),
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;
  final ValueChanged<int> onTap;

  const _NavItemWithBadge({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final colors = context.appColors;

    final iconWidget = badges.Badge(
      showBadge: badgeCount > 0,
      badgeContent: Text(
        badgeCount > 99 ? '99+' : '$badgeCount',
        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      badgeStyle: const badges.BadgeStyle(
        badgeColor: AppColors.statusDanger,
        padding: EdgeInsets.all(3.5),
      ),
      child: Icon(
        isActive ? activeIcon : icon,
        size: 24,
        color: isActive ? AppColors.primary : colors.textDisabled,
      ),
    );

    return _NavItemBase(
      isActive: isActive,
      label: label,
      onTap: () => onTap(index),
      customIcon: iconWidget,
    );
  }
}

class _NavItemBase extends StatelessWidget {
  final bool isActive;
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItemBase({
    required this.isActive,
    required this.label,
    required this.onTap,
    this.icon,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ??
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? AppColors.primary : colors.textDisabled,
                ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : colors.textDisabled,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
