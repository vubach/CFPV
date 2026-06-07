import '../model/category_model.dart';
import '../model/product_model.dart';

/// State of menu operations.
sealed class MenuState {
  const MenuState();

  bool get isLoading => this is MenuStateLoading;
  bool get hasError => this is MenuStateError;
  List<Category> get categories =>
      switch (this) { MenuStateLoaded(:final categories) => categories, _ => <Category>[] };
  List<Product> get products =>
      switch (this) { MenuStateLoaded(:final products) => products, _ => <Product>[] };
  String? get errorMessage =>
      switch (this) { MenuStateError(:final message) => message, _ => null };
}

class MenuStateInitial extends MenuState {
  const MenuStateInitial();
}

class MenuStateLoading extends MenuState {
  const MenuStateLoading();
}

class MenuStateLoaded extends MenuState {
  @override
  final List<Category> categories;
  @override
  final List<Product> products;
  const MenuStateLoaded({this.categories = const [], this.products = const []});
}

class MenuStateError extends MenuState {
  final String message;
  const MenuStateError(this.message);
}
