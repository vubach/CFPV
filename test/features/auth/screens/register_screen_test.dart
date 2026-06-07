import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/auth/screens/register_screen.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import 'package:cfpv/shared/widgets/buttons/primary_pill_button.dart';
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
      registerBuilder: (_, __) => const RegisterScreen(),
      forgotPasswordBuilder:
          (_, __) => const Scaffold(body: Text('Forgot Password Page')),
      homeBuilder: (_, __) => const Scaffold(body: Text('Home Page')),
      initialLocation: '/register',
    );
  });

  Future<void> pumpRegister(WidgetTester tester) {
    return tester.pumpWidget(
      createAuthTestApp(
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
        router: router,
      ),
    );
  }

  /// Helper to find the Create Account button (not the heading).
  Finder createAccountButton() =>
      find.widgetWithText(PrimaryPillButton, 'Create Account');

  group('RegisterScreen', () {
    testWidgets('renders registration form with all fields', (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      // Title and subtitle
      expect(find.text('Create Account'), findsAtLeast(1));
      expect(find.text('Join the CFPV family'), findsOneWidget);

      // Form fields
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Email (optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);

      // Create Account button
      expect(createAccountButton(), findsOneWidget);

      // Sign in link
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      // OTP should not be visible initially
      expect(find.text('Enter verification code'), findsNothing);
    });

    testWidgets('renders 5 text fields in registration form', (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('calls register on auth provider with form data',
        (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), '0987654321');
      await tester.enterText(textFields.at(2), 'john@test.com');
      await tester.enterText(textFields.at(3), 'securepass123');
      await tester.enterText(textFields.at(4), 'securepass123');
      await tester.pumpAndSettle();

      await tester.tap(createAccountButton());
      await tester.pumpAndSettle();

      expect(authNotifier.lastRegisterParams, isNotNull);
      expect(authNotifier.lastRegisterParams!['fullName'], 'John Doe');
      expect(authNotifier.lastRegisterParams!['phone'], '0987654321');
      expect(authNotifier.lastRegisterParams!['email'], 'john@test.com');
      expect(authNotifier.lastRegisterParams!['password'], 'securepass123');
    });

    testWidgets('shows OTP verification after register is called',
        (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), '0987654321');
      await tester.enterText(textFields.at(2), '');
      await tester.enterText(textFields.at(3), 'pass1234');
      await tester.enterText(textFields.at(4), 'pass1234');
      await tester.pumpAndSettle();

      await tester.tap(createAccountButton());
      await tester.pumpAndSettle();

      // The heading "Create Account" stays visible (above the conditional),
      // but the button disappears. Verify OTP view appears.
      expect(createAccountButton(), findsNothing);
      expect(find.text('Enter verification code'), findsOneWidget);
      expect(find.textContaining('Sent to'), findsOneWidget);
      expect(find.textContaining('0987654321'), findsOneWidget);
    });

    testWidgets('shows loading indicator during registration', (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      authNotifier.emitState(const AuthStateLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls auth provider with optional email as null',
        (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), '0987654321');
      await tester.enterText(textFields.at(3), 'pass1234');
      await tester.enterText(textFields.at(4), 'pass1234');
      await tester.pumpAndSettle();

      await tester.tap(createAccountButton());
      await tester.pumpAndSettle();

      expect(authNotifier.lastRegisterParams!['email'], isNull);
    });

    testWidgets('navigates to home on successful registration/OTP',
        (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      authNotifier.emitState(
        const AuthStateAuthenticated(
          userId: '2', fullName: 'New User', phone: '0987654321',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('shows error snackbar on registration error', (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      authNotifier.emitState(
        const AuthStateError(message: 'Phone number already registered'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone number already registered'), findsOneWidget);
      expect(find.text('Create Account'), findsAtLeast(1));
    });

    testWidgets('navigates to login on "Sign in" link tap', (tester) async {
      await pumpRegister(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
