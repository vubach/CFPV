import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';

/// 6-digit OTP input with auto-advance and auto-submit.
/// DESIGN.md §9.3: OTP Input
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final String? errorText;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.errorText,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered — auto-submit
        _focusNodes[index].unfocus();
        final code = _controllers.map((c) => c.text).join();
        if (code.length == widget.length) {
          widget.onCompleted(code);
        }
      }
    }
  }

  void _onKey(String value, int index) {
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: CFPVSpacing.space2 / 2),
              child: SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (v) => _onChanged(v, index),
                  onTap: () => _controllers[index].selection =
                      TextSelection.collapsed(
                          offset: _controllers[index].text.length),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: CFPVTypography.h1.copyWith(
                    color: CFPVColors.textBlack,
                    fontSize: 22,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: CFPVColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _controllers[index].text.isNotEmpty
                            ? CFPVColors.greenAccent
                            : CFPVColors.inputBorder,
                        width: _controllers[index].text.isNotEmpty ? 2 : 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _controllers[index].text.isNotEmpty
                            ? CFPVColors.greenAccent
                            : CFPVColors.inputBorder,
                        width: _controllers[index].text.isNotEmpty ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: CFPVColors.greenAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              widget.errorText!,
              style: CFPVTypography.small.copyWith(color: CFPVColors.red),
            ),
          ),
      ],
    );
  }
}
