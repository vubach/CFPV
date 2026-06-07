import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../model/category_model.dart';
import '../model/product_model.dart';

/// Handles all menu-related API calls.
class MenuRepository {
  final DioClient _dio;

  MenuRepository({required DioClient dioClient}) : _dio = dioClient;

  /// Fetch all active categories.
  Future<List<Category>> fetchCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .where((c) => c.isActive)
          .toList();
    }
    return [];
  }

  /// Fetch products, optionally filtered by category.
  Future<List<Product>> fetchProducts({String? categoryId}) async {
    final queryParameters = <String, dynamic>{};
    if (categoryId != null) {
      queryParameters['categoryId'] = categoryId;
    }
    final response = await _dio.get(
      ApiConstants.products,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch a single product by ID.
  Future<Product> fetchProductById(String id) async {
    final response = await _dio.get(ApiConstants.productById(id));
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch featured/promotional products.
  Future<List<Product>> fetchFeaturedProducts() async {
    final response = await _dio.get(ApiConstants.productsFeatured);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
