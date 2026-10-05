import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/checkout_service.dart';
import '../../../../core/runtime/runtime_provider.dart';

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  if (kIsWeb)
    return CheckoutService.preview(ref.watch(previewRuntimeStoreProvider));
  return CheckoutService(ref.watch(databaseProvider));
});
