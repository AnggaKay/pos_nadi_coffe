import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../orders/presentation/order_confirmation_sheet.dart';
import '../../../shared/formatters/currency_formatter.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../app/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(title: 'Menu Kasir', child: _PosContent());
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
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Menu & Categories
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar & Filters
                Row(
                  children: [
                    const Expanded(child: _MenuSearchField()),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E9E6)),
                      ),
                      child: IconButton(
                        icon: const Icon(Iconsax.setting_4, color: AppTheme.ink, size: 20),
                        onPressed: () {},
                        tooltip: 'Filter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Horizontal Categories Pill
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.valueOrNull?.length ?? 0,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories.valueOrNull![index];
                      final isSelected = category.id == (selectedCategory ?? '');
                      return InkWell(
                        onTap: () => ref.read(selectedCategoryProvider.notifier).state =
                            category.id.isEmpty ? null : category.id,
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : const Color(0xFFE5E9E6),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppTheme.ink,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Products Grid
                Expanded(
                  child: products.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Gagal memuat: $error')),
                    data: (items) => GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, index) => _ProductCard(product: items[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right: Cart Panel
          SizedBox(
            width: 360,
            child: _CartPanel(cart: cart, total: total),
          ),
        ],
      ),
    );
  }
}

class _MenuSearchField extends StatelessWidget {
  const _MenuSearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari kopi, pastry, atau makanan...',
          hintStyle: const TextStyle(color: AppTheme.muted, fontSize: 13),
          prefixIcon: const Icon(Iconsax.search_normal, color: AppTheme.muted, size: 18),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E9E6), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E9E6), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  IconData _getProductIcon(String name, String category) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('latte') || lowerName.contains('cappuccino') || lowerName.contains('americano')) {
      return Iconsax.coffee;
    } else if (lowerName.contains('tea') || lowerName.contains('matcha')) {
      return Iconsax.cup;
    } else if (lowerName.contains('croissant') || lowerName.contains('bread')) {
      return Iconsax.cake;
    } else {
      return Iconsax.element_plus;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconData = _getProductIcon(product.name, product.category);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: product.isAvailable
          ? () => ref.read(cartProvider.notifier).add(product)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9E6)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F7F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: 38,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (!product.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'HABIS',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Colors.red,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (product.isAvailable)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE5E9E6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.add,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.ink,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(product.price),
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.bag_2, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Pesanan',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
              if (cart.isNotEmpty)
                InkWell(
                  onTap: () => ref.read(cartProvider.notifier).clear(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Iconsax.trash, size: 14, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E9E6)),
          const SizedBox(height: 12),
          // Items List
          Expanded(
            child: cart.isEmpty
                ? const _EmptyCart()
                : ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Color(0xFFF1F3F2)),
                    ),
                    itemBuilder: (_, index) => _CartItemRow(item: cart[index]),
                  ),
          ),
          const SizedBox(height: 12),
          // Calculation Summary
          if (cart.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E9E6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Barang',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${cart.fold<int>(0, (sum, i) => sum + i.quantity)} pcs',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pajak & Layanan',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        'Rp 0',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.ink),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFE5E9E6)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bayar',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Checkout CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: cart.isEmpty
                  ? null
                  : () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const OrderConfirmationSheet(),
                    ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: const Color(0xFFDCE2DF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Lanjut ke Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  SizedBox(width: 8),
                  Icon(Iconsax.arrow_right_3, size: 18),
                ],
              ),
            ),
          ),
        ],
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                formatRupiah(item.total),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F7),
            border: Border.all(color: const Color(0xFFE5E9E6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => ref.read(cartProvider.notifier).decrease(item.product),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Icon(Iconsax.minus, size: 14, color: AppTheme.ink),
                ),
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              InkWell(
                onTap: () => ref.read(cartProvider.notifier).add(item.product),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Icon(Iconsax.add, size: 14, color: AppTheme.ink),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.bag_2,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Pesanan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih item menu di sebelah kiri\nuntuk mulai menambahkan pesanan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}