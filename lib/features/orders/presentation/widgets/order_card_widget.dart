import 'package:flutter/material.dart';
import '../../model/order_model.dart';
import 'order_status_badge.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';

/// Card displaying a single order summary in the orders list.
/// Shows store name, order date, item count, total, and status badge.
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  String get _formattedDate {
    final now = DateTime.now();
    final diff = now.difference(order.createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[order.createdAt.month - 1]} ${order.createdAt.day}';
  }

  String get _itemSummary {
    if (order.items.isEmpty) return '${order.itemCount} items';

    final names = order.items.take(2).map((i) => i.productName).toList();
    final summary = names.join(', ');
    if (order.items.length > 2) {
      return '$summary +${order.items.length - 2} more';
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CFPVColors.white,
      borderRadius: BorderRadius.circular(CFPVRadius.card),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 0),
                blurRadius: 0.5,
                color: Colors.black.withOpacity(0.14),
              ),
              BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 1,
                color: Colors.black.withOpacity(0.24),
              ),
            ],
          ),
          padding: const EdgeInsets.all(CFPVSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: store name + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.storeName ?? 'Order',
                          style: CFPVTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CFPVColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_formattedDate · #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                          style: CFPVTypography.small.copyWith(
                            color: CFPVColors.textBlackSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: CFPVSpacing.space2),
                  OrderStatusBadge(status: order.status),
                ],
              ),

              const SizedBox(height: CFPVSpacing.space2),

              // Divider
              const Divider(
                color: CFPVColors.hairline,
                height: 1,
              ),

              const SizedBox(height: CFPVSpacing.space2),

              // Bottom row: items summary + total
              Row(
                children: [
                  // Items summary
                  Expanded(
                    child: Text(
                      _itemSummary,
                      style: CFPVTypography.small.copyWith(
                        color: CFPVColors.textBlackSoft,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: CFPVSpacing.space2),
                  // Total
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: CFPVTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CFPVColors.textBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
