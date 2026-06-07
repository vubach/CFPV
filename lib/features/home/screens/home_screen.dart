import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/featured_items_scroll.dart';
import '../widgets/category_chips_row.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../../cart/provider/cart_provider.dart';
import '../../cart/state/cart_state.dart';
import '../../menu/model/category_model.dart';
import '../../menu/model/product_model.dart';
import '../../menu/provider/menu_provider.dart';
import '../../rewards/provider/rewards_provider.dart';
import '../../rewards/state/rewards_state.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/layout/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).fetchCart();
      ref.read(rewardsProvider.notifier).fetchRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartState = ref.watch(cartProvider);
    final rewardsState = ref.watch(rewardsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);

    final userName = authState is AuthStateAuthenticated
        ? authState.fullName.split(' ').first
        : 'there';
    final pointsBalance = rewardsState.balance > 0 ? rewardsState.balance : null;
    final cartItemCount = cartState.cart?.itemCount;

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(
              greeting: _timeBasedGreeting(userName),
              pointsBalance: pointsBalance,
              cartItemCount: cartItemCount,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroBanner(
                      items: [
                        BannerItem(
                          title: 'Summer Drinks',
                          subtitle: 'New! Refreshing flavors waiting for you',
                          ctaLabel: 'Order Now',
                          onTap: () => context.go(RoutePaths.menu),
                        ),
                        BannerItem(
                          title: 'Earn Rewards',
                          subtitle: 'Collect points with every purchase',
                          ctaLabel: 'Learn More',
                          onTap: () => context.go(RoutePaths.rewards),
                          backgroundColor: CFPVColors.starbucksGreen,
                        ),
                        BannerItem(
                          title: 'Morning Boost',
                          subtitle: 'Start your day with our signature coffee',
                          ctaLabel: 'Browse Menu',
                          onTap: () => context.go(RoutePaths.menu),
                          backgroundColor: CFPVColors.houseGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: CFPVSpacing.space4),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CFPVSpacing.space3,
                      ),
                      child: Row(
                        children: [
                          QuickActionCard(
                            icon: Icons.replay,
                            label: 'Order Again',
                            onTap: () => context.go(RoutePaths.profileOrders),
                          ),
                          const SizedBox(width: CFPVSpacing.space2),
                          QuickActionCard(
                            icon: Icons.menu_book_outlined,
                            label: 'Menu',
                            onTap: () => context.go(RoutePaths.menu),
                          ),
                          const SizedBox(width: CFPVSpacing.space2),
                          QuickActionCard(
                            icon: Icons.star_border,
                            label: 'Rewards',
                            iconColor: CFPVColors.gold,
                            onTap: () => context.go(RoutePaths.rewards),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CFPVSpacing.space5),
                    SectionHeader(title: 'Featured Items'),
                    const SizedBox(height: CFPVSpacing.space2),
                    featuredAsync.when(
                      data: (products) => FeaturedItemsScroll(
                        products: products,
                        onProductTap: (product) => context.go(
                          RoutePaths.productDetail(product.id),
                        ),
                      ),
                      loading: () => const _FeaturedSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: CFPVSpacing.space5),
                    SectionHeader(title: 'Categories'),
                    const SizedBox(height: CFPVSpacing.space2),
                    categoriesAsync.when(
                      data: (categories) => CategoryChipsRow(
                        categories: categories,
                        onCategoryTap: (category) => context.go(
                          RoutePaths.menu,
                        ),
                      ),
                      loading: () => const _CategoryChipsSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: CFPVSpacing.space5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeBasedGreeting(String userName) {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      < 12 => 'Good morning',
      < 18 => 'Good afternoon',
      _ => 'Good evening',
    };
    return '$greeting, $userName!';
  }
}

class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space3),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: CFPVSpacing.space2),
        itemBuilder: (_, __) => Container(
          width: 140,
          decoration: BoxDecoration(
            color: CFPVColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: const BoxDecoration(
                  color: CFPVColors.neutralCool,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(CFPVSpacing.space2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: CFPVColors.neutralCool,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 50,
                      decoration: BoxDecoration(
                        color: CFPVColors.neutralCool,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChipsSkeleton extends StatelessWidget {
  const _CategoryChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space3),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: CFPVSpacing.space2),
        itemBuilder: (_, __) => Container(
          width: 100,
          height: 36,
          decoration: BoxDecoration(
            color: CFPVColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CFPVColors.inputBorder),
          ),
        ),
      ),
    );
  }
}
