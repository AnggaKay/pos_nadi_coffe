import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/cart_item.dart';
import '../../../../shared/models/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItem(product: product)];
      return;
    }

    final items = [...state];
    final item = items[index];
    items[index] = item.copyWith(quantity: item.quantity + 1);
    state = items;
  }

  void decrease(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) return;

    final item = state[index];
    if (item.quantity == 1) {
      remove(product);
      return;
    }

    final items = [...state];
    items[index] = item.copyWith(quantity: item.quantity - 1);
    state = items;
  }

  void remove(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (total, item) => total + item.total);
});
