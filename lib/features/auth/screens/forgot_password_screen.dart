import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/otp_verification.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/buttons/primary_pill_button.dart';
import '../../../shared/widgets/inputs/floating_label_input.dart';
import '../../../shared/widgets/inputs/password_input.dart';
import '../../../core/router/route_paths.dart';

/// Forgot password flow: phone → OTP → new password.
/// Uses authProvider for state management.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _sentOtp = false;
  bool _resetComplete = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    ref.read(authProvider.notifier).forgotPassword(phone: phone);
    setState(() => _sentOtp = true);
  }

  Future<void> _onOtpVerified(String otp) async {
    final newPassword = _passwordController.text;
    if (newPassword.length < 8) return;
    if (newPassword != _confirmController.text) return;

    ref.read(authProvider.notifier).resetPassword(
          phone: _phoneController.text.trim(),
          otp: otp,
          newPassword: newPassword,
        );
  }

  Future<void> _onResetPressed() async {
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters'),
          backgroundColor: CFPVColors.red,
        ),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: CFPVColors.red,
        ),
      );
      return;
    }

    setState(() => _resetComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: CFPVColors.red,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    if (_resetComplete) {
      return Scaffold(
        backgroundColor: CFPVColors.neutralWarm,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(CFPVSpacing.space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    size: 64, color: CFPVColors.greenAccent,),
                const SizedBox(height: CFPVSpacing.space4),
                Text('Password Reset',
                    style: CFPVTypography.h1Green,),
                const SizedBox(height: CFPVSpacing.space2),
                Text(
                  'Your password has been updated successfully.',
                  style: CFPVTypography.body
                      .copyWith(color: CFPVColors.textBlackSoft),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CFPVSpacing.space5),
                PrimaryPillButton(
                  label: 'Back to Sign In',
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CFPVSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: CFPVSpacing.space4),
            Text('Reset Password',
                style: CFPVTypography.h1Green,),
            const SizedBox(height: 4),
            Text(
              "We'll send you a reset code",
              style: CFPVTypography.body
                  .copyWith(color: CFPVColors.textBlackSoft),
            ),
            const SizedBox(height: CFPVSpacing.space5),

            if (!_sentOtp) ...[
              FloatingLabelInput(
                label: 'Phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: CFPVSpacing.space4),
              PrimaryPillButton.fullWidth(
                label: 'Send OTP',
                isLoading: isLoading,
                onPressed: _sendOtp,
              ),
            ] else ...[
              OTPVerification(
                phoneNumber: _phoneController.text.trim(),
                onCompleted: _onOtpVerified,
                isLoading: isLoading,
              ),
              const SizedBox(height: CFPVSpacing.space4),
              PasswordInput(
                label: 'New password',
                controller: _passwordController,
              ),
              const SizedBox(height: CFPVSpacing.space3),
              PasswordInput(
                label: 'Confirm new password',
                controller: _confirmController,
              ),
              const SizedBox(height: CFPVSpacing.space4),
              PrimaryPillButton.fullWidth(
                label: 'Reset Password',
                isLoading: isLoading,
                onPressed: _onResetPressed,
              ),
            ],

            const SizedBox(height: CFPVSpacing.space4),
            TextButton(
              onPressed: () => context.go(RoutePaths.login),
              child: const Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
