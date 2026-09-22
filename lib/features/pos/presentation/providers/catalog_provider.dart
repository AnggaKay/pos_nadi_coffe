import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/product.dart';

const _catalog = [
  Product(
    id: 'iced-latte',
    name: 'Iced Latte',
    category: 'Kopi',
    price: 22000,
    icon: '☕',
  ),
  Product(
    id: 'americano',
    name: 'Americano',
    category: 'Kopi',
    price: 18000,
    icon: '◉',
  ),
  Product(
    id: 'cappuccino',
    name: 'Cappuccino',
    category: 'Kopi',
    price: 24000,
    icon: '☕',
  ),
  Product(
    id: 'matcha-latte',
    name: 'Matcha Latte',
    category: 'Non-Kopi',
    price: 24000,
    icon: '🍵',
  ),
  Product(
    id: 'chocolate',
    name: 'Chocolate',
    category: 'Non-Kopi',
    price: 22000,
    icon: '◌',
  ),
  Product(
    id: 'lemon-tea',
    name: 'Lemon Tea',
    category: 'Non-Kopi',
    price: 16000,
    icon: '🍋',
  ),
  Product(
    id: 'croissant',
    name: 'Butter Croissant',
    category: 'Makanan',
    price: 19000,
    icon: '🥐',
  ),
  Product(
    id: 'banana-bread',
    name: 'Banana Bread',
    category: 'Makanan',
    price: 18000,
    icon: '🍞',
  ),
  Product(
    id: 'french-fries',
    name: 'French Fries',
    category: 'Snack',
    price: 20000,
    icon: '🍟',
  ),
];

final categoriesProvider = Provider<List<String>>((ref) {
  return [
    'Semua',
    ...{for (final product in _catalog) product.category},
  ];
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

final productsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'Semua') return _catalog;
  return _catalog.where((product) => product.category == category).toList();
});
