import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../model/cart_model.dart';
import '../model/cart_item_model.dart';

/// Handles all cart-related API calls.
class CartRepository {
  final DioClient _dio;

  CartRepository({required DioClient dioClient}) : _dio = dioClient;

  /// Fetch the current cart from the server.
  Future<Cart> fetchCart() async {
    final response = await _dio.get(ApiConstants.cart);
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  /// Add an item to the cart.
  Future<Cart> addItem({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiConstants.cartItems,
      data: {
        'productId': productId,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      },
    );
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update the quantity of an existing cart item.
  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    await _dio.patch(
      ApiConstants.cartItemById(itemId),
      data: {'quantity': quantity},
    );
  }

  /// Remove an item from the cart.
  Future<void> removeItem(String itemId) async {
    await _dio.delete(ApiConstants.cartItemById(itemId));
  }

  /// Clear all items from the cart.
  Future<void> clearCart() async {
    await _dio.delete(ApiConstants.cart);
  }
}
