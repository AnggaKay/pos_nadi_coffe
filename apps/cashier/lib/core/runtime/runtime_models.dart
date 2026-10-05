class PreviewOrderItem {
  const PreviewOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  final String id;
  final String productId;
  final String productName;
  final int unitPrice;
  final int quantity;
  final int total;
}

class PreviewPayment {
  const PreviewPayment({
    required this.id,
    required this.method,
    required this.amount,
    required this.receivedAmount,
    required this.changeAmount,
    required this.createdAt,
  });

  final String id;
  final String method;
  final int amount;
  final int receivedAmount;
  final int changeAmount;
  final DateTime createdAt;
}

class PreviewOrder {
  const PreviewOrder({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    this.shiftId,
    this.cashierName,
    this.items = const [],
    this.payment,
  });
  final String id;
  final int total;
  final String status;
  final DateTime createdAt;
  final String? shiftId;
  final String? cashierName;
  final List<PreviewOrderItem> items;
  final PreviewPayment? payment;
}

class PreviewShift {
  const PreviewShift({
    required this.id,
    required this.cashierName,
    required this.openingCash,
    required this.openedAt,
    this.expectedCash = 0,
    this.closingCash,
    this.variance,
  });
  final String id;
  final String cashierName;
  final int openingCash;
  final DateTime openedAt;
  final int expectedCash;
  final int? closingCash;
  final int? variance;
}

class PreviewStockBalance {
  const PreviewStockBalance({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
  });
  final String id;
  final String name;
  final String unit;
  final int quantity;
}
