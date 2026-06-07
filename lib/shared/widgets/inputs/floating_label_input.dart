import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

/// Floating label input field with animated label and validation.
/// DESIGN.md §9.3: Floating Label Input
class FloatingLabelInput extends StatefulWidget {
  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffixIcon;
  final bool readOnly;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const FloatingLabelInput({
    super.key,
    required this.label,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffixIcon,
    this.readOnly = false,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<FloatingLabelInput> createState() => _FloatingLabelInputState();
}

class _FloatingLabelInputState extends State<FloatingLabelInput> {
  late final TextEditingController _effectiveController;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ??
        TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(FloatingLabelInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _effectiveController) {
      // External controller changed — update reference
      _effectiveController.text = widget.controller!.text;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _effectiveController.dispose();
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
  }

  /// Trigger validation and return the error message (null if valid).
  String? validate() {
    final error = widget.validator?.call(_effectiveController.text);
    setState(() => _showError = error != null && error.isNotEmpty);
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _effectiveController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _effectiveController,
          focusNode: _focusNode,
          onChanged: _onChanged,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          validator: (value) {
            // Run the custom validator and track error state
            final error = widget.validator?.call(value);
            if (error != null && error.isNotEmpty) {
              _showError = true;
              return error;
            }
            _showError = false;
            return null;
          },
          style: CFPVTypography.body.copyWith(color: CFPVColors.textBlack),
          decoration: InputDecoration(
            labelText: widget.label,
            prefix: widget.prefix,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.readOnly
                ? CFPVColors.neutralCool
                : _showError
                    ? CFPVColors.red.withOpacity(0.05)
                    : CFPVColors.white,
            contentPadding: const EdgeInsets.all(CFPVSpacing.space3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.input),
              borderSide: BorderSide(
                color: _showError
                    ? CFPVColors.red
                    : _isFocused
                        ? CFPVColors.greenAccent
                        : CFPVColors.inputBorder,
                width: _isFocused ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.input),
              borderSide: BorderSide(color: CFPVColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.input),
              borderSide:
                  const BorderSide(color: CFPVColors.greenAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.input),
              borderSide: const BorderSide(color: CFPVColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.input),
              borderSide: const BorderSide(color: CFPVColors.red, width: 2),
            ),
            labelStyle: CFPVTypography.small.copyWith(
              color: _showError
                  ? CFPVColors.red
                  : _isFocused
                      ? CFPVColors.greenAccent
                      : CFPVColors.textBlackSoft,
              fontWeight: FontWeight.w600,
            ),
            counterText: '',
          ),
        ),
        // Note: TextFormField renders its own error text below the field.
        // The _showError flag is used for the background color styling above.
      ],
    );
  }
}
