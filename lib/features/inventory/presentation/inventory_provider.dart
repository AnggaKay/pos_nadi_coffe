import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/inventory_service.dart';
import '../../../core/runtime/runtime_provider.dart';

final stockBalancesProvider = FutureProvider<List<StockBalance>>((ref) {
  if (kIsWeb) {
    return Future.value(
      ref
          .watch(previewRuntimeStoreProvider)
          .balances
          .map(
            (item) =>
                StockBalance(item.id, item.name, item.unit, item.quantity),
          )
          .toList(),
    );
  }
  return ref.watch(databaseProvider).getStockBalances();
});

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  if (kIsWeb)
    return InventoryService(
      null,
      previewStore: ref.watch(previewRuntimeStoreProvider),
    );
  return InventoryService(ref.watch(databaseProvider));
});
