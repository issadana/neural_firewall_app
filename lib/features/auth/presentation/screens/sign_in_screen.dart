import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/constants/assets_manager.dart';
import '../bloc/auth_cubit.dart';
import 'sign_up_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signIn(_emailCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.authBackground),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.statusDanger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusManager.radiusAll12),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 64),
                    _buildBrand(colors),
                    const SizedBox(height: 44),
                    _buildCard(context, isLoading, colors),
                    const SizedBox(height: 28),
                    _buildSignUpLink(context, colors),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand(AppThemeColors colors) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: DecorationManager.brandLogo(colors),
          child: ClipRRect(
            borderRadius: BorderRadiusManager.radiusAll19,
            child: Image.asset(
              AssetsManager.logo,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sentri',
          style: getBoldTextStyle(
            fontSize: FontSizesManager.s34,
            color: colors.textPrimary,
            letterSpacing: -1.2,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: -0.08, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildCard(BuildContext context, bool isLoading, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll28,
        borderWidth: 1.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s20,
                color: colors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your account',
              style: getRegularTextStyle(fontSize: FontSizesManager.s13, color: colors.textMuted),
            ),
            const SizedBox(height: 24),
            AuthTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Password',
              controller: _passwordCtrl,
              obscure: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 28),
            AuthButton(
              label: 'Unlock',
              isLoading: isLoading,
              onPressed: () => _submit(context),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 700.ms, delay: 200.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 700.ms, delay: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildSignUpLink(BuildContext context, AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: getRegularTextStyle(fontSize: FontSizesManager.s14, color: colors.textMuted),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, anim, _) => const SignUpScreen(),
                transitionsBuilder: (_, anim, _, child) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            'Sign Up',
            style: getSemiBoldTextStyle(fontSize: FontSizesManager.s14),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms);
  }
}
