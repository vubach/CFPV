import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/model/cart_model.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../../orders/provider/order_provider.dart';
import '../../../orders/state/order_state.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/cards/total_row.dart';
import '../../../../shared/widgets/cards/item_row.dart';
import '../../../../shared/widgets/cards/bottom_action_bar.dart';

/// Payment method options.
enum PaymentMethod {
  creditCard('Credit / Debit Card', Icons.credit_card_outlined),
  paypal('PayPal', Icons.account_balance_wallet_outlined),
  cashOnPickup('Cash on Pickup', Icons.payments_outlined);

  final String label;
  final IconData icon;
  const PaymentMethod(this.label, this.icon);
}

/// Full-screen checkout page with order summary, payment selection, and place order.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethod _selectedPayment = PaymentMethod.creditCard;
  final _notesController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).fetchCart();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    final cart = ref.read(cartProvider).cart;
    if (cart == null) {
      setState(() => _isPlacingOrder = false);
      return;
    }

    final items = cart.items
        .map((item) => {
              'productId': item.productId,
              'quantity': item.quantity,
              if (item.notes != null && item.notes!.isNotEmpty)
                'notes': item.notes,
            },)
        .toList();

    await ref.read(orderProvider.notifier).placeOrder(
          items: items,
          storeId: cart.storeId,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );

    if (!mounted) return;

    // Check if place order failed (OrderNotifier catches errors internally)
    final currentOrderState = ref.read(orderProvider);
    if (currentOrderState is OrderStateError) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${currentOrderState.message}'),
          backgroundColor: CFPVColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
      return;
    }

    // After placing, clear the cart and navigate to order history
    await ref.read(cartProvider.notifier).clearCart();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order placed successfully!'),
        backgroundColor: CFPVColors.greenAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
      ),
    );

    context.go(RoutePaths.profileOrders);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final orderState = ref.watch(orderProvider);

    final cart = cartState.cart;
    final isLoading = orderState.isLoading || _isPlacingOrder;

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: CFPVColors.white,
        surfaceTintColor: CFPVColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: cart == null
          ? const _CartMissingState()
          : cart.isEmpty
              ? const _CartEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(CFPVSpacing.space4),
                        children: [
                          // ── Order Summary ──────────────
                          const _SectionHeader(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Order Summary',
                          ),
                          const SizedBox(height: CFPVSpacing.space3),
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: CFPVSpacing.space3,),
                              child: Container(
                              padding: const EdgeInsets.all(CFPVSpacing.space3),
                              decoration: BoxDecoration(
                                color: CFPVColors.white,
                                borderRadius: BorderRadius.circular(CFPVRadius.card),
                              ),
                              child: ItemRow(
                                leadingGap: CFPVSpacing.space3,
                                leading: ItemRow.imagePlaceholder(),
                                productName: item.productName,
                                productNameMaxLines: 1,
                                productNameOverflow: TextOverflow.ellipsis,
                                subtitle: 'Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                subtitleGap: 2,
                                totalPrice: '\$${item.totalPrice.toStringAsFixed(2)}',
                                totalPriceColor: CFPVColors.starbucksGreen,
                              ),
                            ),
                            ),
                          ),
                          const SizedBox(height: CFPVSpacing.space2),

                          // Totals card
                          _TotalsCard(cart: cart),

                          const SizedBox(height: CFPVSpacing.space5),

                          // ── Payment Method ─────────────
                          const _SectionHeader(
                            icon: Icons.payment_outlined,
                            title: 'Payment Method',
                          ),
                          const SizedBox(height: CFPVSpacing.space3),
                          _PaymentMethodSelector(
                            selected: _selectedPayment,
                            onChanged: (method) {
                              setState(() => _selectedPayment = method);
                            },
                          ),

                          const SizedBox(height: CFPVSpacing.space5),

                          // ── Order Notes ────────────────
                          const _SectionHeader(
                            icon: Icons.note_alt_outlined,
                            title: 'Order Notes',
                          ),
                          const SizedBox(height: CFPVSpacing.space3),
                          Container(
                            decoration: BoxDecoration(
                              color: CFPVColors.white,
                              borderRadius:
                                  BorderRadius.circular(CFPVRadius.card),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: 3,
                              maxLength: 200,
                              decoration: InputDecoration(
                                hintText:
                                    'Any special requests or instructions...',
                                hintStyle: CFPVTypography.body.copyWith(
                                  color: CFPVColors.textBlackSoft
                                      .withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.all(CFPVSpacing.space3),
                                counterStyle: CFPVTypography.micro.copyWith(
                                  color: CFPVColors.textBlackSoft,
                                ),
                              ),
                              style: CFPVTypography.body,
                            ),
                          ),

                          // Bottom spacing for scroll
                          const SizedBox(height: CFPVSpacing.space8),
                        ],
                      ),
                    ),

                    // ── Bottom Bar: Total + Place Order ──
                    _CheckoutBottomBar(
                      total: cart.total,
                      itemCount: cart.itemCount,
                      isLoading: isLoading,
                      selectedPayment: _selectedPayment,
                      onPlaceOrder: _placeOrder,
                    ),
                  ],
                ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────

