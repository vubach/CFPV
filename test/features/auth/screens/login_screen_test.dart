import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/auth/screens/login_screen.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import '../../../helpers/auth_test_helper.dart';

void main() {
  late TestAuthNotifier authNotifier;
  late TestOtpTimerNotifier otpNotifier;
  late GoRouter router;

  setUp(() {
    authNotifier = TestAuthNotifier();
    otpNotifier = TestOtpTimerNotifier();
    router = createTestRouter(
      loginBuilder: (_, __) => const LoginScreen(),
      registerBuilder: (_, __) => const Scaffold(body: Text('Register Page')),
      forgotPasswordBuilder:
          (_, __) => const Scaffold(body: Text('Forgot Password Page')),
      homeBuilder: (_, __) => const Scaffold(body: Text('Home Page')),
      initialLocation: '/login',
    );
  });

  Future<void> pumpLogin(WidgetTester tester) {
    return tester.pumpWidget(
      createAuthTestApp(
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
        router: router,
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders all form fields and buttons', (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.text('Phone number or email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Create one'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      // Tap Sign In without filling fields — triggers Form.validate()
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // TextFormField should show validation errors (2 fields: login + password)
      expect(find.text('Required'), findsNWidgets(2));
    });

    testWidgets('shows validation error for empty username field',
        (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      // Fill password only
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.last, 'testpass');
      await tester.pumpAndSettle();

      // Tap Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show one "Required" for the empty username field
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('calls auth provider login with correct credentials',
        (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      // Fill in fields (controllers now properly connected)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'user@test.com');
      await tester.enterText(textFields.last, 'mypassword');
      await tester.pumpAndSettle();

      // Tap Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify auth provider was called with correct parameters
      expect(authNotifier.lastLogin, 'user@test.com');
      expect(authNotifier.lastPassword, 'mypassword');
    });

    testWidgets('shows loading indicator during authentication',
        (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      // Fill in fields
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@test.com');
      await tester.enterText(textFields.last, 'testpass');
      await tester.pumpAndSettle();

      // Verify no loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Emit loading state
      authNotifier.emitState(const AuthStateLoading());
      await tester.pump();

      // Should show loading spinner inside the button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to home on successful login', (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);

      // Emit authenticated state
      authNotifier.emitState(
        const AuthStateAuthenticated(
          userId: '1', fullName: 'Test User', phone: '1234567890',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('shows error snackbar on auth error and stays on login',
        (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      authNotifier.emitState(
        const AuthStateError(message: 'Invalid credentials'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('navigates to forgot password on link tap', (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password Page'), findsOneWidget);
    });

    testWidgets('navigates to register on "Create one" link tap',
        (tester) async {
      await pumpLogin(tester);
      await tester.pumpAndSettle();

      // Ensure the link is visible and tap it
      await tester.ensureVisible(find.text('Create one'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create one'));
      await tester.pumpAndSettle();

      expect(find.text('Register Page'), findsOneWidget);
    });
  });
}
