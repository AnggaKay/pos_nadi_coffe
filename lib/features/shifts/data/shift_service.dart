import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/runtime/preview_runtime_store.dart';

class ShiftService {
  ShiftService(this.database, {this.previewStore});

  final AppDatabase? database;
  final PreviewRuntimeStore? previewStore;

  Future<Shift?> activeShift() async {
    if (previewStore != null) {
      final value = await previewStore!.activeShift();
      if (value == null) return null;
      return Shift(
        id: value.id,
        cashierName: value.cashierName,
        openingCash: value.openingCash,
        expectedCash: value.expectedCash,
        status: 'open',
        openedAt: value.openedAt,
      );
    }
    final localDatabase = database!;
    return (localDatabase.select(localDatabase.shifts)
          ..where((row) => row.status.equals('open'))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Shift> open({
    required String cashierName,
    required int openingCash,
  }) async {
    if (openingCash < 0) throw const FormatException('Modal awal tidak valid');
    if (previewStore != null) {
      final value = await previewStore!.openShift(cashierName, openingCash);
      return Shift(
        id: value.id,
        cashierName: value.cashierName,
        openingCash: value.openingCash,
        expectedCash: value.expectedCash,
        status: 'open',
        openedAt: value.openedAt,
      );
    }
    final localDatabase = database!;
    if (await activeShift() != null) {
      throw const FormatException('Masih ada shift yang terbuka');
    }
    final now = DateTime.now();
    final id = _id('shift');
    await localDatabase
        .into(localDatabase.shifts)
        .insert(
          ShiftsCompanion.insert(
            id: id,
            cashierName: cashierName,
            openingCash: openingCash,
            openedAt: now,
          ),
        );
    await _audit('shift_opened', 'shift', id, '$cashierName|$openingCash');
    return (await (localDatabase.select(
      localDatabase.shifts,
    )..where((row) => row.id.equals(id))).getSingle());
  }

  Future<Shift> close({
    required String shiftId,
    required int closingCash,
  }) async {
    if (previewStore != null) {
      final value = await previewStore!.closeShift(closingCash);
      return Shift(
        id: value.id,
        cashierName: value.cashierName,
        openingCash: value.openingCash,
        expectedCash: value.expectedCash,
        closingCash: value.closingCash,
        variance: value.variance,
        status: 'closed',
        openedAt: value.openedAt,
        closedAt: DateTime.now(),
      );
    }
    final localDatabase = database!;
    final shift = await (localDatabase.select(
      localDatabase.shifts,
    )..where((row) => row.id.equals(shiftId))).getSingle();
    if (shift.status != 'open')
      throw const FormatException('Shift sudah ditutup');
    final paymentRows =
        await (localDatabase.select(localDatabase.payments)
              ..where(
                (row) => row.createdAt.isBiggerOrEqualValue(shift.openedAt),
              )
              ..where((row) => row.method.equals('cash')))
            .get();
    final expected =
        shift.openingCash +
        paymentRows.fold<int>(0, (sum, payment) => sum + payment.amount);
    final now = DateTime.now();
    await (localDatabase.update(
      localDatabase.shifts,
    )..where((row) => row.id.equals(shiftId))).write(
      ShiftsCompanion(
        expectedCash: Value(expected),
        closingCash: Value(closingCash),
        variance: Value(closingCash - expected),
        status: const Value('closed'),
        closedAt: Value(now),
      ),
    );
    await _audit(
      'shift_closed',
      'shift',
      shiftId,
      '$closingCash|$expected|${closingCash - expected}',
    );
    return (await (localDatabase.select(
      localDatabase.shifts,
    )..where((row) => row.id.equals(shiftId))).getSingle());
  }

  Future<void> audit(
    String action,
    String entityType,
    String? entityId,
    String? details,
  ) => _audit(action, entityType, entityId, details);

  Future<void> _audit(
    String action,
    String entityType,
    String? entityId,
    String? details,
  ) async {
    final localDatabase = database!;
    await localDatabase
        .into(localDatabase.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            id: _id('audit'),
            action: action,
            entityType: entityType,
            entityId: Value(entityId),
            details: Value(details),
            createdAt: DateTime.now(),
          ),
        );
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(4294967295)}';
}
