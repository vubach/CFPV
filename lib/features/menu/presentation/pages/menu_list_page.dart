import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../model/category_model.dart';
import '../../model/product_model.dart';
import '../../provider/menu_provider.dart';
import '../../state/menu_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../features/cart/provider/cart_provider.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';

/// Full-screen menu list showing categories and product grid.
class MenuListPage extends ConsumerStatefulWidget {
  const MenuListPage({super.key});

  @override
  ConsumerState<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends ConsumerState<MenuListPage> {
  String? _selectedCategoryId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProvider.notifier).fetchMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuProvider);

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Menu'),
        elevation: 0,
      ),
      body: switch (state) {
        MenuStateInitial() => const SizedBox.shrink(),
        MenuStateLoading() => const Center(
            child: CircularProgressIndicator(color: CFPVColors.greenAccent),
          ),
        MenuStateError(:final message) => _buildError(message),
        MenuStateLoaded(:final categories, :final products) =>
          _buildLoaded(categories, products),
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48,
                color: CFPVColors.red.withOpacity(0.7),),
            const SizedBox(height: CFPVSpacing.space3),
            Text('Could not load menu',
                style: CFPVTypography.body.copyWith(
                    fontWeight: FontWeight.w600, color: CFPVColors.textBlack,),),
            const SizedBox(height: CFPVSpacing.space4),
            ElevatedButton(
              onPressed: () => ref.read(menuProvider.notifier).fetchMenu(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(List<Category> categories, List<Product> products) {
    final filteredProducts = _selectedCategoryId == null
        ? products
        : products.where((p) => p.categoryId == _selectedCategoryId).toList();

    return CustomScrollView(
      slivers: [
        // Categories horizontal scroll
        if (categories.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: CFPVSpacing.space4,
                ),
                itemCount: categories.length + 1, // +1 for "All"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: CFPVSpacing.space2),
                      child: CategoryChip(
                        category: const Category(
                          id: '__all__',
                          name: 'All',
                        ),
                        isSelected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      ),
                    );
                  }
                  final cat = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: CFPVSpacing.space2),
                    child: CategoryChip(
                      category: cat,
                      isSelected: _selectedCategoryId == cat.id,
                      onTap: () =>
                          setState(() => _selectedCategoryId = cat.id),
                    ),
                  );
                },
              ),
            ),
          ),

        // Section gap
        const SliverToBoxAdapter(
          child: SizedBox(height: CFPVSpacing.space3),
        ),

        // Product grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: CFPVSpacing.space3,
              crossAxisSpacing: CFPVSpacing.space3,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = filteredProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push(
                    RoutePaths.productDetail(product.id),
                  ),
                  onAddToCart: () {
                    ref.read(cartProvider.notifier).addItem(
                      productId: product.id,
                      quantity: 1,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
              childCount: filteredProducts.length,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: CFPVSpacing.space9),
        ),
      ],
    );
  }
}
