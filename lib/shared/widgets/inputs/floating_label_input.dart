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
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    if (_errorText != null) {
      setState(() {
        _errorText = widget.validator?.call(value);
      });
    }
  }

  String? get errorText => _errorText;
  String get text => _controller.text;

  @override
  Widget build(BuildContext context) {
    final hasValue = _controller.text.isNotEmpty;
    final showError = _errorText != null && _errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          style: CFPVTypography.body.copyWith(color: CFPVColors.textBlack),
          decoration: InputDecoration(
            labelText: widget.label,
            prefix: widget.prefix,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.readOnly
                ? CFPVColors.neutralCool
                : showError
                    ? CFPVColors.red.withOpacity(0.05)
                    : CFPVColors.white,
            contentPadding: const EdgeInsets.all(CFPVSpacing.space3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.input),
              borderSide: BorderSide(
                color: showError
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
              color: showError
                  ? CFPVColors.red
                  : _isFocused
                      ? CFPVColors.greenAccent
                      : CFPVColors.textBlackSoft,
              fontWeight: FontWeight.w600,
            ),
            counterText: '',
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _errorText!,
              style: CFPVTypography.small.copyWith(color: CFPVColors.red),
            ),
          ),
      ],
    );
  }
}
