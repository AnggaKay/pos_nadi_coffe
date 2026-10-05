import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get name => text()();
  IntColumn get price => integer()();
  TextColumn get icon => text().withDefault(const Constant('☕'))();
  BoolColumn get isAvailable =>
      boolean().named('is_available').withDefault(const Constant(true))();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text().named('shift_id').nullable()();
  IntColumn get total => integer()();
  IntColumn get costTotal =>
      integer().named('cost_total').withDefault(const Constant(0))();
  IntColumn get grossProfit =>
      integer().named('gross_profit').withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('paid'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().named('order_id')();
  TextColumn get productId => text().named('product_id')();
  TextColumn get productName => text().named('product_name')();
  IntColumn get unitPrice => integer().named('unit_price')();
  IntColumn get quantity => integer()();
  IntColumn get total => integer()();
  IntColumn get costTotal =>
      integer().named('cost_total').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().named('order_id')();
  TextColumn get method => text()();
  IntColumn get amount => integer()();
  IntColumn get receivedAmount => integer().named('received_amount')();
  IntColumn get changeAmount => integer().named('change_amount')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StockLedger extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().named('item_id')();
  TextColumn get itemName => text().named('item_name')();
  IntColumn get quantityDelta => integer().named('quantity_delta')();
  IntColumn get unitCost => integer().named('unit_cost').nullable()();
  IntColumn get totalCost => integer().named('total_cost').nullable()();
  TextColumn get reason => text()();
  TextColumn get referenceId => text().named('reference_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Units extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  IntColumn get decimalPlaces =>
      integer().named('decimal_places').withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get unitId => text().named('unit_id')();
  IntColumn get minimumStock =>
      integer().named('minimum_stock').withDefault(const Constant(0))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RecipeVersions extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().named('product_id')();
  IntColumn get version => integer()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RecipeItems extends Table {
  TextColumn get id => text()();
  TextColumn get recipeVersionId => text().named('recipe_version_id')();
  TextColumn get ingredientId => text().named('ingredient_id')();
  IntColumn get quantity => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get cashierName => text().named('cashier_name')();
  IntColumn get openingCash => integer().named('opening_cash')();
  IntColumn get expectedCash =>
      integer().named('expected_cash').withDefault(const Constant(0))();
  IntColumn get closingCash => integer().named('closing_cash').nullable()();
  IntColumn get variance => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get openedAt => dateTime().named('opened_at')();
  DateTimeColumn get closedAt => dateTime().named('closed_at').nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id').nullable()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
