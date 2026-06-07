import 'package:flutter/material.dart';
import '../../model/order_model.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';

/// The order-status steps displayed in sequence.
/// Each entry gets a color + icon based on whether it's completed, active, or upcoming.
enum _TimelineStage {
  pending,
  confirmed,
  preparing,
  ready,
  completed;

  String get label {
    return switch (this) {
      _TimelineStage.pending => 'Order Placed',
      _TimelineStage.confirmed => 'Confirmed',
      _TimelineStage.preparing => 'Preparing',
      _TimelineStage.ready => 'Ready for Pickup',
      _TimelineStage.completed => 'Completed',
    };
  }
}

/// Vertical status timeline showing the order's progress through stages.
/// Completed steps are green, the current step is accented, awaiting steps are gray.
class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.createdAt,
    this.updatedAt,
  });

  /// All timeline stages are always visible; completed/active/upcoming state varies by status.
  List<_TimelineStage> get _visibleStages => _TimelineStage.values.toList();

  /// The furthest-completed timeline index.
  /// For cancelled orders, at minimum the "Order Placed" step is completed.
  int get _completedIndex {
    return switch (currentStatus) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 1,
      OrderStatus.preparing => 2,
      OrderStatus.ready => 3,
      OrderStatus.completed => 4,
      OrderStatus.cancelled => 1, // Order Placed was completed before cancellation
    };
  }

  bool _isCompleted(int index) => index < _completedIndex;
  bool _isActive(int index) => index == _completedIndex;
  bool _isUpcoming(int index) => index > _completedIndex;

  @override
  Widget build(BuildContext context) {
    final stages = _visibleStages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: CFPVTypography.smallBold.copyWith(
            color: CFPVColors.textBlackSoft,
          ),
        ),
        const SizedBox(height: CFPVSpacing.space3),
        ...List.generate(stages.length, (index) {
          final stage = stages[index];
          final isFirst = index == 0;
          final isLast = index == stages.length - 1;
          final completed = _isCompleted(index);
          final active = _isActive(index);
          final upcoming = _isUpcoming(index);
          final isCancelled =
              currentStatus == OrderStatus.cancelled && index >= _completedIndex;

          return _TimelineRow(
            stage: stage,
            index: index,
            isFirst: isFirst,
            isLast: isLast,
            completed: completed,
            active: active,
            upcoming: upcoming,
            isCancelled: isCancelled,
            timestamp: _timestampFor(index),
          );
        }),
      ],
    );
  }

  String? _timestampFor(int index) {
    if (index == 0) return _formatDateTime(createdAt);
    if (index >= _completedIndex && updatedAt != null && currentStatus == OrderStatus.cancelled) {
      return _formatDateTime(updatedAt!);
    }
    // In a real app the backend returns per-step timestamps
    return null;
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$min $amPm';
  }
}

/// A single row in the timeline with an icon, connector line, label, and timestamp.
class _TimelineRow extends StatelessWidget {
  final _TimelineStage stage;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool completed;
  final bool active;
  final bool upcoming;
  final bool isCancelled;
  final String? timestamp;

  const _TimelineRow({
    required this.stage,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.completed,
    required this.active,
    required this.upcoming,
    required this.isCancelled,
    this.timestamp,
  });

  double get _iconSize => 24;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connector column: line + icon
          SizedBox(
            width: _iconSize + 12, // icon + padding
            child: Column(
              children: [
                // Top connector line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _connectorColor,
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),

                // Icon circle
                _buildIcon(),

                // Bottom connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _connectorColor,
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),

          const SizedBox(width: CFPVSpacing.space2),

          // Label + timestamp
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: _iconSize / 2 - 8,
                bottom: isLast ? 0 : CFPVSpacing.space1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.label,
                    style: CFPVTypography.body.copyWith(
                      fontWeight:
                          active || completed ? FontWeight.w600 : FontWeight.w400,
                      color: isCancelled
                          ? CFPVColors.red
                          : completed || active
                              ? CFPVColors.textBlack
                              : CFPVColors.textBlackSoft,
                    ),
                  ),
                  if (timestamp != null)
                    Text(
                      timestamp!,
                      style: CFPVTypography.small.copyWith(
                        color: completed || active
                            ? CFPVColors.textBlackSoft
                            : CFPVColors.textBlackSoft.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _connectorColor {
    if (isCancelled) return CFPVColors.red.withOpacity(0.4);
    if (completed) return CFPVColors.starbucksGreen;
    if (active) return CFPVColors.greenAccent;
    return CFPVColors.hairline;
  }

  Widget _buildIcon() {
    if (isCancelled && !completed) {
      return Container(
        width: _iconSize,
        height: _iconSize,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.cancel,
          size: 14,
          color: CFPVColors.red,
        ),
      );
    }

    if (completed) {
      return Container(
        width: _iconSize,
        height: _iconSize,
        decoration: const BoxDecoration(
          color: CFPVColors.starbucksGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 14,
          color: CFPVColors.white,
        ),
      );
    }

    if (active) {
      return Container(
        width: _iconSize,
        height: _iconSize,
        decoration: BoxDecoration(
          color: CFPVColors.greenAccent.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: CFPVColors.greenAccent, width: 2),
        ),
        child: const Icon(
          Icons.circle,
          size: 8,
          color: CFPVColors.greenAccent,
        ),
      );
    }

    // Upcoming
    return Container(
      width: _iconSize,
      height: _iconSize,
      decoration: const BoxDecoration(
        color: CFPVColors.neutralCool,
        shape: BoxShape.circle,
      ),
    );
  }
}
