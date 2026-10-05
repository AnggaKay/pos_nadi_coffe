import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/shift_service.dart';
import 'package:flutter/foundation.dart';
import '../../../core/runtime/runtime_provider.dart';

final shiftServiceProvider = Provider<ShiftService>((ref) {
  if (kIsWeb)
    return ShiftService(
      null,
      previewStore: ref.watch(previewRuntimeStoreProvider),
    );
  return ShiftService(ref.watch(databaseProvider));
});

final activeShiftProvider = FutureProvider<Shift?>((ref) {
  return ref.watch(shiftServiceProvider).activeShift();
});
