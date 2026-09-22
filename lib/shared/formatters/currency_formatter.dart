String formatRupiah(int amount) {
  final digits = amount.toString();
  final groups = <String>[];
  var end = digits.length;

  while (end > 3) {
    groups.insert(0, digits.substring(end - 3, end));
    end -= 3;
  }
  groups.insert(0, digits.substring(0, end));

  return 'Rp${groups.join('.')}';
}
