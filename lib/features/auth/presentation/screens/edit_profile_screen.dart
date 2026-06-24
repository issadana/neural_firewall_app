import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Lets the signed-in user view their account details and edit their username
/// and/or password via `PUT /users/me`. Email is shown read-only — the API does
/// not update it. On success the [AuthCubit] re-fetches and re-caches the user,
/// so the rest of the app (e.g. the home welcome header) updates automatically.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  /// The username when the screen opened — used to detect an actual change.
  late final String _originalUsername;

  /// True while a save we initiated is in flight, so the BlocListener only
  /// reacts to our own update (not unrelated auth-state changes).
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    _originalUsername = state.username ?? '';
    _usernameCtrl = TextEditingController(text: _originalUsername);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newUsername = _usernameCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text;
    final usernameChanged =
        newUsername.isNotEmpty && newUsername != _originalUsername;
    final changingPassword = newPassword.isNotEmpty;

    if (!usernameChanged && !changingPassword) {
      _showSnack('Nothing to update', AppColors.statusWarning);
      return;
    }

    setState(() => _saving = true);
    context.read<AuthCubit>().updateProfile(
          username: usernameChanged ? newUsername : null,
          newPassword: changingPassword ? newPassword : null,
          currentPassword: changingPassword ? _currentPasswordCtrl.text : null,
        );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: const Text('Edit Profile'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.borderColor),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => _saving && prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            _saving = false;
            _showSnack('Profile updated successfully', AppColors.statusNormal);
            Navigator.of(context).pop();
          } else if (state.status == AuthStatus.error) {
            setState(() => _saving = false);
            _showSnack(
              state.errorMessage ?? 'Could not update profile',
              AppColors.statusDanger,
            );
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: PaddingManager.paddingAll16,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileAvatar(username: _originalUsername),
                SpacesManager.h24,
                _SectionLabel('Account'),
                SpacesManager.h12,
                _ReadOnlyField(
                  label: 'Email',
                  value: context.read<AuthCubit>().state.email ?? '—',
                ),
                SpacesManager.h16,
                AuthTextField(
                  label: 'Username',
                  controller: _usernameCtrl,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                SpacesManager.h28,
                _SectionLabel('Change Password'),
                SpacesManager.h4,
                Text(
                  'Leave these blank to keep your current password.',
                  style: getRegularTextStyle(
                    fontSize: FontSizesManager.s12,
                    color: colors.textMuted,
                  ),
                ),
                SpacesManager.h16,
                AuthTextField(
                  label: 'Current Password',
                  controller: _currentPasswordCtrl,
                  obscure: true,
                  validator: (v) {
                    // Required only when a new password is being set.
                    if (_newPasswordCtrl.text.isNotEmpty &&
                        (v == null || v.isEmpty)) {
                      return 'Enter your current password to change it';
                    }
                    return null;
                  },
                ),
                SpacesManager.h16,
                AuthTextField(
                  label: 'New Password',
                  controller: _newPasswordCtrl,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 8) {
                      return 'New password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                SpacesManager.h32,
                AuthButton(
                  label: 'Save Changes',
                  isLoading: _saving,
                  onPressed: _submit,
                ),
                SpacesManager.h24,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular avatar showing the user's first initial.
class _ProfileAvatar extends StatelessWidget {
  final String username;
  const _ProfileAvatar({required this.username});

  @override
  Widget build(BuildContext context) {
    final initial =
        username.isEmpty ? '?' : username.characters.first.toUpperCase();
    return Center(
      child: Container(
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: DecorationManager.tinted(
          AppColors.primary,
          BorderRadiusManager.radiusAll28,
          alpha: 0.14,
        ),
        child: Text(
          initial,
          style: getBoldTextStyle(
            fontSize: FontSizesManager.s34,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: getBoldTextStyle(
        fontSize: FontSizesManager.s11,
        color: context.appColors.textMuted,
        letterSpacing: 1.0,
      ),
    );
  }
}

/// A non-editable field (used for the email, which the API won't change).
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: PaddingManager.paddingH18V16,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getRegularTextStyle(
                    fontSize: FontSizesManager.s12,
                    color: colors.textMuted,
                  ),
                ),
                SpacesManager.h2,
                Text(
                  value,
                  style: getSemiBoldTextStyle(
                    fontSize: FontSizesManager.s15,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colors.textDisabled,
          ),
        ],
      ),
    );
  }
}
