import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../shared/models/product.dart' as domain;

class CatalogRepository {
  const CatalogRepository(this.database);

  const CatalogRepository.preview() : database = null;

  final AppDatabase? database;

  Stream<List<({String id, String name})>> watchCategories() {
    if (database == null) {
      return Stream.value(const [
        (id: '', name: 'Semua'),
        (id: 'coffee', name: 'Kopi'),
        (id: 'non-coffee', name: 'Non-Kopi'),
        (id: 'food', name: 'Makanan'),
        (id: 'snack', name: 'Snack'),
      ]);
    }

    return database!.watchCategories().map((items) {
      return [
        (id: '', name: 'Semua'),
        ...items.map((item) => (id: item.id, name: item.name)),
      ];
    });
  }

  Stream<List<domain.Product>> watchProducts({String? categoryId}) {
    if (database == null) {
      return Stream.value(
        _previewProducts
            .where(
              (product) => categoryId == null || product.category == categoryId,
            )
            .toList(),
      );
    }

    return database!.watchProducts(categoryId: categoryId).map((items) {
      return items
          .map(
            (item) => domain.Product(
              id: item.id,
              name: item.name,
              category: item.categoryId,
              price: item.price,
              icon: item.icon,
              isAvailable: item.isAvailable,
            ),
          )
          .toList();
    });
  }
}

const _previewProducts = [
  domain.Product(
    id: 'iced-latte',
    name: 'Iced Latte',
    category: 'coffee',
    price: 22000,
    icon: '☕',
  ),
  domain.Product(
    id: 'americano',
    name: 'Americano',
    category: 'coffee',
    price: 18000,
    icon: '◉',
  ),
  domain.Product(
    id: 'cappuccino',
    name: 'Cappuccino',
    category: 'coffee',
    price: 24000,
    icon: '☕',
  ),
  domain.Product(
    id: 'matcha-latte',
    name: 'Matcha Latte',
    category: 'non-coffee',
    price: 24000,
    icon: '🍵',
  ),
  domain.Product(
    id: 'chocolate',
    name: 'Chocolate',
    category: 'non-coffee',
    price: 22000,
    icon: '◌',
  ),
  domain.Product(
    id: 'lemon-tea',
    name: 'Lemon Tea',
    category: 'non-coffee',
    price: 16000,
    icon: '🍋',
  ),
  domain.Product(
    id: 'croissant',
    name: 'Butter Croissant',
    category: 'food',
    price: 19000,
    icon: '🥐',
  ),
  domain.Product(
    id: 'banana-bread',
    name: 'Banana Bread',
    category: 'food',
    price: 18000,
    icon: '🍞',
  ),
  domain.Product(
    id: 'french-fries',
    name: 'French Fries',
    category: 'snack',
    price: 20000,
    icon: '🍟',
  ),
];

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  // Browser preview does not open the native SQLite connection.
  if (kIsWeb) return const CatalogRepository.preview();
  return CatalogRepository(ref.watch(databaseProvider));
});
