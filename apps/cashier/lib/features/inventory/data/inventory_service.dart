import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/runtime/preview_runtime_store.dart';

enum StockMovementType { restock, waste, adjustment }

class InventoryService {
  InventoryService(this.database, {this.previewStore});

  final AppDatabase? database;
  final PreviewRuntimeStore? previewStore;

  Future<void> addMovement({
    required String ingredientId,
    required int quantity,
    required StockMovementType type,
    String? note,
    int? totalCost,
  }) async {
    if (quantity <= 0) throw const FormatException('Jumlah harus lebih dari 0');
    if (previewStore != null) {
      previewStore!.addMovement(ingredientId, quantity, type);
      return;
    }
    if (type == StockMovementType.restock &&
        (totalCost == null || totalCost < 0)) {
      throw const FormatException('Total biaya restock wajib diisi');
    }
    final localDatabase = database!;
    final ingredient = await (localDatabase.select(
      localDatabase.ingredients,
    )..where((row) => row.id.equals(ingredientId))).getSingleOrNull();
    if (ingredient == null)
      throw const FormatException('Bahan tidak ditemukan');
    await localDatabase
        .into(localDatabase.stockLedger)
        .insert(
          StockLedgerCompanion.insert(
            id: 'stock-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(4294967295)}',
            itemId: ingredient.id,
            itemName: ingredient.name,
            quantityDelta: type == StockMovementType.waste
                ? -quantity
                : quantity,
            unitCost: totalCost == null
                ? const Value.absent()
                : Value(totalCost ~/ quantity),
            totalCost: totalCost == null
                ? const Value.absent()
                : Value(totalCost),
            reason: type.name,
            referenceId: Value(note),
            createdAt: DateTime.now(),
          ),
        );
  }
}
