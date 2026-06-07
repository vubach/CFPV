import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/rewards_provider.dart';
import '../../state/rewards_state.dart';
import '../../model/rewards_transaction_model.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/state/state.dart';

/// Full-screen rewards page with balance, tier progress, and transaction history.
class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rewardsProvider.notifier).fetchRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: CFPVColors.white,
        surfaceTintColor: CFPVColors.white,
      ),
      body: switch (state) {
        RewardsInitial() => const SizedBox.shrink(),
        RewardsLoading() => const StateLoading(),
        RewardsError(:final message) => StateError(
            title: 'Could not load rewards',
            message: message,
            onRetry: () => ref.read(rewardsProvider.notifier).fetchRewards(),
          ),
        RewardsLoaded(:final balance, :final transactions) => _RewardsContent(
            balance: balance,
            transactions: transactions,
            onRefresh: () => ref.read(rewardsProvider.notifier).fetchRewards(),
          ),
      },
    );
  }
}

// ── Main rewards content with balance card and transaction list ──
class _RewardsContent extends StatelessWidget {
  final int balance;
  final List<RewardsTransaction> transactions;
  final VoidCallback onRefresh;

  const _RewardsContent({
    required this.balance,
    required this.transactions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: CFPVColors.greenAccent,
      child: ListView(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        children: [
          // ── Balance Card ──────────────────────
          _BalanceCard(balance: balance),
          const SizedBox(height: CFPVSpacing.space4),

          // ── Loyalty Tier ──────────────────────
          _TierCard(balance: balance),
          const SizedBox(height: CFPVSpacing.space4),

          // ── Transaction History ───────────────
          const _SectionHeader(title: 'Transaction History'),
          const SizedBox(height: CFPVSpacing.space3),
          if (transactions.isEmpty)
            const StateEmpty(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              description: 'Start ordering to earn rewards points!',
            )
          else
            ...transactions.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: CFPVSpacing.space3),
                  child: _TransactionCard(transaction: t),
                ),),
        ],
      ),
    );
  }
}

/// Gold balance card showing total points.
class _BalanceCard extends StatelessWidget {
  final int balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CFPVSpacing.space5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CFPVColors.houseGreen, CFPVColors.greenUplift],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CFPVRadius.card),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: CFPVColors.houseGreen.withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Star icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CFPVColors.gold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: CFPVColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(height: CFPVSpacing.space3),

          // Balance
          Text(
            '$balance',
            style: CFPVTypography.jumbo.copyWith(
              color: CFPVColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CFPVSpacing.space1),
          Text(
            balance == 1 ? 'Point' : 'Points',
            style: CFPVTypography.body.copyWith(
              color: CFPVColors.textWhiteSoft,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loyalty tier card with progress indicator.
class _TierCard extends StatelessWidget {
  final int balance;

  const _TierCard({required this.balance});

  /// Determine tier index (0=Green, 1=Gold, 2=Platinum).
  int get _tierIndex {
    if (balance >= 500) return 2; // Platinum
    if (balance >= 200) return 1; // Gold
    return 0; // Green
  }

  String get _tierName {
    return switch (_tierIndex) {
      0 => 'Green',
      1 => 'Gold',
      _ => 'Platinum',
    };
  }

  String get _nextTierName {
    return switch (_tierIndex) {
      0 => 'Gold',
      1 => 'Platinum',
      _ => 'Max',
    };
  }

  int get _nextTierThreshold {
    return switch (_tierIndex) {
      0 => 200,
      1 => 500,
      _ => 500, // Already at max
    };
  }

  double get _progress {
    return switch (_tierIndex) {
      0 => balance / 200,
      1 => (balance - 200) / 300,
      _ => 1.0,
    };
  }

  IconData get _tierIcon {
    return switch (_tierIndex) {
      0 => Icons.eco_outlined,
      1 => Icons.emoji_events_outlined,
      _ => Icons.diamond_outlined,
    };
  }

  Color get _tierColor {
    return switch (_tierIndex) {
      0 => CFPVColors.greenAccent,
      1 => CFPVColors.gold,
      _ => const Color(0xFF6A5ACD),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CFPVSpacing.space4),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 0.5,
            color: Colors.black.withOpacity(0.14),
          ),
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier header
          Row(
            children: [
              Icon(_tierIcon, color: _tierColor, size: 24),
              const SizedBox(width: CFPVSpacing.space2),
              Text(
                '$_tierName Tier',
                style: CFPVTypography.h1.copyWith(
                  color: _tierColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: CFPVSpacing.space3),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(CFPVRadius.circular),
            child: LinearProgressIndicator(
              value: _progress.clamp(0.0, 1.0),
              backgroundColor: CFPVColors.neutralCool,
              valueColor: AlwaysStoppedAnimation<Color>(_tierColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: CFPVSpacing.space2),

          // Next tier info
          if (_tierIndex < 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tierName,
                  style: CFPVTypography.small.copyWith(
                    color: CFPVColors.textBlackSoft,
                  ),
                ),
                Text(
                  _nextTierName,
                  style: CFPVTypography.small.copyWith(
                    color: CFPVColors.textBlackSoft,
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                'You\'ve reached the highest tier!',
                style: CFPVTypography.small.copyWith(
                  color: CFPVColors.textBlackSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          if (_tierIndex < 2) ...[
            const SizedBox(height: CFPVSpacing.space2),
            Text(
              '${_nextTierThreshold - balance} points to $_nextTierName',
              style: CFPVTypography.smallBold.copyWith(
                color: _tierColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section header with title.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: CFPVTypography.smallBold.copyWith(
        color: CFPVColors.textBlackSoft,
      ),
    );
  }
}

/// A single transaction row showing points earned/redeemed.
class _TransactionCard extends StatelessWidget {
  final RewardsTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dt = transaction.createdAt;
    final dateStr =
        '${months[dt.month - 1]} ${dt.day}, ${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      padding: const EdgeInsets.all(CFPVSpacing.space3),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isEarned
                  ? CFPVColors.greenLight
                  : CFPVColors.goldLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(CFPVRadius.card - 4),
            ),
            child: Icon(
              transaction.isEarned
                  ? Icons.add_card_outlined
                  : Icons.redeem_outlined,
              size: 20,
              color: transaction.isEarned
                  ? CFPVColors.starbucksGreen
                  : CFPVColors.gold,
            ),
          ),
          const SizedBox(width: CFPVSpacing.space3),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: CFPVTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: CFPVColors.textBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: CFPVTypography.small.copyWith(
                    color: CFPVColors.textBlackSoft,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${transaction.isEarned ? '+' : '-'}${transaction.points}',
            style: CFPVTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              color: transaction.isEarned
                  ? CFPVColors.starbucksGreen
                  : CFPVColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
