import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pos/presentation/providers/cart_provider.dart';
import '../../../shared/formatters/currency_formatter.dart';

class OrderConfirmationSheet extends ConsumerWidget {
  const OrderConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfirmasi pembayaran',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan pesanan sudah sesuai sebelum customer membayar.',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total pembayaran'),
                Text(
                  formatRupiah(total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Pilih metode pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
