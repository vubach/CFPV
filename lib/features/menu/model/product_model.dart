/// Nutritional information for a product.
class NutritionInfo {
  final int? calories;
  final double? sugarGrams;
  final double? fatGrams;
  final double? proteinGrams;
  final double? caffeineMg;
  final List<String>? ingredients;

  const NutritionInfo({
    this.calories,
    this.sugarGrams,
    this.fatGrams,
    this.proteinGrams,
    this.caffeineMg,
    this.ingredients,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
        calories: json['calories'] as int?,
        sugarGrams: (json['sugarGrams'] as num?)?.toDouble(),
        fatGrams: (json['fatGrams'] as num?)?.toDouble(),
        proteinGrams: (json['proteinGrams'] as num?)?.toDouble(),
        caffeineMg: (json['caffeineMg'] as num?)?.toDouble(),
        ingredients: (json['ingredients'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );
}

/// Represents a menu product with details and pricing.
class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String categoryId;
  final String? categoryName;
  final bool isAvailable;
  final List<String>? tags;
  final NutritionInfo? nutrition;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    this.isAvailable = true,
    this.tags,
    this.nutrition,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isAvailable': isAvailable,
        'tags': tags,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String?,
        isAvailable: json['isAvailable'] as bool? ?? true,
        tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        nutrition: json['nutrition'] != null
            ? NutritionInfo.fromJson(
                json['nutrition'] as Map<String, dynamic>,)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
