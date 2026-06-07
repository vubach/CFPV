import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/product_model.dart';
import '../../provider/menu_provider.dart';
import '../../state/menu_state.dart';
import '../../../../features/cart/provider/cart_provider.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';

/// Full-screen product detail page with hero, description, nutrition, and add-to-cart.
class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);

    // Look up product from loaded state
    Product? product;
    if (menuState is MenuStateLoaded) {
      final matches = menuState.products.where((p) => p.id == productId);
      if (matches.isNotEmpty) {
        product = matches.first;
      }
    }

    if (product == null) {
      return _buildNotFound(context, ref);
    }

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      body: CustomScrollView(
        slivers: [
          // App bar with hero image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: CFPVColors.houseGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: CFPVColors.neutralCool,
                child: Center(
                  child: Icon(
                    Icons.local_cafe_outlined,
                    size: 100,
                    color: CFPVColors.textBlackSoft.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: CFPVColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Product info
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Name + price card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(CFPVSpacing.space4),
                  color: CFPVColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: CFPVTypography.h1,
                      ),
                      const SizedBox(height: CFPVSpacing.space1),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: CFPVTypography.h2.copyWith(
                          color: CFPVColors.starbucksGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.categoryName != null) ...[
                        const SizedBox(height: CFPVSpacing.space1),
                        Text(
                          product.categoryName!,
                          style: CFPVTypography.small.copyWith(
                            color: CFPVColors.textBlackSoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: CFPVSpacing.space3),

                // Description card
                if (product.description != null &&
                    product.description!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(CFPVSpacing.space4),
                    color: CFPVColors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: CFPVTypography.smallBold.copyWith(
                            color: CFPVColors.textBlackSoft,
                          ),
                        ),
                        const SizedBox(height: CFPVSpacing.space2),
                        Text(
                          product.description!,
                          style: CFPVTypography.body.copyWith(
                            color: CFPVColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (product.description != null &&
                    product.description!.isNotEmpty)
                  const SizedBox(height: CFPVSpacing.space3),

                // Nutrition card
                if (product.nutrition != null)
                  _NutritionCard(nutrition: product.nutrition!),

                if (product.nutrition != null)
                  const SizedBox(height: CFPVSpacing.space3),

                // Tags
                if (product.tags != null && product.tags!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(CFPVSpacing.space4),
                    color: CFPVColors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: CFPVTypography.smallBold.copyWith(
                            color: CFPVColors.textBlackSoft,
                          ),
                        ),
                        const SizedBox(height: CFPVSpacing.space2),
                        Wrap(
                          spacing: CFPVSpacing.space2,
                          runSpacing: CFPVSpacing.space1,
                          children: product.tags!.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CFPVColors.greenLight.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(
                                  CFPVRadius.circular,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: CFPVTypography.small.copyWith(
                                  color: CFPVColors.starbucksGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // Bottom padding for the add to cart button
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // Add to cart button (floating at bottom)
      bottomNavigationBar: _buildBottomBar(context, product, ref),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        CFPVSpacing.space4,
        CFPVSpacing.space3,
        CFPVSpacing.space4,
        MediaQuery.of(context).padding.bottom + CFPVSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: product.isAvailable
              ? () {
                  ref.read(cartProvider.notifier).addItem(
                    productId: product.id,
                    quantity: 1,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text(
            product.isAvailable
                ? 'Add to Order — \$${product.price.toStringAsFixed(2)}'
                : 'Currently Unavailable',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: product.isAvailable
                ? CFPVColors.greenAccent
                : CFPVColors.textBlackSoft,
            foregroundColor: CFPVColors.white,
            disabledBackgroundColor: CFPVColors.textBlackSoft.withOpacity(0.3),
            disabledForegroundColor: CFPVColors.white.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CFPVRadius.button),
            ),
            textStyle: CFPVTypography.buttonLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64,
                color: CFPVColors.textBlackSoft.withOpacity(0.5),),
            const SizedBox(height: CFPVSpacing.space4),
            Text('Product not found',
                style: CFPVTypography.h2
                    .copyWith(color: CFPVColors.textBlackSoft),),
            const SizedBox(height: CFPVSpacing.space3),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible nutrition information card.
class _NutritionCard extends StatefulWidget {
  final NutritionInfo nutrition;
  const _NutritionCard({required this.nutrition});

  @override
  State<_NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<_NutritionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.nutrition;
    return Container(
      width: double.infinity,
      color: CFPVColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(CFPVSpacing.space4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nutrition & Ingredients',
                      style: CFPVTypography.smallBold.copyWith(
                        color: CFPVColors.textBlackSoft,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: CFPVColors.textBlackSoft,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: CFPVColors.hairline),
            Padding(
              padding: const EdgeInsets.all(CFPVSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n.calories != null)
                    _NutritionRow(label: 'Calories', value: '${n.calories}'),
                  if (n.sugarGrams != null)
                    _NutritionRow(
                        label: 'Sugar', value: '${n.sugarGrams}g',),
                  if (n.fatGrams != null)
                    _NutritionRow(
                        label: 'Fat', value: '${n.fatGrams}g',),
                  if (n.proteinGrams != null)
                    _NutritionRow(
                        label: 'Protein', value: '${n.proteinGrams}g',),
                  if (n.caffeineMg != null)
                    _NutritionRow(
                        label: 'Caffeine', value: '${n.caffeineMg}mg',),
                  if (n.ingredients != null &&
                      n.ingredients!.isNotEmpty) ...[
                    const SizedBox(height: CFPVSpacing.space3),
                    Text(
                      'Ingredients',
                      style: CFPVTypography.smallBold.copyWith(
                        color: CFPVColors.textBlackSoft,
                      ),
                    ),
                    const SizedBox(height: CFPVSpacing.space2),
                    Text(
                      n.ingredients!.join(', '),
                      style: CFPVTypography.small.copyWith(
                        color: CFPVColors.textBlackSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  const _NutritionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: CFPVTypography.body
                  .copyWith(color: CFPVColors.textBlackSoft),),
          Text(value,
              style: CFPVTypography.body
                  .copyWith(fontWeight: FontWeight.w600),),
        ],
      ),
    );
  }
}
