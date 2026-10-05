import 'package:flutter/services.dart';

String parseRupiah(String value) {
  return value.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '');
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = parseRupiah(newValue.text);
    if (digits.isEmpty) return const TextEditingValue();
    final groups = <String>[];
    var end = digits.length;
    while (end > 3) {
      groups.insert(0, digits.substring(end - 3, end));
      end -= 3;
    }
    groups.insert(0, digits.substring(0, end));
    final text = groups.join('.');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
