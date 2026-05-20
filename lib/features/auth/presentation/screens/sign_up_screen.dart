import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/theme/app_colors.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUp(_emailCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.authBackground),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (state.status == AuthStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.statusDanger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    const SizedBox(height: 56),
                    _buildBrand(colors),
                    const SizedBox(height: 36),
                    _buildCard(context, isLoading, colors),
                    const SizedBox(height: 28),
                    _buildSignInLink(context, colors),
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
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.borderColor),
            boxShadow: colors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Image.asset(
              'assets/images/logo/logo.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sentri',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 12),
        Image.asset(
          'assets/images/branding/sentri-slogan.png',
          height: 22,
          fit: BoxFit.contain,
          color: colors.textSecondary,
          colorBlendMode: BlendMode.modulate,
          errorBuilder: (_, _, _) => Text(
            'Stay safe, stay ahead',
            style: TextStyle(fontSize: 13, color: colors.textMuted, letterSpacing: 0.4),
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
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.borderColor),
        boxShadow: colors.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Protect your network from day one',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
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
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Confirm Password',
              controller: _confirmCtrl,
              obscure: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 28),
            AuthButton(
              label: 'Create Account',
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

  Widget _buildSignInLink(BuildContext context, AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: colors.textMuted, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms);
  }
}
