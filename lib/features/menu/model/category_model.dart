/// Represents a product category (e.g., Coffee, Tea, Food).
class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final int? productCount;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.productCount,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'productCount': productCount,
        'isActive': isActive,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        imageUrl: json['imageUrl'] as String?,
        productCount: json['productCount'] as int?,
        isActive: json['isActive'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
