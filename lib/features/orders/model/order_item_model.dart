/// Represents a single item in an order.
class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.notes,
  });

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    String? notes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'notes': notes,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        productImage: json['productImage'] as String?,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'] as int,
        totalPrice: (json['totalPrice'] as num).toDouble(),
        notes: json['notes'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          productName == other.productName &&
          productImage == other.productImage &&
          unitPrice == other.unitPrice &&
          quantity == other.quantity &&
          totalPrice == other.totalPrice &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        id,
        productId,
        productName,
        productImage,
        unitPrice,
        quantity,
        totalPrice,
        notes,
      );
}
