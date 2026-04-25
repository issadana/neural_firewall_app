import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AddIpDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String? notesHint;

  const AddIpDialog({
    super.key,
    required this.title,
    this.hint = 'e.g. 192.168.1.100',
    this.notesHint,
  });

  @override
  State<AddIpDialog> createState() => _AddIpDialogState();
}

class _AddIpDialogState extends State<AddIpDialog> {
  final _ipController = TextEditingController();
  final _notesController = TextEditingController();
  String? _error;

  static final _ipRegex = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  @override
  void dispose() {
    _ipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final ip = _ipController.text.trim();
    if (!_ipRegex.hasMatch(ip)) {
      setState(() => _error = 'Enter a valid IPv4 address');
      return;
    }
    Navigator.of(context).pop((ip: ip, notes: _notesController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: AppColors.accentBlue,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ipController,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.textDisabled),
              errorText: _error,
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.accentBlue),
              ),
              prefixIcon: const Icon(Icons.dns_outlined, color: AppColors.textDisabled, size: 18),
            ),
            onSubmitted: (_) => widget.notesHint == null ? _submit() : null,
          ),
          if (widget.notesHint != null) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.notesHint,
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.accentBlue),
                ),
                prefixIcon: const Icon(Icons.notes_outlined, color: AppColors.textDisabled, size: 18),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
