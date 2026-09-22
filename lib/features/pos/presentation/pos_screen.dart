import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/presentation/order_confirmation_sheet.dart';
import '../../../shared/formatters/currency_formatter.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/section_title.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(title: 'Kasir', child: _PosContent());
  }
}

class _PosContent extends ConsumerWidget {
  const _PosContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, Kasir',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: category == selectedCategory,
                        onSelected: (_) =>
                            ref.read(selectedCategoryProvider.notifier).state =
                                category,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 190,
                          mainAxisExtent: 164,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, index) =>
                        _ProductCard(product: products[index]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 330,
            child: _CartPanel(cart: cart, total: total),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: product.isAvailable
          ? () => ref.read(cartProvider.notifier).add(product)
          : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    product.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                formatRupiah(product.price),
                style: const TextStyle(color: Color(0xFF825B3A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel({required this.cart, required this.total});

  final List<CartItem> cart;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'Pesanan baru',
              action: cart.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () => ref.read(cartProvider.notifier).clear(),
                      child: const Text('Kosongkan'),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              '${cart.length} jenis item',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 30),
            Expanded(
              child: cart.isEmpty
                  ? const Center(child: Text('Belum ada pesanan'))
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, index) =>
                          _CartItemRow(item: cart[index]),
                    ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  formatRupiah(total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: cart.isEmpty
                    ? null
                    : () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => const OrderConfirmationSheet(),
                      ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Lanjut ke pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(formatRupiah(item.total)),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              ref.read(cartProvider.notifier).decrease(item.product),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '${item.quantity}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: () => ref.read(cartProvider.notifier).add(item.product),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
