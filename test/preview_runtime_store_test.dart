import 'package:flutter_test/flutter_test.dart';

import 'package:pos_nadi_coffe/core/runtime/preview_runtime_store.dart';
import 'package:pos_nadi_coffe/features/orders/data/checkout_service.dart';

void main() {
  test('preview checkout menyimpan order dan mengurangi stok resep', () async {
    final store = PreviewRuntimeStore.seeded();
    await store.openShift('Kasir Preview', 100000);

    final result = await store.checkout(
      items: [
        (id: 'iced-latte', name: 'Iced Latte', price: 22000, quantity: 1),
      ],
      method: PaymentMethod.cash,
      receivedAmount: 50000,
    );

    expect(result.change, 28000);
    expect(store.orders, hasLength(1));
    expect(store.orders.single.status, 'paid');
    expect(
      store.balances.firstWhere((item) => item.id == 'coffee-beans').quantity,
      9982,
    );
    expect(
      store.balances.firstWhere((item) => item.id == 'fresh-milk').quantity,
      9820,
    );
    expect(store.shift!.expectedCash, 122000);
  });

  test('preview menolak pembayaran kurang tanpa membuat order', () async {
    final store = PreviewRuntimeStore.seeded();
    expect(
      () => store.checkout(
        items: [
          (id: 'americano', name: 'Americano', price: 18000, quantity: 1),
        ],
        method: PaymentMethod.cash,
        receivedAmount: 17000,
      ),
      throwsA(isA<FormatException>()),
    );
    expect(store.orders, isEmpty);
  });
}
