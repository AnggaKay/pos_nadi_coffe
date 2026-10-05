import 'package:flutter_test/flutter_test.dart';
import 'package:pos_nadi_coffe/shared/formatters/currency_input_formatter.dart';

void main() {
  test('parse Rupiah removes separators', () {
    expect(parseRupiah('20.000'), '20000');
  });

  test('input adds thousands separators', () {
    final formatter = RupiahInputFormatter();
    final result = formatter.formatEditUpdate(
      const TextEditingValue(),
      const TextEditingValue(text: '20000'),
    );
    expect(result.text, '20.000');
  });
}
