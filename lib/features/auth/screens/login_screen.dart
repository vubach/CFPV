import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/buttons/primary_pill_button.dart';
import '../../../shared/widgets/inputs/floating_label_input.dart';
import '../../../shared/widgets/inputs/password_input.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../core/router/route_paths.dart';

/// Login screen — phone/email + password authentication.
/// Design: specs/design-phase.md §3.2
class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).login(
          login: _loginController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.isAuthenticated) {
        context.go(widget.redirectPath ?? RoutePaths.home);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CFPVSpacing.space3),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: CFPVSpacing.space6),
                const AppLogo(size: 72, fontSize: 22),
                const SizedBox(height: CFPVSpacing.space5),
                // Heading
                Text('Welcome Back',
                    style: CFPVTypography.h1Green,),
                const SizedBox(height: 4),
                Text(
                  'Sign in to your account',
                  style: CFPVTypography.body.copyWith(
                      color: CFPVColors.textBlackSoft,),
                ),
                const SizedBox(height: CFPVSpacing.space5),
                // Login input
                FloatingLabelInput(
                  label: 'Phone number or email',
                  controller: _loginController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: CFPVSpacing.space3),
                // Password input
                PasswordInput(
                  label: 'Password',
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: CFPVSpacing.space2),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RoutePaths.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: CFPVSpacing.space4),
                // Login button
                PrimaryPillButton.fullWidth(
                  label: 'Sign In',
                  isLoading: isLoading,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: CFPVSpacing.space5),
                // Register link
                const SizedBox(height: CFPVSpacing.space5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: CFPVTypography.body
                            .copyWith(color: CFPVColors.textBlackSoft),),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.register),
                      child: const Text('Create one'),
                    ),
                  ],
                ),
                const SizedBox(height: CFPVSpacing.space5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
