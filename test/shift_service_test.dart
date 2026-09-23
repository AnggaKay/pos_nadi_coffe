import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_nadi_coffe/core/database/app_database.dart';
import 'package:pos_nadi_coffe/features/shifts/data/shift_service.dart';

void main() {
  late AppDatabase database;
  late ShiftService shifts;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    shifts = ShiftService(database);
  });

  tearDown(() => database.close());

  test('membuka dan menutup shift menghitung selisih kas', () async {
    final opened = await shifts.open(
      cashierName: 'Kasir 01',
      openingCash: 100000,
    );
    final closed = await shifts.close(shiftId: opened.id, closingCash: 100000);

    expect(closed.status, 'closed');
    expect(closed.expectedCash, 100000);
    expect(closed.variance, 0);
    expect(await database.select(database.auditLogs).get(), hasLength(2));
  });

  test('tidak boleh membuka dua shift sekaligus', () async {
    await shifts.open(cashierName: 'Kasir 01', openingCash: 0);
    expect(
      () => shifts.open(cashierName: 'Kasir 02', openingCash: 0),
      throwsA(isA<FormatException>()),
    );
  });
}
