import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/rewards/model/rewards_transaction_model.dart';
import 'package:cfpv/features/rewards/provider/rewards_provider.dart';
import 'package:cfpv/features/rewards/repository/rewards_repository.dart';
import 'package:cfpv/features/rewards/state/rewards_state.dart';
import 'package:cfpv/features/rewards/presentation/pages/rewards_page.dart';

/// Mock rewards repository with controllable behavior.
class _MockRewardsRepository extends RewardsRepository {
  bool _shouldThrow = false;
  int _mockBalance = 150;
  List<RewardsTransaction> _mockTransactions = [];

  _MockRewardsRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setShouldThrow(bool value) {
    _shouldThrow = value;
  }

  void setBalance(int balance) {
    _mockBalance = balance;
  }

  void setTransactions(List<RewardsTransaction> transactions) {
    _mockTransactions = transactions;
  }

  @override
  Future<int> fetchBalance() async {
    if (_shouldThrow) throw Exception('Network error');
    return _mockBalance;
  }

  @override
  Future<List<RewardsTransaction>> fetchTransactions() async {
    if (_shouldThrow) throw Exception('Network error');
    return _mockTransactions;
  }
}

/// Build a test app wrapping the real RewardsPage with the given notifier.
Widget _buildApp(RewardsNotifier notifier) {
  final goRouter = GoRouter(
    initialLocation: '/rewards',
    routes: [
      GoRoute(
        path: '/rewards',
        name: 'rewards',
        builder: (_, __) => const RewardsPage(),
      ),
    ],
  );

  final container = ProviderContainer(
    overrides: [
      rewardsProvider.overrideWith((_) => notifier),
    ],
  );

  return ProviderScope(
    parent: container,
    child: MaterialApp.router(
      routerConfig: goRouter,
    ),
  );
}

/// Common pump sequence — processes initState postFrameCallback + async fetch.
Future<void> settleRewardsPage(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

void main() {
  group('RewardsPage', () {
    testWidgets('shows points balance', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setBalance(250);
      final notifier = RewardsNotifier(repo);
      notifier.state = const RewardsLoaded(balance: 250, transactions: []);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('250'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows "Point" (singular) for balance of 1', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setBalance(1);
      final notifier = RewardsNotifier(repo);
      notifier.state = const RewardsLoaded(balance: 1, transactions: []);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Point'), findsOneWidget);
      expect(find.text('Points'), findsNothing);
    });

    testWidgets('shows Green tier for under 200 points', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setBalance(150);
      final notifier = RewardsNotifier(repo);
      notifier.state = const RewardsLoaded(balance: 150, transactions: []);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('Green Tier'), findsOneWidget);
      expect(find.textContaining('50 points to Gold'), findsOneWidget);
    });

    testWidgets('shows Gold tier for 200–499 points', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setBalance(350);
      final notifier = RewardsNotifier(repo);
      notifier.state = const RewardsLoaded(balance: 350, transactions: []);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('Gold Tier'), findsOneWidget);
      expect(find.textContaining('150 points to Platinum'), findsOneWidget);
    });

    testWidgets('shows Platinum tier for 500+ points', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setBalance(500);
      final notifier = RewardsNotifier(repo);
      notifier.state = const RewardsLoaded(balance: 500, transactions: []);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('Platinum Tier'), findsOneWidget);
      expect(find.text("You've reached the highest tier!"), findsOneWidget);
    });

    testWidgets('shows earned and redeemed transaction in history',
        (tester) async {
      // Use a tall surface so all transaction cards are built by SliverList
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _MockRewardsRepository();
      repo.setBalance(175);
      final txnEarn = RewardsTransaction(
        id: 'txn-1',
        description: 'Order #1234',
        points: 50,
        isEarned: true,
        createdAt: DateTime(2026, 6, 1, 14, 30),
      );
      final txnRedeem = RewardsTransaction(
        id: 'txn-2',
        description: 'Redeemed Free Drink',
        points: 100,
        isEarned: false,
        createdAt: DateTime(2026, 5, 15, 9, 0),
      );
      repo.setTransactions([txnEarn, txnRedeem]);
      final notifier = RewardsNotifier(repo);
      notifier.state =
          RewardsLoaded(balance: 175, transactions: [txnEarn, txnRedeem]);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      // Section header
      expect(find.text('Transaction History'), findsOneWidget);

      // Both descriptions
      expect(find.text('Order #1234'), findsOneWidget);
      expect(find.text('Redeemed Free Drink'), findsOneWidget);

      // Both points values
      expect(find.text('+50'), findsOneWidget);
      expect(find.text('-100'), findsOneWidget);

      // Both icons
      expect(find.byIcon(Icons.add_card_outlined), findsOneWidget);
      expect(find.byIcon(Icons.redeem_outlined), findsOneWidget);
    });

    testWidgets('shows empty transactions state', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setBalance(50);
      repo.setTransactions([]);
      final notifier = RewardsNotifier(repo);
      notifier.state = const RewardsLoaded(balance: 50, transactions: []);

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text('Start ordering to earn rewards points!'),
        findsOneWidget,
      );
    });

    testWidgets('shows error state with retry button', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setShouldThrow(true);
      final notifier = RewardsNotifier(repo);
      await notifier.fetchRewards();

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('Could not load rewards'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('tapping retry reloads rewards after error', (tester) async {
      final repo = _MockRewardsRepository();
      repo.setShouldThrow(true);

      final notifier = RewardsNotifier(repo);
      await notifier.fetchRewards();

      await tester.pumpWidget(_buildApp(notifier));
      await settleRewardsPage(tester);

      expect(find.text('Could not load rewards'), findsOneWidget);

      repo.setShouldThrow(false);
      repo.setBalance(300);

      await tester.tap(find.text('Try Again'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      expect(find.text('300'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
    });
  });
}
