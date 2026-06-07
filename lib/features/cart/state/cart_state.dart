import '../model/cart_model.dart';

/// State of cart operations.
sealed class CartState {
  const CartState();

  bool get isLoading => this is CartStateLoading;
  bool get hasError => this is CartStateError;
  Cart? get cart =>
      switch (this) { CartStateLoaded(:final cart) => cart, _ => null };
  String? get errorMessage =>
      switch (this) { CartStateError(:final message) => message, _ => null };
}

class CartStateInitial extends CartState {
  const CartStateInitial();
}

class CartStateLoading extends CartState {
  const CartStateLoading();
}

class CartStateLoaded extends CartState {
  @override
  final Cart cart;
  const CartStateLoaded(this.cart);
}

class CartStateError extends CartState {
  final String message;
  const CartStateError(this.message);
}
