import 'package:flutter_test/flutter_test.dart';

import 'package:pos_nadi_coffe/shared/formatters/currency_formatter.dart';

void main() {
  test('format Rupiah uses Indonesian thousands separator', () {
    expect(formatRupiah(0), 'Rp 0');
    expect(formatRupiah(22000), 'Rp 22.000');
    expect(formatRupiah(1250000), 'Rp 1.250.000');
    expect(formatRupiah(-5000), 'Rp -5.000');
  });
}
