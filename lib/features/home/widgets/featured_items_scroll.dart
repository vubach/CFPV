import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../menu/model/product_model.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/radius.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/theme/typography.dart';

class FeaturedItemsScroll extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onProductTap;

  const FeaturedItemsScroll({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space3),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: CFPVSpacing.space2),
        itemBuilder: (context, index) {
          final product = products[index];
          return _FeaturedProductCard(
            product: product,
            onTap: () => onProductTap(product),
          );
        },
      ),
    );
  }
}

Widget _imagePlaceholder() {
  return Container(
    height: 110,
    decoration: const BoxDecoration(
      color: CFPVColors.neutralCool,
    ),
    child: Center(
      child: Icon(
        Icons.local_cafe_outlined,
        size: 40,
        color: CFPVColors.textBlackSoft.withOpacity(0.3),
      ),
    ),
  );
}

class _FeaturedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _FeaturedProductCard({
    required this.product,
    required this.onTap,
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
          width: 140,
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(CFPVRadius.card),
                ),
                child: SizedBox(
                  height: 110,
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          width: 140,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
