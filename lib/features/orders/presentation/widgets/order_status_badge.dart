import 'package:flutter/material.dart';
import '../../model/order_model.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';

/// Color-coded pill badge showing the current order status.
/// Maps each OrderStatus to a distinct color that signals the stage.
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  Color get _backgroundColor {
    return switch (status) {
      OrderStatus.pending => const Color(0xFFFFF3E0),  // light amber
      OrderStatus.confirmed => CFPVColors.greenLight,   // light green
      OrderStatus.preparing => const Color(0xFFE3F2FD), // light blue
      OrderStatus.ready => const Color(0xFFE0F2F1),     // light teal
      OrderStatus.completed => const Color(0xFFF5F5F5), // light gray
      OrderStatus.cancelled => const Color(0xFFFFEBEE), // light red
    };
  }

  Color get _foregroundColor {
    return switch (status) {
      OrderStatus.pending => const Color(0xFFE65100),
      OrderStatus.confirmed => CFPVColors.starbucksGreen,
      OrderStatus.preparing => const Color(0xFF1565C0),
      OrderStatus.ready => const Color(0xFF00695C),
      OrderStatus.completed => const Color(0xFF616161),
      OrderStatus.cancelled => CFPVColors.red,
    };
  }

  IconData get _icon {
    return switch (status) {
      OrderStatus.pending => Icons.schedule,
      OrderStatus.confirmed => Icons.check_circle_outline,
      OrderStatus.preparing => Icons.coffee_maker,
      OrderStatus.ready => Icons.local_cafe,
      OrderStatus.completed => Icons.check_circle,
      OrderStatus.cancelled => Icons.cancel_outlined,
    };
  }

  String get _label {
    return switch (status) {
      OrderStatus.pending => 'Pending',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.preparing => 'Preparing',
      OrderStatus.ready => 'Ready',
      OrderStatus.completed => 'Completed',
      OrderStatus.cancelled => 'Cancelled',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(CFPVRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _foregroundColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: CFPVTypography.smallBold.copyWith(color: _foregroundColor),
          ),
        ],
      ),
    );
  }
}
