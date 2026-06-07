import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Password input with visibility toggle icon.
/// DESIGN.md §9.3: Floating Label Input variant
class PasswordInput extends StatefulWidget {
  final String label;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const PasswordInput({
    super.key,
    this.label = 'Password',
    this.onChanged,
    this.validator,
    this.textInputAction,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
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
