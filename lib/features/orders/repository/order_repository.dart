import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../model/order_model.dart';

/// Handles all order-related API calls.
class OrderRepository {
  final DioClient _dio;

  OrderRepository({required DioClient dioClient}) : _dio = dioClient;

  /// Fetch all orders for the current user.
  Future<List<Order>> fetchOrders() async {
    final response = await _dio.get(ApiConstants.orders);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Place a new order from the current cart.
  Future<Order> placeOrder({
    List<Map<String, dynamic>>? items,
    String? storeId,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiConstants.orders,
      data: {
        if (items != null) 'items': items,
        if (storeId != null) 'storeId': storeId,
        if (notes != null) 'notes': notes,
      },
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  /// Cancel an existing order by ID.
  Future<Order> cancelOrder(String orderId) async {
    final response = await _dio.post(
      ApiConstants.orderCancel(orderId),
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  /// Reorder an existing order, adding its items back to the cart.
  Future<Order> reorderOrder(String orderId) async {
    final response = await _dio.post(
      ApiConstants.orderReorder(orderId),
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }
}
