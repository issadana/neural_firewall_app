import 'package:flutter/material.dart';

import 'package:Sentri/core/theme/app_colors.dart';

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
  final _ipController    = TextEditingController();
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
    final colors = context.appColors;
    return Dialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.borderColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dns_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ipController,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: colors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: colors.textDisabled, fontFamily: 'monospace'),
                errorText: _error,
                filled: true,
                fillColor: colors.surfaceDark,
                prefixIcon: Icon(Icons.router_rounded, color: colors.textDisabled, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.statusDanger),
                ),
              ),
              onSubmitted: (_) => widget.notesHint == null ? _submit() : null,
            ),
            if (widget.notesHint != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.notesHint,
                  hintStyle: TextStyle(color: colors.textDisabled),
                  filled: true,
                  fillColor: colors.surfaceDark,
                  prefixIcon: Icon(Icons.notes_rounded, color: colors.textDisabled, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: colors.textMuted),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A8BFF), AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(80, 40),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
