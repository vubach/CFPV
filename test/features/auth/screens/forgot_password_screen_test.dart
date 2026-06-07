import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/auth/screens/forgot_password_screen.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import 'package:cfpv/shared/widgets/buttons/primary_pill_button.dart';
import 'package:cfpv/shared/widgets/inputs/password_input.dart';
import '../../../helpers/auth_test_helper.dart';

void main() {
  late TestAuthNotifier authNotifier;
  late TestOtpTimerNotifier otpNotifier;
  late GoRouter router;

  setUp(() {
    authNotifier = TestAuthNotifier();
    otpNotifier = TestOtpTimerNotifier();
    router = createTestRouter(
      loginBuilder: (_, __) => const Scaffold(body: Text('Login Page')),
      registerBuilder: (_, __) => const Scaffold(body: Text('Register Page')),
      forgotPasswordBuilder: (_, __) => const ForgotPasswordScreen(),
      homeBuilder: (_, __) => const Scaffold(body: Text('Home Page')),
      initialLocation: '/forgot-password',
    );
  });

  Future<void> pumpForgotPassword(WidgetTester tester) {
    return tester.pumpWidget(
      createAuthTestApp(
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
        router: router,
      ),
    );
  }

  /// Helper to find the Reset Password button (not the heading).
  Finder resetPasswordButton() =>
      find.widgetWithText(PrimaryPillButton, 'Reset Password');

  /// Helper to fill password fields in the OTP step.
  Future<void> fillPasswordFields(
    WidgetTester tester, {
    required String newPassword,
    required String confirmPassword,
  }) async {
    final passwordInputs = find.byType(PasswordInput);
    expect(passwordInputs, findsNWidgets(2));

    await tester.enterText(
      find.descendant(
        of: passwordInputs.first,
        matching: find.byType(TextField),
      ),
      newPassword,
    );
    await tester.enterText(
      find.descendant(
        of: passwordInputs.last,
        matching: find.byType(TextField),
      ),
      confirmPassword,
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders phone input in initial state', (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text("We'll send you a reset code"), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
      expect(find.text('Enter verification code'), findsNothing);
    });

    testWidgets('sends OTP when phone is provided and button tapped',
        (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0987654321');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send OTP'));
      await tester.pump(); // rebuild with _sentOtp = true
      await tester.pump(); // process OTPVerification.initState microtask

      // OTP view appears
      expect(find.text('Enter verification code'), findsOneWidget);
      expect(find.text('New password'), findsOneWidget);
      expect(find.text('Confirm new password'), findsOneWidget);
      expect(resetPasswordButton(), findsOneWidget);
    });

    testWidgets('shows loading indicator during OTP send', (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0987654321');
      await tester.pumpAndSettle();

      authNotifier.emitState(const AuthStateLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('shows error snackbar on forgot password error',
        (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      authNotifier.emitState(
        const AuthStateError(message: 'Phone number not found'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone number not found'), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('shows success screen after password reset completes',
        (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      // Enter phone → send OTP
      await tester.enterText(find.byType(TextField), '0987654321');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      // Fill in matching passwords
      await fillPasswordFields(tester,
          newPassword: 'newpassword123', confirmPassword: 'newpassword123',);
      await tester.pump();

      // Ensure Reset Password button is visible, then tap
      await tester.ensureVisible(resetPasswordButton());
      await tester.pump();
      await tester.tap(resetPasswordButton());
      await tester.pumpAndSettle();

      // Success screen
      expect(find.text('Password Reset'), findsOneWidget);
      expect(
        find.text('Your password has been updated successfully.'),
        findsOneWidget,
      );
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('navigates to login from success screen', (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0987654321');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      await fillPasswordFields(tester,
          newPassword: 'newpass123', confirmPassword: 'newpass123',);
      await tester.pump();

      await tester.ensureVisible(resetPasswordButton());
      await tester.pump();
      await tester.tap(resetPasswordButton());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('shows snackbar when passwords do not match', (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0987654321');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      await fillPasswordFields(tester,
          newPassword: 'password123', confirmPassword: 'differentpass',);
      await tester.pump();

      await tester.ensureVisible(resetPasswordButton());
      await tester.pump();
      await tester.tap(resetPasswordButton());
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('Password Reset'), findsNothing);
    });

    testWidgets('shows snackbar when password is too short (less than 8 chars)',
        (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0987654321');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      await fillPasswordFields(tester,
          newPassword: 'short', confirmPassword: 'short',);
      await tester.pump();

      await tester.ensureVisible(resetPasswordButton());
      await tester.pump();
      await tester.tap(resetPasswordButton());
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Password Reset'), findsNothing);
    });

    testWidgets('navigates to login on back to sign in link', (tester) async {
      await pumpForgotPassword(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
