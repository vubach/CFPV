import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/shared/widgets/navigation/cfpv_tab_bar.dart';

/// Creates a test GoRouter with a ShellRoute + tab routes matching the real app.
GoRouter _createStubTestRouter({String initialLocation = '/menu'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (_, __, child) => CFPVTabShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Home Page')),
            ),
          ),
          GoRoute(
            path: '/menu',
            name: 'menu',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Menu — Coming in Sprint 2')),
            ),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Cart — Coming in Sprint 3')),
            ),
          ),
          GoRoute(
            path: '/rewards',
            name: 'rewards',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Rewards — Coming in Sprint 5')),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Profile — Coming in Sprint 6')),
            ),
          ),
        ],
      ),
    ],
  );
}

void main() {
  setUp(() {
    DioClient.create(baseUrl: 'http://test.local');
  });

  group('Stub tab screens', () {
    testWidgets('menu screen shows placeholder text', (tester) async {
      final router = _createStubTestRouter(initialLocation: '/menu');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Menu — Coming in Sprint 2'), findsOneWidget);
    });

    testWidgets('cart screen shows placeholder text', (tester) async {
      final router = _createStubTestRouter(initialLocation: '/cart');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cart — Coming in Sprint 3'), findsOneWidget);
    });

    testWidgets('rewards screen shows placeholder text', (tester) async {
      final router = _createStubTestRouter(initialLocation: '/rewards');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rewards — Coming in Sprint 5'), findsOneWidget);
    });

    testWidgets('profile screen shows placeholder text', (tester) async {
      final router = _createStubTestRouter(initialLocation: '/profile');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile — Coming in Sprint 6'), findsOneWidget);
    });

    testWidgets('tab bar renders with all 5 tabs and bottom nav',
        (tester) async {
      final router = _createStubTestRouter(initialLocation: '/menu');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // CFPVTabBar should be present
      expect(find.byType(CFPVTabBar), findsOneWidget);

      // All 5 tab labels should be visible
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tab navigation switches screens correctly',
        (tester) async {
      final router = _createStubTestRouter(initialLocation: '/menu');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we start on menu
      expect(find.text('Menu — Coming in Sprint 2'), findsOneWidget);

      // Navigate to each tab and verify content changes
      final tabMappings = [
        ('Home', 'Home Page'),
        ('Menu', 'Menu — Coming in Sprint 2'),
        ('Cart', 'Cart — Coming in Sprint 3'),
        ('Rewards', 'Rewards — Coming in Sprint 5'),
        ('Profile', 'Profile — Coming in Sprint 6'),
      ];

      for (final (tabLabel, expectedText) in tabMappings) {
        // Use runAsync to handle GoRouter's async route processing
        await tester.runAsync(() async {
          await tester.tap(find.text(tabLabel));
          await Future.delayed(const Duration(milliseconds: 200));
        });

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text(expectedText), findsOneWidget,
            reason: 'After tapping "$tabLabel" tab, expected "$expectedText"',);
      }
    });
  });
}
