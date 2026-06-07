import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

/// A read-only product item row used across order detail and checkout pages.
///
/// Layout: [leading] | [productName + subtitle] | [totalPrice]
///
/// When [leading] is omitted, a default quantity badge (28×28 square with the
/// item count) is rendered. Pass a custom widget (e.g. an image placeholder)
/// via [leading] to override it.
///
/// Spacing between rows is **not** baked in — wrap in a [Padding] or
/// [SizedBox] at the call site as needed.
class ItemRow extends StatelessWidget {
  /// Optional leading widget. Defaults to [quantityBadge] when null and
  /// [quantity] is provided; otherwise no leading widget is shown.
  final Widget? leading;

  final String productName;

  /// Controls text wrapping for [productName]. Defaults to `null` (no limit).
  final int? productNameMaxLines;

  /// Overflow behavior when [productNameMaxLines] is set.
  final TextOverflow? productNameOverflow;

  /// Shown below [productName] (e.g. "\$X.XX each" or "Qty: N × \$X.XX").
  final String subtitle;

  /// The bold right-aligned price string (e.g. "\$12.50").
  final String totalPrice;

  /// Color for [totalPrice]. Defaults to [CFPVColors.textBlack].
  final Color? totalPriceColor;

  /// Item count used when [leading] is null to render a default quantity badge.
  final int? quantity;

  /// Vertical gap between [productName] and [subtitle]. Defaults to `0.0`.
  final double subtitleGap;

  /// Horizontal gap between [leading] and the text column. Defaults to
  /// [CFPVSpacing.space2] (8px).
  final double leadingGap;

  const ItemRow({
    super.key,
    this.leading,
    required this.productName,
    this.productNameMaxLines,
    this.productNameOverflow,
    required this.subtitle,
    required this.totalPrice,
    this.totalPriceColor,
    this.quantity,
    this.subtitleGap = 0.0,
    this.leadingGap = CFPVSpacing.space2,
  });

  // ── Default leading widgets ──────────────────────────────────

  /// A small square badge showing the item [count].
  static Widget quantityBadge(int count) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: CFPVColors.neutralCool,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: CFPVTypography.smallBold.copyWith(
          color: CFPVColors.textBlack,
        ),
      ),
    );
  }

  /// A rounded square image placeholder with a coffee icon.
  static Widget imagePlaceholder({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CFPVColors.neutralCool,
        borderRadius: BorderRadius.circular(CFPVRadius.card - 4),
      ),
      child: Icon(
        Icons.local_cafe_outlined,
        size: size * 0.5,
        color: CFPVColors.textBlackSoft.withOpacity(0.3),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveLeading = leading ??
        (quantity != null ? quantityBadge(quantity!) : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (effectiveLeading != null) ...[
          effectiveLeading,
          SizedBox(width: leadingGap),
        ],

        // Name + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: CFPVTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CFPVColors.textBlack,
                ),
                maxLines: productNameMaxLines,
                overflow: productNameOverflow,
              ),
              if (subtitleGap > 0)
                SizedBox(height: subtitleGap),
              Text(
                subtitle,
                style: CFPVTypography.small.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
            ],
          ),
        ),

        // Total price
        Text(
          totalPrice,
          style: CFPVTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: totalPriceColor ?? CFPVColors.textBlack,
          ),
        ),
      ],
    );
  }
}
