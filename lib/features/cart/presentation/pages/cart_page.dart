import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../provider/cart_provider.dart';
import '../../state/cart_state.dart';
import '../../model/cart_model.dart';
import '../../model/cart_item_model.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/state/state.dart';
import '../../../../shared/widgets/cards/total_row.dart';
import '../../../../shared/widgets/cards/bottom_action_bar.dart';
import '../../../../core/router/route_paths.dart';

/// Full-screen cart page with item list, quantity controls, summary, and checkout.
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: CFPVColors.white,
        surfaceTintColor: CFPVColors.white,
        actions: [
          if (state.cart != null && state.cart!.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(context),
              child: Text(
                'Clear',
                style: CFPVTypography.buttonSmall.copyWith(
                  color: CFPVColors.red,
                ),
              ),
            ),
        ],
      ),
      body: switch (state) {
        CartStateInitial() => const SizedBox.shrink(),
        CartStateLoading() => const StateLoading(),
        CartStateError(:final message) => StateError(
            title: 'Could not load cart',
            message: message,
            onRetry: () => ref.read(cartProvider.notifier).fetchCart(),
          ),
        CartStateLoaded(:final cart) => cart.isEmpty
            ? StateEmpty(
                icon: Icons.shopping_bag_outlined,
                title: 'Your cart is empty',
                description: 'Browse our menu to add items.',
                actionLabel: 'Browse Menu',
                actionOnPressed: () => context.go(RoutePaths.menu),
              )
            : _CartContent(
                cart: cart,
                onUpdateQuantity: (itemId, quantity) {
                  if (quantity < 1) {
                    ref.read(cartProvider.notifier).removeItem(itemId);
                  } else {
                    ref.read(cartProvider.notifier).updateItemQuantity(
                      itemId: itemId,
                      quantity: quantity,
                    );
                  }
                },
                onRemoveItem: (itemId) {
                  ref.read(cartProvider.notifier).removeItem(itemId);
                },
                onCheckout: () => context.push(RoutePaths.checkout),
              ),
      },
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: CFPVTypography.buttonSmall.copyWith(
                color: CFPVColors.textBlackSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cartProvider.notifier).clearCart();
            },
            child: Text(
              'Clear All',
              style: CFPVTypography.buttonSmall.copyWith(
                color: CFPVColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loaded cart with items, summary, and checkout ──
class _CartContent extends StatelessWidget {
  final Cart cart;
  final void Function(String itemId, int quantity) onUpdateQuantity;
  final void Function(String itemId) onRemoveItem;
  final VoidCallback onCheckout;

  const _CartContent({
    required this.cart,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              CFPVSpacing.space4,
              CFPVSpacing.space4,
              CFPVSpacing.space4,
              0,
            ),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: CFPVSpacing.space3),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemCard(
                item: item,
                onIncrement: () =>
                    onUpdateQuantity(item.id, item.quantity + 1),
                onDecrement: () =>
                    onUpdateQuantity(item.id, item.quantity - 1),
                onRemove: () => onRemoveItem(item.id),
              );
            },
          ),
        ),

        // Order summary + checkout
        _CartBottomBar(
          subtotal: cart.subtotal,
          tax: cart.tax,
          total: cart.total,
          itemCount: cart.itemCount,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}

/// A single cart item card with quantity controls.
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: CFPVSpacing.space4),
        decoration: BoxDecoration(
          color: CFPVColors.red,
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
        child: const Icon(Icons.delete_outline, color: CFPVColors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(CFPVSpacing.space3),
        decoration: BoxDecoration(
          color: CFPVColors.white,
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CFPVColors.neutralCool,
                borderRadius: BorderRadius.circular(CFPVRadius.card - 4),
              ),
              child: Icon(
                Icons.local_cafe_outlined,
                color: CFPVColors.textBlackSoft.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: CFPVSpacing.space3),

            // Name, price, quantity controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    item.productName,
                    style: CFPVTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: CFPVSpacing.space1),
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)}',
                    style: CFPVTypography.small.copyWith(
                      color: CFPVColors.textBlackSoft,
                    ),
                  ),

                  const SizedBox(height: CFPVSpacing.space2),

                  // Quantity controls row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: onDecrement,
                      ),
                      const SizedBox(width: CFPVSpacing.space2),
                      Text(
                        '${item.quantity}',
                        style: CFPVTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: CFPVSpacing.space2),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: onIncrement,
                      ),
                    ],
                  ),

                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: CFPVSpacing.space1),
                    Text(
                      'Note: ${item.notes}',
                      style: CFPVTypography.micro.copyWith(
                        color: CFPVColors.textBlackSoft,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Line total + delete button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: CFPVTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CFPVColors.starbucksGreen,
                  ),
                ),
                const SizedBox(height: CFPVSpacing.space1),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: CFPVColors.textBlackSoft.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Round quantity adjust button (minus / plus).
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CFPVColors.neutralWarm,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: CFPVColors.textBlack),
        ),
      ),
    );
  }
}

/// Bottom bar with subtotal, tax, total, and checkout button.
class _CartBottomBar extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final int itemCount;
  final VoidCallback onCheckout;

  const _CartBottomBar({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.itemCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TotalRow(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          TotalRow(
            label: 'Tax',
            value: '\$${tax.toStringAsFixed(2)}',
            valueStyle: CFPVTypography.body.copyWith(
              color: CFPVColors.textBlackSoft,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: CFPVColors.hairline),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: CFPVTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: CFPVTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: CFPVColors.starbucksGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: CFPVSpacing.space3),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(
                itemCount == 1
                    ? 'Checkout — 1 item'
                    : 'Checkout — $itemCount items',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CFPVColors.greenAccent,
                foregroundColor: CFPVColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CFPVRadius.button),
                ),
                textStyle: CFPVTypography.buttonLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


