import '../model/order_model.dart';

/// State of order operations.
sealed class OrderState {
  const OrderState();

  bool get isLoading => this is OrderStateLoading;
  bool get hasError => this is OrderStateError;
  List<Order> get orders =>
      switch (this) { OrderStateLoaded(:final orders) => orders, _ => <Order>[] };
  String? get errorMessage =>
      switch (this) { OrderStateError(:final message) => message, _ => null };
}

class OrderStateInitial extends OrderState {
  const OrderStateInitial();
}

class OrderStateLoading extends OrderState {
  const OrderStateLoading();
}

class OrderStateLoaded extends OrderState {
  @override
  final List<Order> orders;
  const OrderStateLoaded(this.orders);
}

class OrderStateError extends OrderState {
  final String message;
  const OrderStateError(this.message);
}
