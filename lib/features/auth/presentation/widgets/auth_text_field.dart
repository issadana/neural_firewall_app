import 'package:flutter/material.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured;
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: DecorationManager.inputFocusGlow(
        BorderRadiusManager.radiusAll14,
        focused: _isFocused,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _obscured,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        style: getRegularTextStyle(fontSize: FontSizesManager.s15, color: colors.textPrimary, letterSpacing: 0.2),
        decoration: DecorationManager.inputField(
          colors,
          labelText: widget.label,
          hintText: widget.hint,
          radius: BorderRadiusManager.radiusAll14,
          contentPadding: PaddingManager.paddingH18V16,
          labelStyle: getRegularTextStyle(
            fontSize: FontSizesManager.s14,
            color: _isFocused ? AppColors.primary : colors.textMuted,
          ),
        ).copyWith(
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _isFocused ? AppColors.primary : colors.textDisabled,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : null,
        ),
      ),
    );
  }
}
