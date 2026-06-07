import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Password input with visibility toggle icon.
/// DESIGN.md §9.3: Floating Label Input variant
class PasswordInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const PasswordInput({
    super.key,
    this.label = 'Password',
    this.controller,
    this.onChanged,
    this.validator,
    this.textInputAction,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  late final TextEditingController _effectiveController;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _effectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _effectiveController,
      onChanged: widget.onChanged,
      validator: widget.validator,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      style: CFPVTypography.body.copyWith(color: CFPVColors.textBlack),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(
            _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: CFPVColors.textBlackSoft,
            size: 20,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
        filled: true,
        fillColor: CFPVColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: CFPVColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: CFPVColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: CFPVColors.greenAccent, width: 2),
        ),
        labelStyle: CFPVTypography.small.copyWith(
          color: CFPVColors.textBlackSoft,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
