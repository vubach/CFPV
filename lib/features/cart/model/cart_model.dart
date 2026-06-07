import 'cart_item_model.dart';

/// Represents the full shopping cart including items, store info, and totals.
class Cart {
  final String? id;
  final List<CartItem> items;
  final String? storeId;
  final String? storeName;
  final String? notes;
  final double subtotal;
  final double tax;
  final double total;
  final int itemCount;

  const Cart({
    this.id,
    this.items = const [],
    this.storeId,
    this.storeName,
    this.notes,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
    this.itemCount = 0,
  });

  bool get isEmpty => items.isEmpty;

  Cart copyWith({
    String? id,
    List<CartItem>? items,
    String? storeId,
    String? storeName,
    String? notes,
    double? subtotal,
    double? tax,
    double? total,
    int? itemCount,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'storeId': storeId,
        'storeName': storeName,
        'notes': notes,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'itemCount': itemCount,
      };

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id'] as String?,
        items: (json['items'] as List<dynamic>?)
                ?.map(
                    (e) => CartItem.fromJson(e as Map<String, dynamic>),)
                .toList() ??
            [],
        storeId: json['storeId'] as String?,
        storeName: json['storeName'] as String?,
        notes: json['notes'] as String?,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
        itemCount: json['itemCount'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cart &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          items.length == other.items.length &&
          storeId == other.storeId &&
          storeName == other.storeName &&
          notes == other.notes &&
          subtotal == other.subtotal &&
          tax == other.tax &&
          total == other.total &&
          itemCount == other.itemCount;

  @override
  int get hashCode => Object.hash(
        id,
        Object.hashAll(items),
        storeId,
        storeName,
        notes,
        subtotal,
        tax,
        total,
        itemCount,
      );
}
