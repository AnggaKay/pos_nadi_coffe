import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preview_runtime_store.dart';

final previewRuntimeStoreProvider = Provider<PreviewRuntimeStore>((ref) {
  return PreviewRuntimeStore.seeded();
});
