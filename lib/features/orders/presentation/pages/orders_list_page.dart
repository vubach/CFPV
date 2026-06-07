import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../model/order_model.dart';
import '../../provider/order_provider.dart';
import '../../state/order_state.dart';
import '../widgets/order_card_widget.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/state/state.dart';

/// Full-screen order history list.
/// Displays loading, empty, error, and loaded states.
class OrdersListPage extends ConsumerStatefulWidget {
  const OrdersListPage({super.key});

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch orders on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: switch (state) {
        OrderStateInitial() => const SizedBox.shrink(),
        OrderStateLoading() => const StateLoading(),
        OrderStateError(:final message) => StateError(
            title: 'Could not load orders',
            message: message,
            onRetry: () => ref.read(orderProvider.notifier).fetchOrders(),
          ),
        OrderStateLoaded(:final orders) => orders.isEmpty
            ? const StateEmpty(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                description: 'Place your first order and it will appear here.',
              )
            : _OrdersList(
                orders: orders,
                onRefresh: () => ref.read(orderProvider.notifier).fetchOrders(),
              ),
      },
    );
  }
}

/// Scrollable list of order cards with pull-to-refresh.
class _OrdersList extends StatelessWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;

  const _OrdersList({
    required this.orders,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: CFPVColors.greenAccent,
      child: ListView.separated(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: CFPVSpacing.space3),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            onTap: () => context.go(
              RoutePaths.orderDetail(order.id),
            ),
          );
        },
      ),
    );
  }
}
