import 'dart:math';

import '../../features/orders/data/checkout_service.dart';
import 'runtime_models.dart';

class PreviewRuntimeStore {
  PreviewRuntimeStore.seeded()
    : _stock = {
        'coffee-beans': const PreviewStockBalance(
          id: 'coffee-beans',
          name: 'Coffee Beans',
          unit: 'g',
          quantity: 10000,
        ),
        'fresh-milk': const PreviewStockBalance(
          id: 'fresh-milk',
          name: 'Fresh Milk',
          unit: 'ml',
          quantity: 10000,
        ),
        'ice': const PreviewStockBalance(
          id: 'ice',
          name: 'Ice',
          unit: 'g',
          quantity: 10000,
        ),
      };

  final Map<String, PreviewStockBalance> _stock;
  final List<PreviewOrder> orders = [];
  PreviewShift? shift;

  List<PreviewStockBalance> get balances => _stock.values.toList();

  void addMovement(String ingredientId, int quantity, Object type) {
    final current = _stock[ingredientId];
    if (current == null) return;
    final isWaste = type.toString().contains('waste');
    _stock[ingredientId] = PreviewStockBalance(
      id: current.id,
      name: current.name,
      unit: current.unit,
      quantity: current.quantity + (isWaste ? -quantity : quantity),
    );
  }

  Future<CheckoutResult> checkout({
    required List<({String id, String name, int price, int quantity})> items,
    required PaymentMethod method,
    required int receivedAmount,
  }) async {
    final total = items.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    if (receivedAmount < total)
      throw FormatException('Pembayaran kurang ${total - receivedAmount}');
    final id = _id('preview-order');
    final now = DateTime.now();
    final payment = PreviewPayment(
      id: _id('preview-pay'),
      method: method.name,
      amount: total,
      receivedAmount: receivedAmount,
      changeAmount: receivedAmount - total,
      createdAt: now,
    );
    final orderItems = items
        .map(
          (item) => PreviewOrderItem(
            id: _id('preview-item'),
            productId: item.id,
            productName: item.name,
            unitPrice: item.price,
            quantity: item.quantity,
            total: item.price * item.quantity,
          ),
        )
        .toList();

    orders.insert(
      0,
      PreviewOrder(
        id: id,
        total: total,
        status: 'paid',
        createdAt: now,
        shiftId: shift?.id,
        cashierName: shift?.cashierName,
        items: orderItems,
        payment: payment,
      ),
    );
    for (final item in items) {
      final recipe = <String, int>{
        'iced-latte': item.id == 'iced-latte' ? 0 : 0,
        'americano': item.id == 'americano' ? 0 : 0,
      };
      if (recipe.containsKey(item.id)) {
        _consume(
          'coffee-beans',
          item.id == 'iced-latte' || item.id == 'americano'
              ? 18 * item.quantity
              : 0,
        );
        if (item.id == 'iced-latte') {
          _consume('fresh-milk', 180 * item.quantity);
          _consume('ice', 120 * item.quantity);
        } else {
          _consume('ice', 150 * item.quantity);
        }
      }
    }
    if (shift != null && method == PaymentMethod.cash) {
      shift = PreviewShift(
        id: shift!.id,
        cashierName: shift!.cashierName,
        openingCash: shift!.openingCash,
        openedAt: shift!.openedAt,
        expectedCash: shift!.expectedCash + total,
      );
    }
    return CheckoutResult(orderId: id, change: receivedAmount - total);
  }

  Future<PreviewShift> openShift(String name, int openingCash) async {
    if (shift != null)
      throw const FormatException('Masih ada shift yang terbuka');
    shift = PreviewShift(
      id: _id('preview-shift'),
      cashierName: name,
      openingCash: openingCash,
      openedAt: DateTime.now(),
      expectedCash: openingCash,
    );
    return shift!;
  }

  Future<PreviewShift?> activeShift() async => shift;

  Future<PreviewShift> closeShift(int closingCash) async {
    final current = shift;
    if (current == null) throw const FormatException('Belum ada shift aktif');
    shift = PreviewShift(
      id: current.id,
      cashierName: current.cashierName,
      openingCash: current.openingCash,
      openedAt: current.openedAt,
      expectedCash: current.expectedCash,
      closingCash: closingCash,
      variance: closingCash - current.expectedCash,
    );
    final result = shift!;
    shift = null;
    return result;
  }

  void _consume(String id, int quantity) {
    final current = _stock[id];
    if (current == null || quantity == 0) return;
    _stock[id] = PreviewStockBalance(
      id: current.id,
      name: current.name,
      unit: current.unit,
      quantity: current.quantity - quantity,
    );
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(4294967295)}';
}
