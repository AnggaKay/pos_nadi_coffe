import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Products,
    Orders,
    OrderItems,
    Payments,
    StockLedger,
    SyncQueue,
    Units,
    Ingredients,
    RecipeVersions,
    RecipeItems,
    Shifts,
    AuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
    : super(executor ?? openDatabaseConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedCatalog();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(orders);
        await migrator.createTable(orderItems);
        await migrator.createTable(payments);
        await migrator.createTable(stockLedger);
        await migrator.createTable(syncQueue);
      }
      if (from < 3) {
        await migrator.createTable(units);
        await migrator.createTable(ingredients);
        await migrator.createTable(recipeVersions);
        await migrator.createTable(recipeItems);
        await _seedInventory();
      }
      if (from < 4) {
        await migrator.addColumn(orders, orders.costTotal);
        await migrator.addColumn(orders, orders.grossProfit);
        await migrator.addColumn(orderItems, orderItems.costTotal);
        await migrator.addColumn(stockLedger, stockLedger.unitCost);
        await migrator.addColumn(stockLedger, stockLedger.totalCost);
      }
      if (from < 5) {
        await migrator.createTable(shifts);
        await migrator.createTable(auditLogs);
      }
      if (from < 6) {
        await migrator.addColumn(orders, orders.shiftId);
      }
    },
  );

  Future<void> _seedCatalog() async {
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(categories, [
        CategoriesCompanion.insert(
          id: 'coffee',
          name: 'Kopi',
          sortOrder: const Value(1),
        ),
        CategoriesCompanion.insert(
          id: 'non-coffee',
          name: 'Non-Kopi',
          sortOrder: const Value(2),
        ),
        CategoriesCompanion.insert(
          id: 'food',
          name: 'Makanan',
          sortOrder: const Value(3),
        ),
        CategoriesCompanion.insert(
          id: 'snack',
          name: 'Snack',
          sortOrder: const Value(4),
        ),
      ]);
      batch.insertAll(products, [
        ProductsCompanion.insert(
          id: 'iced-latte',
          categoryId: 'coffee',
          name: 'Iced Latte',
          price: 22000,
          icon: const Value('☕'),
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'americano',
          categoryId: 'coffee',
          name: 'Americano',
          price: 18000,
          icon: const Value('◉'),
          sortOrder: const Value(2),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'cappuccino',
          categoryId: 'coffee',
          name: 'Cappuccino',
          price: 24000,
          icon: const Value('☕'),
          sortOrder: const Value(3),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'matcha-latte',
          categoryId: 'non-coffee',
          name: 'Matcha Latte',
          price: 24000,
          icon: const Value('🍵'),
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'chocolate',
          categoryId: 'non-coffee',
          name: 'Chocolate',
          price: 22000,
          icon: const Value('◌'),
          sortOrder: const Value(2),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'lemon-tea',
          categoryId: 'non-coffee',
          name: 'Lemon Tea',
          price: 16000,
          icon: const Value('🍋'),
          sortOrder: const Value(3),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'croissant',
          categoryId: 'food',
          name: 'Butter Croissant',
          price: 19000,
          icon: const Value('🥐'),
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'banana-bread',
          categoryId: 'food',
          name: 'Banana Bread',
          price: 18000,
          icon: const Value('🍞'),
          sortOrder: const Value(2),
          createdAt: now,
          updatedAt: now,
        ),
        ProductsCompanion.insert(
          id: 'french-fries',
          categoryId: 'snack',
          name: 'French Fries',
          price: 20000,
          icon: const Value('🍟'),
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    });
    await _seedInventory();
  }

  Future<void> _seedInventory() async {
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(units, [
        UnitsCompanion.insert(id: 'gram', name: 'Gram', symbol: 'g'),
        UnitsCompanion.insert(
          id: 'milliliter',
          name: 'Milliliter',
          symbol: 'ml',
        ),
        UnitsCompanion.insert(id: 'piece', name: 'Piece', symbol: 'pcs'),
      ]);
      batch.insertAll(ingredients, [
        IngredientsCompanion.insert(
          id: 'coffee-beans',
          name: 'Coffee Beans',
          unitId: 'gram',
        ),
        IngredientsCompanion.insert(
          id: 'fresh-milk',
          name: 'Fresh Milk',
          unitId: 'milliliter',
        ),
        IngredientsCompanion.insert(id: 'ice', name: 'Ice', unitId: 'gram'),
      ]);
      batch.insertAll(recipeVersions, [
        RecipeVersionsCompanion.insert(
          id: 'recipe-iced-latte-v1',
          productId: 'iced-latte',
          version: 1,
          createdAt: now,
        ),
        RecipeVersionsCompanion.insert(
          id: 'recipe-americano-v1',
          productId: 'americano',
          version: 1,
          createdAt: now,
        ),
      ]);
      batch.insertAll(recipeItems, [
        RecipeItemsCompanion.insert(
          id: 'ri-latte-beans',
          recipeVersionId: 'recipe-iced-latte-v1',
          ingredientId: 'coffee-beans',
          quantity: 18,
        ),
        RecipeItemsCompanion.insert(
          id: 'ri-latte-milk',
          recipeVersionId: 'recipe-iced-latte-v1',
          ingredientId: 'fresh-milk',
          quantity: 180,
        ),
        RecipeItemsCompanion.insert(
          id: 'ri-latte-ice',
          recipeVersionId: 'recipe-iced-latte-v1',
          ingredientId: 'ice',
          quantity: 120,
        ),
        RecipeItemsCompanion.insert(
          id: 'ri-americano-beans',
          recipeVersionId: 'recipe-americano-v1',
          ingredientId: 'coffee-beans',
          quantity: 18,
        ),
        RecipeItemsCompanion.insert(
          id: 'ri-americano-ice',
          recipeVersionId: 'recipe-americano-v1',
          ingredientId: 'ice',
          quantity: 150,
        ),
      ]);
      batch.insertAll(stockLedger, [
        StockLedgerCompanion.insert(
          id: 'opening-coffee',
          itemId: 'coffee-beans',
          itemName: 'Coffee Beans',
          quantityDelta: 10000,
          unitCost: const Value(100),
          totalCost: const Value(1000000),
          reason: 'opening_stock',
          createdAt: now,
        ),
        StockLedgerCompanion.insert(
          id: 'opening-milk',
          itemId: 'fresh-milk',
          itemName: 'Fresh Milk',
          quantityDelta: 10000,
          unitCost: const Value(15),
          totalCost: const Value(150000),
          reason: 'opening_stock',
          createdAt: now,
        ),
        StockLedgerCompanion.insert(
          id: 'opening-ice',
          itemId: 'ice',
          itemName: 'Ice',
          quantityDelta: 10000,
          unitCost: const Value(5),
          totalCost: const Value(50000),
          reason: 'opening_stock',
          createdAt: now,
        ),
      ]);
    });
  }

  Future<List<StockBalance>> getStockBalances() async {
    final rows = await customSelect('''
      SELECT i.id, i.name, u.symbol, COALESCE(SUM(s.quantity_delta), 0) AS balance
      FROM ingredients i JOIN units u ON u.id = i.unit_id
      LEFT JOIN stock_ledger s ON s.item_id = i.id
      WHERE i.is_active = 1 GROUP BY i.id, i.name, u.symbol ORDER BY i.name
    ''').get();
    return rows
        .map(
          (row) => StockBalance(
            row.read<String>('id'),
            row.read<String>('name'),
            row.read<String>('symbol'),
            row.read<int>('balance'),
          ),
        )
        .toList();
  }

  Future<int> ingredientUnitCost(String ingredientId) async {
    final rows = await customSelect(
      '''SELECT COALESCE(SUM(total_cost) * 1.0 / NULLIF(SUM(quantity_delta), 0), 0) AS cost
         FROM stock_ledger WHERE item_id = ? AND quantity_delta > 0 AND total_cost IS NOT NULL''',
      variables: [Variable.withString(ingredientId)],
    ).get();
    return rows.single.read<double>('cost').round();
  }

  Future<int> recipeCost(String productId) async {
    final recipe =
        await (select(recipeVersions)
              ..where((row) => row.productId.equals(productId))
              ..where((row) => row.isActive.equals(true))
              ..orderBy([(row) => OrderingTerm.desc(row.version)])
              ..limit(1))
            .getSingleOrNull();
    if (recipe == null) return 0;
    final items = await (select(
      recipeItems,
    )..where((row) => row.recipeVersionId.equals(recipe.id))).get();
    var cost = 0;
    for (final item in items) {
      cost += item.quantity * await ingredientUnitCost(item.ingredientId);
    }
    return cost;
  }

  Stream<List<Order>> watchRecentOrders() {
    return (select(orders)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
          ..limit(50))
        .watch();
  }

  Future<List<OrderItem>> getOrderItems(String orderId) {
    return (select(
      orderItems,
    )..where((row) => row.orderId.equals(orderId))).get();
  }

  Future<Payment?> getOrderPayment(String orderId) {
    return (select(payments)
          ..where((row) => row.orderId.equals(orderId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Shift?> getOrderShift(String shiftId) {
    return (select(shifts)
          ..where((row) => row.id.equals(shiftId))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<Category>> watchCategories() {
    return (select(categories)
          ..where((category) => category.isActive.equals(true))
          ..orderBy([
            (category) => OrderingTerm(expression: category.sortOrder),
          ]))
        .watch();
  }

  Stream<List<Product>> watchProducts({String? categoryId}) {
    final query = select(products)
      ..where((product) => product.isAvailable.equals(true))
      ..orderBy([(product) => OrderingTerm(expression: product.sortOrder)]);

    if (categoryId != null) {
      query.where((product) => product.categoryId.equals(categoryId));
    }

    return query.watch();
  }
}

class StockBalance {
  const StockBalance(this.id, this.name, this.unit, this.quantity);
  final String id;
  final String name;
  final String unit;
  final int quantity;
}
