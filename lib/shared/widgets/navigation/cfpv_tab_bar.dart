import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/cart/provider/cart_provider.dart';
import '../../../shared/theme/colors.dart';

/// Tab definitions for the CFPV bottom navigation.
enum CFPVTab {
  home('Home', Icons.home_outlined, Icons.home),
  menu('Menu', Icons.menu_book_outlined, Icons.menu_book),
  cart('Cart', Icons.shopping_bag_outlined, Icons.shopping_bag),
  rewards('Rewards', Icons.star_border, Icons.star),
  profile('Profile', Icons.person_outline, Icons.person);

  final String label;
  final IconData icon;
  final IconData activeIcon;

  const CFPVTab(this.label, this.icon, this.activeIcon);
}

/// CFPV bottom navigation tab bar.
/// Design: DESIGN.md §9.4
class CFPVTabBar extends StatelessWidget {
  final int currentIndex;
  final int? cartBadgeCount;
  final ValueChanged<int> onTap;

  const CFPVTabBar({
    super.key,
    required this.currentIndex,
    this.cartBadgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CFPVColors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.black.withOpacity(0.1),
          ),
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CFPVTab.values.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive ? tab.activeIcon : tab.icon,
                                size: 24,
                                color: isActive
                                    ? CFPVColors.greenAccent
                                    : CFPVColors.textBlackSoft,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: isActive
                                      ? CFPVColors.greenAccent
                                      : CFPVColors.textBlackSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cart badge
                        if (tab == CFPVTab.cart &&
                            cartBadgeCount != null &&
                            cartBadgeCount! > 0)
                          Positioned(
                            top: 2,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: CFPVColors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(minWidth: 16),
                              child: Text(
                                cartBadgeCount! > 99
                                    ? '99+'
                                    : cartBadgeCount.toString(),
                                style: const TextStyle(
                                  color: CFPVColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Shell widget that wraps tab-root screens with the CFPVTabBar.
class CFPVTabShell extends StatefulWidget {
  final Widget child;

  const CFPVTabShell({super.key, required this.child});

  @override
  State<CFPVTabShell> createState() => _CFPVTabShellState();
}

class _CFPVTabShellState extends State<CFPVTabShell> {
  int _currentIndex = 0;

  static final _routeToIndex = <String, int>{
    '/home': 0,
    '/menu': 1,
    '/cart': 2,
    '/rewards': 3,
    '/profile': 4,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final basePath = '/${location.split('/')[1]}';
    _currentIndex = _routeToIndex[basePath] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final cartState = ref.watch(cartProvider);
          final itemCount = cartState.cart?.itemCount ?? 0;
          return CFPVTabBar(
            currentIndex: _currentIndex,
            cartBadgeCount: itemCount > 0 ? itemCount : null,
            onTap: (index) {
              setState(() => _currentIndex = index);
              final route = CFPVTab.values[index];
              final path = '/${route.name}';
              context.go(path);
            },
          );
        },
      ),
    );
  }
}
