import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/auth_state.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/inputs/password_input.dart';
import '../../../../shared/widgets/buttons/primary_pill_button.dart';

/// Full-screen change password page with current, new, and confirm fields.
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthStateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${authState.message}'),
          backgroundColor: CFPVColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password changed successfully'),
        backgroundColor: CFPVColors.greenAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
      ),
    );
    if (!mounted) return;
    context.go(RoutePaths.profile);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: CFPVColors.white,
        surfaceTintColor: CFPVColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Instructions ────────────────────
              Container(
                padding: const EdgeInsets.all(CFPVSpacing.space3),
                decoration: BoxDecoration(
                  color: CFPVColors.greenLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(CFPVRadius.card),
                  border: Border.all(
                    color: CFPVColors.greenLight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: CFPVColors.starbucksGreen,
                    ),
                    const SizedBox(width: CFPVSpacing.space2),
                    Expanded(
                      child: Text(
                        'Choose a strong password with at least 8 characters, including letters and numbers.',
                        style: CFPVTypography.small.copyWith(
                          color: CFPVColors.starbucksGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CFPVSpacing.space5),

              // ── Current Password ────────────────
              Text(
                'Current Password',
                style: CFPVTypography.smallBold.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space2),
              PasswordInput(
                label: 'Current Password',
                controller: _currentPasswordController,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your current password';
                  return null;
                },
              ),
              const SizedBox(height: CFPVSpacing.space4),

              // ── New Password ────────────────────
              Text(
                'New Password',
                style: CFPVTypography.smallBold.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space2),
              PasswordInput(
                label: 'New Password',
                controller: _newPasswordController,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a new password';
                  if (v.length < 8) return 'At least 8 characters';
                  if (!RegExp(r'[a-zA-Z]').hasMatch(v)) return 'Must include a letter';
                  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must include a number';
                  return null;
                },
              ),
              const SizedBox(height: CFPVSpacing.space4),

              // ── Confirm New Password ────────────
              Text(
                'Confirm New Password',
                style: CFPVTypography.smallBold.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space2),
              PasswordInput(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirm your new password';
                  if (v != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: CFPVSpacing.space5),

              // ── Save button ─────────────────────
              PrimaryPillButton.fullWidth(
                label: 'Update Password',
                isLoading: isLoading,
                onPressed: _onSave,
              ),

              const SizedBox(height: CFPVSpacing.space8),
            ],
          ),
        ),
      ),
    );
  }
}
