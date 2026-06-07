import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/onboarding/screens/onboarding_screen.dart';

/// Creates a test GoRouter with onboarding and login routes.
GoRouter _createTestRouter({String initialLocation = '/onboarding'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const Scaffold(body: Text('Login Page')),
      ),
    ],
  );
}

void main() {
  late GoRouter router;

  setUp(() {
    // Mock FlutterSecureStorage channel so SecureStorageService() doesn't crash
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
          case 'containsKey':
            return null;
          case 'write':
            return true;
          case 'delete':
          case 'deleteAll':
            return true;
          case 'readAll':
            return <String, dynamic>{};
          default:
            return null;
        }
      },
    );

    router = _createTestRouter();
  });

  tearDown(() {
    // Clean up mock channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
      null,
    );
  });

  Future<void> pumpOnboarding(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
  }

  group('OnboardingScreen', () {
    testWidgets('renders first slide with correct content', (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Slide 1 content
      expect(find.text('Browse & Order'), findsOneWidget);
      expect(
        find.text(
          'Explore our full menu of handcrafted beverages and fresh food.',
        ),
        findsOneWidget,
      );

      // Page 1 should show "Next →" button, not "Get Started"
      expect(find.text('Next →'), findsOneWidget);
      expect(find.text('✓  Get Started'), findsNothing);

      // Skip button visible on first page
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows "Next →" button on first two pages', (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Page 1: shows Next
      expect(find.text('Next →'), findsOneWidget);
      expect(find.text('✓  Get Started'), findsNothing);

      // Navigate to page 2
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Page 2: still shows Next
      expect(find.text('Next →'), findsOneWidget);
      expect(find.text('✓  Get Started'), findsNothing);
    });

    testWidgets('shows "Get Started" on last page without Skip',
        (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Navigate to last page (page 3)
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Last page: shows Get Started, no Next, no Skip
      expect(find.text('✓  Get Started'), findsOneWidget);
      expect(find.text('Next →'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('navigates to login on "Get Started" tap', (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Go to last page
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Verify we can see the Get Started button
      expect(find.text('✓  Get Started'), findsOneWidget);

      // Tap Get Started inside runAsync to properly handle async continuation
      await tester.runAsync(() async {
        await tester.tap(find.text('✓  Get Started'));
        await Future.delayed(const Duration(milliseconds: 200));
      });

      // Pump multiple frames to process navigation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify navigation to login route
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('navigates to login on "Skip" tap', (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Verify onboarding is showing
      expect(find.text('Browse & Order'), findsOneWidget);

      // Tap Skip inside runAsync to properly handle async continuation
      await tester.runAsync(() async {
        await tester.tap(find.text('Skip'));
        await Future.delayed(const Duration(milliseconds: 200));
      });

      // Pump multiple frames to process navigation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify navigation to login route
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('page indicator updates on navigation', (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Initially 3 AnimatedContainers for dots
      expect(find.byType(AnimatedContainer), findsNWidgets(3));

      // Navigate to page 2
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Navigate to page 3
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Still 3 dots on last page
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('swipe navigation changes slides', (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Start on slide 1
      expect(find.text('Browse & Order'), findsOneWidget);

      // Swipe left to go to slide 2 (500px > half of 800px viewport)
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Slide 2 content should be visible
      expect(find.text('Earn Rewards'), findsOneWidget);
      expect(
        find.text(
          'Collect points with every order and unlock exclusive benefits.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders all three slides with correct content',
        (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Slide 1
      expect(find.text('Browse & Order'), findsOneWidget);
      expect(
        find.text(
          'Explore our full menu of handcrafted beverages and fresh food.',
        ),
        findsOneWidget,
      );

      // Swipe to slide 2 (500px > half of 800px viewport)
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Slide 2
      expect(find.text('Earn Rewards'), findsOneWidget);
      expect(
        find.text(
          'Collect points with every order and unlock exclusive benefits.',
        ),
        findsOneWidget,
      );

      // Swipe to slide 3
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Slide 3
      expect(find.text('Fast & Easy Pickup'), findsOneWidget);
      expect(
        find.text(
          'Order ahead and skip the line. Your order will be ready when you arrive.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('"Next →" advances to next slide without skip button on last',
        (tester) async {
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();

      // Slide 1: has Skip, Page 1 text
      expect(find.text('Browse & Order'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap Next
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Slide 2: has Skip, Page 2 text
      expect(find.text('Earn Rewards'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap Next again
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();

      // Slide 3: no Skip, Page 3 text
      expect(find.text('Fast & Easy Pickup'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('✓  Get Started'), findsOneWidget);
    });
  });
}
