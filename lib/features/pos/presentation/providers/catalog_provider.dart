import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog_repository.dart';

final categoriesProvider = StreamProvider<List<({String id, String name})>>((
  ref,
) {
  return ref.watch(catalogRepositoryProvider).watchCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final productsProvider = StreamProvider((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  return ref
      .watch(catalogRepositoryProvider)
      .watchProducts(categoryId: categoryId);
});
