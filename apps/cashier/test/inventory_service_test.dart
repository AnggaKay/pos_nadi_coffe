import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_nadi_coffe/core/database/app_database.dart';
import 'package:pos_nadi_coffe/features/inventory/data/inventory_service.dart';

void main() {
  late AppDatabase database;
  late InventoryService inventory;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    inventory = InventoryService(database);
  });

  tearDown(() => database.close());

  test('restock dan waste mengubah saldo melalui ledger', () async {
    await inventory.addMovement(
      ingredientId: 'coffee-beans',
      quantity: 500,
      type: StockMovementType.restock,
      totalCost: 60000,
    );
    await inventory.addMovement(
      ingredientId: 'coffee-beans',
      quantity: 100,
      type: StockMovementType.waste,
      note: 'Tumpah',
    );

    final balances = await database.getStockBalances();
    final coffee = balances.firstWhere((item) => item.id == 'coffee-beans');
    expect(coffee.quantity, 10400);
  });

  test('jumlah mutasi tidak boleh nol atau negatif', () {
    expect(
      () => inventory.addMovement(
        ingredientId: 'coffee-beans',
        quantity: 0,
        type: StockMovementType.restock,
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
