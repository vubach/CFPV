import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../model/order_model.dart';
import '../../provider/order_provider.dart';
import '../../state/order_state.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_status_timeline.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/buttons/confirmation_action_button.dart';
import '../../../../shared/widgets/cards/card_container.dart';
import '../../../../shared/widgets/cards/total_row.dart';
import '../../../../shared/widgets/cards/notes_card.dart';
import '../../../../shared/widgets/cards/item_row.dart';

/// Full-screen order detail with item list, status timeline, and cancel action.
class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderProvider);

    if (state is OrderStateLoading) {
      return _buildLoading(context);
    }

    final order = _findOrder(state);

    if (order == null) {
      return _buildNotFound(context, ref);
    }

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        children: [
          // ── Header Card ───────────────────────
          _HeaderCard(order: order),
          const SizedBox(height: CFPVSpacing.space3),

          // ── Timeline Card ─────────────────────
          _TimelineCard(order: order),
          const SizedBox(height: CFPVSpacing.space3),

          // ── Items Card ────────────────────────
          _ItemsCard(order: order),
          const SizedBox(height: CFPVSpacing.space3),

          // ── Notes ─────────────────────────────
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            NotesCard(notes: order.notes!),
            const SizedBox(height: CFPVSpacing.space3),
          ],

          // ── Cancel Button (active orders) ─────
          if (order.status.isActive) ...[
            ConfirmationActionButton(
              icon: Icons.cancel_outlined,
              label: 'Cancel Order',
              dialogTitle: 'Cancel Order',
              dialogContent:
                  'Are you sure you want to cancel this order? This action cannot be undone.',
              confirmLabel: 'Yes, Cancel',
              cancelLabel: 'Keep Order',
              onConfirm: () async {
                await ref.read(orderProvider.notifier).cancelOrder(order.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: CFPVSpacing.space3),
          ],

          // ── Reorder Button (final orders) ──────
          if (order.status.isFinal) ...[
            _ReorderButton(orderId: order.id, ref: ref),
            const SizedBox(height: CFPVSpacing.space4),
          ],
        ],
      ),
    );
  }

  Order? _findOrder(OrderState state) {
    return switch (state) {
      OrderStateLoaded(:final orders) => orders.where((o) => o.id == orderId).firstOrNull,
      _ => null,
    };
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: CFPVColors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(CFPVSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: CFPVColors.textBlackSoft.withOpacity(0.5),
              ),
              const SizedBox(height: CFPVSpacing.space4),
              Text(
                'Order not found',
                style: CFPVTypography.h2.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space3),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CFPVColors.greenAccent,
                  foregroundColor: CFPVColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Header card: store name, order ID, date, status badge ──────────

class _HeaderCard extends StatelessWidget {
  final Order order;
  const _HeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final createdAt = order.createdAt;
    final dateStr =
        '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';

    return CardContainer(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.storeName ?? 'Order',
                      style: CFPVTypography.h1,
                    ),
                    const SizedBox(height: CFPVSpacing.space1),
                    Text(
                      '#${order.id}',
                      style: CFPVTypography.small.copyWith(
                        color: CFPVColors.textBlackSoft,
                      ),
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
              OrderStatusBadge(status: order.status),
            ],
          ),
        ],
      ),
    );
  }
}

/// ── Timeline card ──────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final Order order;
  const _TimelineCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: OrderStatusTimeline(
        currentStatus: order.status,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      ),
    );
  }
}

/// ── Items card ─────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final Order order;
  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${order.itemCount})',
            style: CFPVTypography.smallBold.copyWith(
              color: CFPVColors.textBlackSoft,
            ),
          ),
          const SizedBox(height: CFPVSpacing.space3),

          // Item rows
          ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: CFPVSpacing.space2),
              child: ItemRow(
                quantity: item.quantity,
                productName: item.productName,
                subtitle: '\$${item.unitPrice.toStringAsFixed(2)} each',
                totalPrice: '\$${item.totalPrice.toStringAsFixed(2)}',
              ),
            ),),
          const Divider(height: CFPVSpacing.space4, color: CFPVColors.hairline),

          // Subtotal
          TotalRow(label: 'Subtotal', value: '\$${order.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: CFPVSpacing.space1),
          TotalRow(label: 'Tax', value: '\$${order.tax.toStringAsFixed(2)}'),
          const SizedBox(height: CFPVSpacing.space1),
          TotalRow(
            label: 'Total',
            value: '\$${order.total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

/// ── Reorder button ────────────────────────────────────────────────

class _ReorderButton extends StatelessWidget {
  final String orderId;
  final WidgetRef ref;

  const _ReorderButton({
    required this.orderId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _onReorder(context),
        icon: const Icon(Icons.replay_outlined),
        label: const Text('Reorder'),
        style: ElevatedButton.styleFrom(
          backgroundColor: CFPVColors.greenAccent,
          foregroundColor: CFPVColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.button),
          ),
          textStyle: CFPVTypography.buttonLabel,
        ),
      ),
    );
  }

  Future<void> _onReorder(BuildContext context) async {
    await ref.read(orderProvider.notifier).reorderOrder(orderId);
    if (!context.mounted) return;

    // Check if reorder failed (OrderNotifier catches errors internally)
    final currentState = ref.read(orderProvider);
    if (currentState is OrderStateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reorder: ${currentState.message}'),
          backgroundColor: CFPVColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Items added to your cart'),
        backgroundColor: CFPVColors.greenAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: CFPVColors.white,
          onPressed: () => context.go(RoutePaths.cart),
        ),
      ),
    );
    if (!context.mounted) return;
    context.go(RoutePaths.cart);
  }
}


