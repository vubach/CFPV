import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/otp_timer_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/inputs/otp_input.dart';
import '../../../core/constants/app_constants.dart';

/// OTP verification card with phone display and resend timer.
class OTPVerification extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? errorText;
  final ValueChanged<String> onCompleted;
  final bool isLoading;

  const OTPVerification({
    super.key,
    required this.phoneNumber,
    this.errorText,
    required this.onCompleted,
    this.isLoading = false,
  });

  @override
  ConsumerState<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends ConsumerState<OTPVerification> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(otpTimerProvider.notifier).start();
    });
  }

  void _onResend() {
    if (ref.read(otpTimerProvider) > 0) return;
    ref.read(otpTimerProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds = ref.watch(otpTimerProvider);
    final canResend = remainingSeconds == 0;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Icon(Icons.sms_outlined,
              size: 48, color: CFPVColors.greenAccent,),
          const SizedBox(height: CFPVSpacing.space3),
          Text('Enter verification code',
              style: CFPVTypography.h1Green,),
          const SizedBox(height: CFPVSpacing.space2),
          Text(
            'Sent to ${widget.phoneNumber}',
            style: CFPVTypography.body
                .copyWith(color: CFPVColors.textBlackSoft),
          ),
          const SizedBox(height: CFPVSpacing.space4),
          OtpInput(
            length: AppConstants.otpLength,
            onCompleted: widget.onCompleted,
            errorText: widget.errorText,
          ),
          const SizedBox(height: CFPVSpacing.space4),
          if (canResend)
            TextButton(
              onPressed: _onResend,
              child: const Text('Resend code'),
            )
          else
            Text(
              'Resend code in ${remainingSeconds}s',
              style: CFPVTypography.small
                  .copyWith(color: CFPVColors.textBlackSoft),
            ),
          if (widget.isLoading) ...[
            const SizedBox(height: CFPVSpacing.space3),
            const CircularProgressIndicator(color: CFPVColors.greenAccent),
          ],
        ],
      ),
    );
  }
}
