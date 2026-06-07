import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../model/cart_model.dart';
import '../repository/cart_repository.dart';
import '../state/cart_state.dart';

/// Manages cart state: fetch, add, update, remove, and clear operations.
class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(const CartStateInitial());

  /// Fetch the full cart from the server.
  Future<void> fetchCart() async {
    state = const CartStateLoading();
    try {
      final cart = await _repository.fetchCart();
      state = CartStateLoaded(cart);
    } catch (e) {
      state = CartStateError(e.toString());
    }
  }

  /// Add an item to the cart, then reload the full cart.
  Future<void> addItem({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    state = const CartStateLoading();
    try {
      await _repository.addItem(
        productId: productId,
        quantity: quantity,
        notes: notes,
      );
      final cart = await _repository.fetchCart();
      state = CartStateLoaded(cart);
    } catch (e) {
      state = CartStateError(e.toString());
    }
  }

  /// Update item quantity, then reload the full cart.
  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    state = const CartStateLoading();
    try {
      await _repository.updateItemQuantity(
        itemId: itemId,
        quantity: quantity,
      );
      final cart = await _repository.fetchCart();
      state = CartStateLoaded(cart);
    } catch (e) {
      state = CartStateError(e.toString());
    }
  }

  /// Remove an item from the cart, then reload.
  Future<void> removeItem(String itemId) async {
    state = const CartStateLoading();
    try {
      await _repository.removeItem(itemId);
      final cart = await _repository.fetchCart();
      state = CartStateLoaded(cart);
    } catch (e) {
      state = CartStateError(e.toString());
    }
  }

  /// Clear the entire cart.
  Future<void> clearCart() async {
    state = const CartStateLoading();
    try {
      await _repository.clearCart();
      state = const CartStateLoaded(Cart());
    } catch (e) {
      state = CartStateError(e.toString());
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final dio = DioClient.instance;
  final repository = CartRepository(dioClient: dio);
  return CartNotifier(repository);
});
