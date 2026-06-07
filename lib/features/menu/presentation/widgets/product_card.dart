import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../model/product_model.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';

Widget _imagePlaceholder() {
  return Container(
    height: 120,
    decoration: const BoxDecoration(
      color: CFPVColors.neutralCool,
    ),
    child: Center(
      child: Icon(
        Icons.local_cafe_outlined,
        size: 48,
        color: CFPVColors.textBlackSoft.withOpacity(0.3),
      ),
    ),
  );
}

/// Card displaying a product in the menu grid.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image area
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(CFPVRadius.card),
                ),
                child: SizedBox(
                  height: 120,
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imagePlaceholder(),
                          errorWidget: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
              ),

              // Product info
              Padding(
                padding: const EdgeInsets.all(CFPVSpacing.space2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: CFPVTypography.smallBold.copyWith(
                        color: CFPVColors.textBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: CFPVTypography.small.copyWith(
                        color: CFPVColors.starbucksGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Add to cart button
              if (onAddToCart != null && product.isAvailable)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    CFPVSpacing.space2,
                    0,
                    CFPVSpacing.space2,
                    CFPVSpacing.space2,
                  ),
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CFPVColors.greenAccent,
                        foregroundColor: CFPVColors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(CFPVRadius.button),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
