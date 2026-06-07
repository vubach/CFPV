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
import '../../../core/constants/app_constants.dart';

/// Registration screen with OTP verification.
/// Design: specs/design-phase.md §3.3
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOtp = false;
  String? _otpError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).register(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: _passwordController.text,
        );

    setState(() => _showOtp = true);
  }

  void _onOtpCompleted(String otp) async {
    if (AppConstants.isOtpHardcoded && otp != AppConstants.hardcodedOtp) {
      setState(() => _otpError = 'Invalid verification code');
      return;
    }

    setState(() => _otpError = null);
    ref.read(authProvider.notifier).verifyOtp(
          phone: _phoneController.text.trim(),
          otp: otp,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.isAuthenticated) {
        context.go(RoutePaths.home);
      } else if (state is AuthStateError) {
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: CFPVSpacing.space3),
              Text('Create Account',
                  style: CFPVTypography.h1Green,),
              const SizedBox(height: 4),
              Text(
                'Join the CFPV family',
                style: CFPVTypography.body
                    .copyWith(color: CFPVColors.textBlackSoft),
              ),
              const SizedBox(height: CFPVSpacing.space5),

              if (!_showOtp) ...[
                // ── Registration Form ───────────
                FloatingLabelInput(
                  label: 'Full name',
                  controller: _nameController,
                ),
                const SizedBox(height: CFPVSpacing.space3),
                FloatingLabelInput(
                  label: 'Phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text('+84',
                        style: CFPVTypography.small,),
                  ),
                ),
                const SizedBox(height: CFPVSpacing.space3),
                FloatingLabelInput(
                  label: 'Email (optional)',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: CFPVSpacing.space3),
                PasswordInput(
                  label: 'Password',
                  controller: _passwordController,
                ),
                const SizedBox(height: CFPVSpacing.space3),
                PasswordInput(
                  label: 'Confirm password',
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: CFPVSpacing.space5),
                PrimaryPillButton.fullWidth(
                  label: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _onRegister,
                ),
              ] else ...[
                // ── OTP Verification ───────────
                OTPVerification(
                  phoneNumber: _phoneController.text.trim(),
                  errorText: _otpError,
                  onCompleted: _onOtpCompleted,
                  isLoading: isLoading,
                ),
              ],

              const SizedBox(height: CFPVSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?',
                      style: CFPVTypography.body
                          .copyWith(color: CFPVColors.textBlackSoft),),
                  TextButton(
                    onPressed: () => context.go(RoutePaths.login),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
              const SizedBox(height: CFPVSpacing.space5),
            ],
          ),
        ),
      ),
    );
  }
}
