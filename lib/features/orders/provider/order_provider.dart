import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../repository/order_repository.dart';
import '../state/order_state.dart';

/// Manages order state: fetch, place, and cancel operations.
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const OrderStateInitial());

  /// Fetch all orders from the server.
  Future<void> fetchOrders() async {
    state = const OrderStateLoading();
    try {
      final orders = await _repository.fetchOrders();
      state = OrderStateLoaded(orders);
    } catch (e) {
      state = OrderStateError(e.toString());
    }
  }

  /// Place a new order, then reload the orders list.
  Future<void> placeOrder({
    List<Map<String, dynamic>>? items,
    String? storeId,
    String? notes,
  }) async {
    state = const OrderStateLoading();
    try {
      await _repository.placeOrder(
        items: items,
        storeId: storeId,
        notes: notes,
      );
      final orders = await _repository.fetchOrders();
      state = OrderStateLoaded(orders);
    } catch (e) {
      state = OrderStateError(e.toString());
    }
  }

  /// Cancel an order, then reload the orders list.
  Future<void> cancelOrder(String orderId) async {
    state = const OrderStateLoading();
    try {
      await _repository.cancelOrder(orderId);
      final orders = await _repository.fetchOrders();
      state = OrderStateLoaded(orders);
    } catch (e) {
      state = OrderStateError(e.toString());
    }
  }

  /// Reorder an existing order, adding its items back to the cart.
  Future<void> reorderOrder(String orderId) async {
    state = const OrderStateLoading();
    try {
      await _repository.reorderOrder(orderId);
      final orders = await _repository.fetchOrders();
      state = OrderStateLoaded(orders);
    } catch (e) {
      state = OrderStateError(e.toString());
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final dio = DioClient.instance;
  final repository = OrderRepository(dioClient: dio);
  return OrderNotifier(repository);
});
