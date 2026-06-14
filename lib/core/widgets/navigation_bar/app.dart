import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/constants/assets_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/theme/app_theme.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:Sentri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:Sentri/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:Sentri/features/blacklist/presentation/bloc/blacklist_cubit.dart';
import 'package:Sentri/features/blacklist/presentation/screens/blacklist_screen.dart';
import 'package:Sentri/features/chatbot/presentation/screens/nova_chat_screen.dart';
import 'package:Sentri/features/dashboard/presentation/screens/dashboard_tabs_screen.dart';
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
            Image.asset(AssetsManager.logo, width: 56, height: 56),
            SpacesManager.h24,
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
    DashboardTabsScreen(),
    BlacklistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
        final bottomInset = MediaQuery.of(context).padding.bottom;
        return Container(
          decoration: DecorationManager.navBarScrim(colors),
          padding: EdgeInsets.only(
            top: PaddingManager.spacing1000.h,
            left: PaddingManager.p10.w,
            right: PaddingManager.p10.w,
            bottom: bottomInset + PaddingManager.spacing600.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: DecorationManager.navBar(colors),
                  child: Padding(
                    padding: PaddingManager.paddingAll6,
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavItem(
                            index: 0,
                            currentIndex: currentIndex,
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home_rounded,
                            label: 'Home',
                            onTap: onTap,
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            index: 1,
                            currentIndex: currentIndex,
                            icon: Icons.dashboard_outlined,
                            activeIcon: Icons.dashboard_rounded,
                            label: 'Portal',
                            onTap: onTap,
                          ),
                        ),
                        Expanded(
                          child: _NavItemWithBadge(
                            index: 2,
                            currentIndex: currentIndex,
                            icon: Icons.block_outlined,
                            activeIcon: Icons.block_rounded,
                            label: 'Blacklist',
                            badgeCount: blockedCount,
                            onTap: onTap,
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            index: 3,
                            currentIndex: currentIndex,
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings_rounded,
                            label: 'Settings',
                            onTap: onTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SpacesManager.w10,
              const _NovaFab(),
            ],
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
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s9,
          color: ColorManager.white,
        ),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: AppColors.statusDanger,
        padding: PaddingManager.paddingAll3p5,
      ),
      child: Icon(
        isActive ? activeIcon : icon,
        size: 20,
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
    return AppPressable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: PaddingManager.paddingH12V6,
        decoration: DecorationManager.navItem(isActive),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            customIcon ??
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.primary : colors.textDisabled,
                ),
            SpacesManager.h2,
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: isActive
                  ? getSemiBoldTextStyle(
                      fontSize: FontSizesManager.s10,
                      color: AppColors.primary,
                    )
                  : getRegularTextStyle(
                      fontSize: FontSizesManager.s10,
                      color: colors.textDisabled,
                    ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular launcher for Nova — the Sentri AI assistant. Sits at the
/// bottom-right of the floating nav bar and opens an instant chat.
class _NovaFab extends StatelessWidget {
  const _NovaFab();

  static const double _size = 50;

  void _openNova(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, animation, _) => const NovaChatScreen(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: () => _openNova(context),
      child: Container(
        width: _size.r,
        height: _size.r,
        alignment: Alignment.center,
        decoration: DecorationManager.novaFab,
        child:
            Icon(
                  Icons.auto_awesome_rounded,
                  color: ColorManager.white,
                  size: 26.r,
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2400.ms, color: ColorManager.white)
                .then(delay: 1600.ms),
      ),
    );
  }
}
