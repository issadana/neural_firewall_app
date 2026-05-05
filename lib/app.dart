import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_cubit.dart';
import 'blocs/blacklist/blacklist_cubit.dart';
import 'blocs/blacklist/blacklist_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'models/app_models.dart';
import 'screens/acl/acl_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/blacklist/blacklist_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';

class NeuralFirewallApp extends StatelessWidget {
  const NeuralFirewallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            return const _AppShell();
          }
          if (state.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const SignInScreen();
        },
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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return BlocBuilder<BlacklistCubit, BlacklistState>(
      builder: (context, blacklist) {
        final blockedCount = blacklist.entries.length;

        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.accentBlue,
          unselectedItemColor: AppColors.textDisabled,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 15),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: badges.Badge(
                showBadge: blockedCount > 0,
                badgeContent: Text(
                  blockedCount > 99 ? '99+' : '$blockedCount',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.statusDanger,
                  padding: EdgeInsets.all(3),
                ),
                child: const Icon(Icons.block_outlined),
              ),
              activeIcon: badges.Badge(
                showBadge: blockedCount > 0,
                badgeContent: Text(
                  blockedCount > 99 ? '99+' : '$blockedCount',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.statusDanger,
                  padding: EdgeInsets.all(3),
                ),
                child: const Icon(Icons.block),
              ),
              label: 'Blacklist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'ACL',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}

