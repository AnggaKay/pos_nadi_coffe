import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/formatters/currency_formatter.dart';
import '../../../shared/formatters/currency_input_formatter.dart';
import '../../inventory/presentation/inventory_provider.dart';
import '../../pos/presentation/providers/cart_provider.dart';
import '../../shifts/presentation/shift_provider.dart';
import '../data/checkout_service.dart';
import 'active_orders_screen.dart';
import 'providers/checkout_provider.dart';

class OrderConfirmationSheet extends ConsumerStatefulWidget {
  const OrderConfirmationSheet({super.key});

  @override
  ConsumerState<OrderConfirmationSheet> createState() =>
      _OrderConfirmationSheetState();
}

class _OrderConfirmationSheetState
    extends ConsumerState<OrderConfirmationSheet> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _cashController = TextEditingController();
  int _receivedAmount = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final total = ref.read(cartTotalProvider);
    _receivedAmount = total;
    _cashController.text = formatRupiah(total).replaceFirst('Rp ', '');
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _onQuickCash(int amount) {
    setState(() {
      _receivedAmount = amount;
      _cashController.text = formatRupiah(amount).replaceFirst('Rp ', '');
    });
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    final total = ref.read(cartTotalProvider);

    if (_selectedMethod == PaymentMethod.cash && _receivedAmount < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal uang tunai kurang dari total pembayaran!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final orderTotal = total;
    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    final paymentMethod = _selectedMethod;
    final receivedCash = _receivedAmount;

    try {
      final result = await ref
          .read(checkoutServiceProvider)
          .checkout(
            items: cart,
            method: _selectedMethod,
            receivedAmount: _selectedMethod == PaymentMethod.cash
                ? _receivedAmount
                : total,
          );

      if (!mounted) return;
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(recentOrdersProvider);
      ref.invalidate(stockBalancesProvider);
      ref.invalidate(activeShiftProvider);

      Navigator.pop(context);

      // Tampilkan Pop-Up Sukses Modern & Rapi
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _PurchaseSuccessDialog(
          orderId: result.orderId,
          total: orderTotal,
          itemCount: totalItems,
          method: paymentMethod,
          receivedAmount: receivedCash,
          change: result.change,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final change = _receivedAmount - total;

    final quickAmounts = [
      total,
      if (total < 50000) 50000,
      if (total < 100000) 100000,
      if (total > 50000 && total < 200000)
        ((total / 50000).ceil() * 50000).toInt(),
    ].toSet().toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        32,
        16,
        32,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9E6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Selesaikan Pembayaran',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pilih metode pembayaran dan masukkan nominal.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9E6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.muted,
                        ),
                      ),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Methods Tabs
            const Text(
              'METODE PEMBAYARAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PaymentMethodCard(
                  title: 'Tunai (Cash)',
                  icon: Iconsax.moneys,
                  isSelected: _selectedMethod == PaymentMethod.cash,
                  onTap: () =>
                      setState(() => _selectedMethod = PaymentMethod.cash),
                ),
                const SizedBox(width: 12),
                _PaymentMethodCard(
                  title: 'QRIS',
                  icon: Iconsax.scan_barcode,
                  isSelected: _selectedMethod == PaymentMethod.qris,
                  onTap: () =>
                      setState(() => _selectedMethod = PaymentMethod.qris),
                ),
                const SizedBox(width: 12),
                _PaymentMethodCard(
                  title: 'Kartu Debit',
                  icon: Iconsax.card,
                  isSelected: _selectedMethod == PaymentMethod.debit,
                  onTap: () =>
                      setState(() => _selectedMethod = PaymentMethod.debit),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Conditional Content based on Payment Method
            if (_selectedMethod == PaymentMethod.cash) ...[
              const Text(
                'NOMINAL DITERIMA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cashController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.ink,
                ),
                onChanged: (val) {
                  setState(() {
                    _receivedAmount = int.tryParse(parseRupiah(val)) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Iconsax.wallet_3,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.ink,
                  ),
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E9E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E9E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Quick Cash Suggestions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amt) {
                  final isExact = amt == total;
                  return InkWell(
                    onTap: () => _onQuickCash(amt),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _receivedAmount == amt
                            ? AppTheme.primaryLight
                            : const Color(0xFFF6F8F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _receivedAmount == amt
                              ? AppTheme.primary
                              : const Color(0xFFE5E9E6),
                        ),
                      ),
                      child: Text(
                        isExact ? 'Uang Pas' : formatRupiah(amt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _receivedAmount == amt
                              ? AppTheme.primary
                              : AppTheme.ink,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Kembalian info container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: change >= 0
                      ? const Color(0xFFF3F9F5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: change >= 0
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      change >= 0 ? 'Kembalian' : 'Kekurangan Pembayaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: change >= 0
                            ? const Color(0xFF047857)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                    Text(
                      formatRupiah(change.abs()),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: change >= 0
                            ? const Color(0xFF047857)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_selectedMethod == PaymentMethod.qris) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E9E6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E9E6)),
                      ),
                      child: const Icon(
                        Iconsax.scan_barcode,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Instruksi QRIS Dinamis/Statis',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Arahkan pelanggan scan barcode QRIS Nadi Coffee pada display meja.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E9E6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E9E6)),
                      ),
                      child: const Icon(
                        Iconsax.card,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pembayaran Mesin EDC',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gesek atau tap kartu debit nasabah pada mesin EDC, lalu konfirmasi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Iconsax.tick_circle, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Konfirmasi & Selesaikan Transaksi',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primary : const Color(0xFFE5E9E6),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primary : AppTheme.muted,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppTheme.primary : AppTheme.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// POP UP / MODAL MODERN TRANSAKSI SUKSES
// ==========================================
class _PurchaseSuccessDialog extends StatelessWidget {
  const _PurchaseSuccessDialog({
    required this.orderId,
    required this.total,
    required this.itemCount,
    required this.method,
    required this.receivedAmount,
    required this.change,
  });

  final String orderId;
  final int total;
  final int itemCount;
  final PaymentMethod method;
  final int receivedAmount;
  final int change;

  String get shortId {
    if (orderId.length <= 10) return '#$orderId';
    final parts = orderId.split('-');
    if (parts.length > 1) {
      return '#${parts.last.substring(0, parts.last.length.clamp(0, 6)).toUpperCase()}';
    }
    return '#${orderId.substring(orderId.length - 6).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final isCash = method == PaymentMethod.cash;
    final isQris = method == PaymentMethod.qris;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(28),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dual-ring Success Badge
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 3),
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: Color(0xFF059669),
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Title & Subtitle
            const Center(
              child: Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Transaksi telah tercatat & siap disajikan.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Short ID Chip with Copy
            Center(
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: orderId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID Transaksi disalin ke clipboard'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shortId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Iconsax.copy, size: 13, color: AppTheme.muted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Rincian Pembayaran Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E9E6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.muted,
                        ),
                      ),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Metode Bayar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.muted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCash
                                  ? Iconsax.moneys
                                  : isQris
                                  ? Iconsax.scan_barcode
                                  : Iconsax.card,
                              size: 13,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCash
                                  ? 'Tunai'
                                  : isQris
                                  ? 'QRIS'
                                  : 'Debit',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isCash) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Uang Diterima',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.muted,
                          ),
                        ),
                        Text(
                          formatRupiah(receivedAmount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E9E6)),
                    // Kembalian Highlight Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian Pelanggan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF047857),
                            ),
                          ),
                          Text(
                            formatRupiah(change),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Cetak Struk & Selesai)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Struk berhasil dikirim ke printer kasir!',
                          ),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.printer, size: 17),
                    label: const Text('Cetak Struk'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppTheme.ink,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
