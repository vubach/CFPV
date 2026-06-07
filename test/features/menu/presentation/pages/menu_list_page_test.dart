import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/menu/model/category_model.dart';
import 'package:cfpv/features/menu/model/product_model.dart';
import 'package:cfpv/features/menu/presentation/pages/menu_list_page.dart';
import 'package:cfpv/features/menu/provider/menu_provider.dart';
import 'package:cfpv/features/menu/repository/menu_repository.dart';

class _MockMenuRepository extends MenuRepository {
  _MockMenuRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  @override
  Future<List<Category>> fetchCategories() async {
    return [
      const Category(id: 'cat-1', name: 'Coffee'),
      const Category(id: 'cat-2', name: 'Tea'),
    ];
  }

  @override
  Future<List<Product>> fetchProducts({String? categoryId}) async {
    return [
      const Product(
        id: 'prod-1',
        name: 'Caffè Latte',
        price: 5.50,
        categoryId: 'cat-1',
        categoryName: 'Coffee',
        description: 'Espresso with steamed milk',
      ),
      const Product(
        id: 'prod-2',
        name: 'English Breakfast',
        price: 3.50,
        categoryId: 'cat-2',
        categoryName: 'Tea',
      ),
    ];
  }
}

Widget _createApp(MenuRepository repo) {
  final container = ProviderContainer(
    overrides: [
      menuProvider.overrideWith((_) => MenuNotifier(repo)),
    ],
  );
  return MaterialApp(
    home: ProviderScope(
      parent: container,
      child: const MenuListPage(),
    ),
  );
}

void main() {
  group('MenuListPage', () {
    testWidgets('shows loading then product grid', (tester) async {
      await tester.pumpWidget(_createApp(_MockMenuRepository()));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Caffè Latte'), findsOneWidget);
      expect(find.text('\$5.50'), findsOneWidget);
      expect(find.text('English Breakfast'), findsOneWidget);
    });

    testWidgets('shows category chips', (tester) async {
      await tester.pumpWidget(_createApp(_MockMenuRepository()));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
    });
  });
}
