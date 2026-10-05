import 'package:drift/drift.dart';

QueryExecutor openDatabaseConnection() {
  throw UnsupportedError(
    'Native SQLite is unavailable in the browser preview.',
  );
}
