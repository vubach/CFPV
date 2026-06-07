import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../model/category_model.dart';
import '../model/product_model.dart';
import '../repository/menu_repository.dart';
import '../state/menu_state.dart';

/// Manages menu state: categories, products, and product detail.
class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRepository _repository;

  MenuNotifier(this._repository) : super(const MenuStateInitial());

  /// Fetch all categories and products.
  Future<void> fetchMenu() async {
    state = const MenuStateLoading();
    try {
      final categories = await _repository.fetchCategories();
      final products = await _repository.fetchProducts();
      state = MenuStateLoaded(
        categories: categories,
        products: products,
      );
    } catch (e) {
      state = MenuStateError(e.toString());
    }
  }

  /// Fetch a single product by ID (for the detail page).
  Future<Product?> fetchProductById(String id) async {
    try {
      return await _repository.fetchProductById(id);
    } catch (_) {
      return null;
    }
  }
}

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final dio = DioClient.instance;
  final repository = MenuRepository(dioClient: dio);
  return MenuNotifier(repository);
});

final _menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final dio = DioClient.instance;
  return MenuRepository(dioClient: dio);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(_menuRepositoryProvider);
  return repo.fetchCategories();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(_menuRepositoryProvider);
  return repo.fetchFeaturedProducts();
});
