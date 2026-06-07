import 'order_item_model.dart';

/// Represents the status of an order.
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled;

  bool get isActive => this == pending || this == confirmed || this == preparing;
  bool get isFinal => this == completed || this == cancelled;
}

/// Represents a customer order with items, status, and totals.
class Order {
  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final double subtotal;
  final double tax;
  final double total;
  final String? storeId;
  final String? storeName;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    this.items = const [],
    this.status = OrderStatus.pending,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
    this.storeId,
    this.storeName,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  int get itemCount => items.length;

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    OrderStatus? status,
    double? subtotal,
    double? tax,
    double? total,
    String? storeId,
    String? storeName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.name,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'storeId': storeId,
        'storeName': storeName,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        items: (json['items'] as List<dynamic>?)
                ?.map(
                    (e) => OrderItem.fromJson(e as Map<String, dynamic>),)
                .toList() ??
            [],
        status: OrderStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => OrderStatus.pending,
        ),
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
        storeId: json['storeId'] as String?,
        storeName: json['storeName'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          total == other.total;

  @override
  int get hashCode => Object.hash(id, status, total);
}