/// Section header with icon.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: CFPVColors.starbucksGreen),
        const SizedBox(width: CFPVSpacing.space2),
        Text(
          title,
          style: CFPVTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: CFPVColors.starbucksGreen,
          ),
        ),
      ],
    );
  }
}

/// Subtotal, tax, total summary card.
class _TotalsCard extends StatelessWidget {
  final Cart cart;

  const _TotalsCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CFPVSpacing.space3),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
      ),
      child: Column(
        children: [
          TotalRow(label: 'Subtotal', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          TotalRow(
            label: 'Tax',
            value: '\$${cart.tax.toStringAsFixed(2)}',
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
                '\$${cart.total.toStringAsFixed(2)}',
                style: CFPVTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: CFPVColors.starbucksGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Radio button list for payment method selection.
class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
      ),
      child: Column(
        children: PaymentMethod.values.map((method) {
          final isSelected = method == selected;
          return Column(
            children: [
              if (method != PaymentMethod.values.first)
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: CFPVSpacing.space3,),
                  child: Divider(height: 1, color: CFPVColors.hairline),
                ),
              InkWell(
                onTap: () => onChanged(method),
                borderRadius: method == PaymentMethod.values.first
                    ? const BorderRadius.vertical(top: Radius.circular(CFPVRadius.card))
                    : method == PaymentMethod.values.last
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(CFPVRadius.card),)
                        : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CFPVSpacing.space3,
                    vertical: CFPVSpacing.space2 + 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        method.icon,
                        size: 24,
                        color: isSelected
                            ? CFPVColors.greenAccent
                            : CFPVColors.textBlackSoft,
                      ),
                      const SizedBox(width: CFPVSpacing.space3),
                      Expanded(
                        child: Text(
                          method.label,
                          style: CFPVTypography.body.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? CFPVColors.textBlack
                                : CFPVColors.textBlackSoft,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? CFPVColors.greenAccent
                            : CFPVColors.textBlackSoft.withOpacity(0.4),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Bottom bar with total and place order button.
class _CheckoutBottomBar extends StatelessWidget {
  final double total;
  final int itemCount;
  final bool isLoading;
  final PaymentMethod selectedPayment;
  final VoidCallback onPlaceOrder;

  const _CheckoutBottomBar({
    required this.total,
    required this.itemCount,
    required this.isLoading,
    required this.selectedPayment,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: CFPVSpacing.space2),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onPlaceOrder,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CFPVColors.white,
                      ),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              label: Text(
                isLoading
                    ? 'Placing Order...'
                    : itemCount == 1
                        ? 'Place Order — 1 item'
                        : 'Place Order — $itemCount items',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CFPVColors.greenAccent,
                foregroundColor: CFPVColors.white,
                disabledBackgroundColor: CFPVColors.greenAccent.withOpacity(0.5),
                disabledForegroundColor: CFPVColors.white.withOpacity(0.7),
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

/// Shown when cart data is missing.
class _CartMissingState extends StatelessWidget {
  const _CartMissingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: CFPVColors.textBlackSoft.withOpacity(0.5),
            ),
            const SizedBox(height: CFPVSpacing.space3),
            Text(
              'Unable to load cart',
              style: CFPVTypography.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: CFPVSpacing.space4),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: CFPVColors.greenAccent,
                foregroundColor: CFPVColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CFPVRadius.button),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: CFPVSpacing.space4,
                  vertical: CFPVSpacing.space2,
                ),
              ),
              child: const Text('Go to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when cart is empty.
class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: CFPVColors.textBlackSoft.withOpacity(0.5),
            ),
            const SizedBox(height: CFPVSpacing.space4),
            Text(
              'Your cart is empty',
              style: CFPVTypography.h2.copyWith(
                color: CFPVColors.textBlackSoft,
              ),
            ),
            const SizedBox(height: CFPVSpacing.space2),
            Text(
              'Add items before proceeding to checkout.',
              style: CFPVTypography.body.copyWith(
                color: CFPVColors.textBlackSoft.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CFPVSpacing.space5),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.menu),
              style: ElevatedButton.styleFrom(
                backgroundColor: CFPVColors.greenAccent,
                foregroundColor: CFPVColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CFPVRadius.button),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: CFPVSpacing.space5,
                  vertical: CFPVSpacing.space2,
                ),
              ),
              child: const Text('Browse Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
