import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/models/cart_item.dart';
import '../../../core/runtime/preview_runtime_store.dart';

enum PaymentMethod { cash, qris, debit }

class CheckoutResult {
  const CheckoutResult({required this.orderId, required this.change});

  final String orderId;
  final int change;
}

class CheckoutService {
  CheckoutService(this.database) : previewStore = null;

  CheckoutService.preview(this.previewStore) : database = null;

  final AppDatabase? database;
  final PreviewRuntimeStore? previewStore;

  Future<CheckoutResult> checkout({
    required List<CartItem> items,
    required PaymentMethod method,
    required int receivedAmount,
  }) async {
    if (items.isEmpty) throw const FormatException('Keranjang kosong');
    final total = items.fold<int>(0, (sum, item) => sum + item.total);
    if (receivedAmount < total) {
      throw FormatException('Pembayaran kurang ${total - receivedAmount}');
    }

    // Chrome uses a memory-only catalog preview and has no native SQLite.
    if (previewStore != null) {
      return previewStore!.checkout(
        items: items
            .map(
              (item) => (
                id: item.product.id,
                name: item.product.name,
                price: item.product.price,
                quantity: item.quantity,
              ),
            )
            .toList(),
        method: method,
        receivedAmount: receivedAmount,
      );
    }

    final localDatabase = database!;

    final now = DateTime.now();
    final orderId = _id('ord');
    final paymentId = _id('pay');
    final activeShift =
        await (localDatabase.select(localDatabase.shifts)
              ..where((row) => row.status.equals('open'))
              ..limit(1))
            .getSingleOrNull();
    final itemCosts = <String, int>{};
    for (final item in items) {
      itemCosts[item.product.id] = await localDatabase.recipeCost(
        item.product.id,
      );
    }
    final costTotal = items.fold<int>(
      0,
      (sum, item) => sum + itemCosts[item.product.id]! * item.quantity,
    );

    await localDatabase.transaction(() async {
      await localDatabase
          .into(localDatabase.orders)
          .insert(
            OrdersCompanion.insert(
              id: orderId,
              shiftId: Value(activeShift?.id),
              total: total,
              costTotal: Value(costTotal),
              grossProfit: Value(total - costTotal),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final item in items) {
        await localDatabase
            .into(localDatabase.orderItems)
            .insert(
              OrderItemsCompanion.insert(
                id: _id('item'),
                orderId: orderId,
                productId: item.product.id,
                productName: item.product.name,
                unitPrice: item.product.price,
                quantity: item.quantity,
                total: item.total,
                costTotal: Value(itemCosts[item.product.id]! * item.quantity),
              ),
            );
        final recipe =
            await (localDatabase.select(localDatabase.recipeVersions)
                  ..where((row) => row.productId.equals(item.product.id))
                  ..where((row) => row.isActive.equals(true))
                  ..orderBy([(row) => OrderingTerm.desc(row.version)])
                  ..limit(1))
                .getSingleOrNull();
        if (recipe != null) {
          final recipeItems = await (localDatabase.select(
            localDatabase.recipeItems,
          )..where((row) => row.recipeVersionId.equals(recipe.id))).get();
          for (final recipeItem in recipeItems) {
            final ingredient =
                await (localDatabase.select(localDatabase.ingredients)
                      ..where((row) => row.id.equals(recipeItem.ingredientId)))
                    .getSingle();
            await localDatabase
                .into(localDatabase.stockLedger)
                .insert(
                  StockLedgerCompanion.insert(
                    id: _id('stock'),
                    itemId: ingredient.id,
                    itemName: ingredient.name,
                    quantityDelta: -recipeItem.quantity * item.quantity,
                    reason: 'sale',
                    referenceId: Value(orderId),
                    createdAt: now,
                  ),
                );
          }
        }
      }
      await localDatabase
          .into(localDatabase.payments)
          .insert(
            PaymentsCompanion.insert(
              id: paymentId,
              orderId: orderId,
              method: method.name,
              amount: total,
              receivedAmount: receivedAmount,
              changeAmount: receivedAmount - total,
              createdAt: now,
            ),
          );
      await localDatabase
          .into(localDatabase.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              id: _id('sync'),
              entityType: 'order',
              entityId: orderId,
              createdAt: now,
            ),
          );
    });

    return CheckoutResult(orderId: orderId, change: receivedAmount - total);
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(4294967295)}';
}
