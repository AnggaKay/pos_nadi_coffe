import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_nadi_coffe/core/database/app_database.dart';
import 'package:pos_nadi_coffe/features/orders/data/checkout_service.dart';
import 'package:pos_nadi_coffe/shared/models/cart_item.dart';
import 'package:pos_nadi_coffe/shared/models/product.dart' as domain;

void main() {
  late AppDatabase database;
  late CheckoutService checkout;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    checkout = CheckoutService(database);
    await database.customSelect('SELECT 1').get();
  });

  tearDown(() async => database.close());

  test('checkout menyimpan order, payment, ledger, dan sync queue', () async {
    const product = domain.Product(
      id: 'iced-latte',
      name: 'Iced Latte',
      category: 'coffee',
      price: 22000,
      icon: 'coffee',
    );

    final result = await checkout.checkout(
      items: [const CartItem(product: product, quantity: 2)],
      method: PaymentMethod.cash,
      receivedAmount: 50000,
    );

    expect(result.change, 6000);
    final orders = await database.select(database.orders).get();
    expect(orders, hasLength(1));
    expect(orders.single.costTotal, 10200);
    expect(orders.single.grossProfit, 33800);
    expect(await database.select(database.orderItems).get(), hasLength(1));
    final payments = await database.select(database.payments).get();
    expect(payments.single.method, 'cash');
    expect(payments.single.changeAmount, 6000);
    final ledger = await database.select(database.stockLedger).get();
    final saleLedger = ledger.where((entry) => entry.reason == 'sale').toList();
    expect(saleLedger, hasLength(3));
    expect(saleLedger.map((entry) => entry.quantityDelta).toSet(), {
      -36,
      -240,
      -360,
    });
    expect(
      (await database.select(database.syncQueue).get()).single.status,
      'pending',
    );
  });

  test('checkout menolak pembayaran kurang tanpa menyimpan data', () async {
    const product = domain.Product(
      id: 'americano',
      name: 'Americano',
      category: 'coffee',
      price: 18000,
      icon: 'coffee',
    );

    expect(
      () => checkout.checkout(
        items: [const CartItem(product: product)],
        method: PaymentMethod.cash,
        receivedAmount: 17000,
      ),
      throwsA(isA<FormatException>()),
    );
    expect(await database.select(database.orders).get(), isEmpty);
    expect(await database.select(database.payments).get(), isEmpty);
    final ledger = await database.select(database.stockLedger).get();
    expect(ledger, hasLength(3));
    expect(ledger.every((entry) => entry.reason == 'opening_stock'), isTrue);
    expect(await database.select(database.syncQueue).get(), isEmpty);
  });
}
