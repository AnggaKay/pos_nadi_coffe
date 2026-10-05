import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../formatters/currency_formatter.dart';
import 'app_dialogs.dart';

class ReceiptItemPreview {
  const ReceiptItemPreview({
    required this.name,
    required this.quantity,
    required this.total,
  });

  final String name;
  final int quantity;
  final int total;
}

class ReceiptPreviewDialog extends StatelessWidget {
  const ReceiptPreviewDialog({
    required this.orderId,
    required this.shortId,
    required this.total,
    required this.methodName,
    this.itemCount,
    this.items = const [],
    this.cashierName,
    this.createdAt,
    this.receivedAmount,
    this.change,
    super.key,
  });

  final String orderId;
  final String shortId;
  final int total;
  final String methodName;
  final int? itemCount;
  final List<ReceiptItemPreview> items;
  final String? cashierName;
  final DateTime? createdAt;
  final int? receivedAmount;
  final int? change;

  static void show(
    BuildContext context, {
    required String orderId,
    required String shortId,
    required int total,
    required String methodName,
    int? itemCount,
    List<ReceiptItemPreview> items = const [],
    String? cashierName,
    DateTime? createdAt,
    int? receivedAmount,
    int? change,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ReceiptPreviewDialog(
        orderId: orderId,
        shortId: shortId,
        total: total,
        methodName: methodName,
        itemCount: itemCount,
        items: items,
        cashierName: cashierName,
        createdAt: createdAt,
        receivedAmount: receivedAmount,
        change: change,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute WIB';
  }

  void _copyReceiptText(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('          NADI COFFEE           ');
    buffer.writeln('     Point of Sale - Pusat      ');
    buffer.writeln('================================');
    buffer.writeln('No. Order : $shortId');
    buffer.writeln('ID Ref    : $orderId');
    if (createdAt != null) {
      buffer.writeln('Waktu     : ${_formatDateTime(createdAt!)}');
    }
    if (cashierName != null && cashierName!.isNotEmpty) {
      buffer.writeln('Kasir     : $cashierName');
    }
    buffer.writeln('--------------------------------');
    for (final item in items) {
      buffer.writeln(
        '${item.name.padRight(18).substring(0, 18)} ${item.quantity}x ${formatRupiah(item.total).padLeft(10)}',
      );
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Total     : ${formatRupiah(total)}');
    buffer.writeln('Metode    : ${methodName.toUpperCase()}');
    if (receivedAmount != null) {
      buffer.writeln('Diterima  : ${formatRupiah(receivedAmount!)}');
      buffer.writeln('Kembalian : ${formatRupiah(change ?? 0)}');
    }
    buffer.writeln('================================');
    buffer.writeln('     Terima Kasih Atas          ');
    buffer.writeln('     Kunjungan Anda!            ');
    buffer.writeln('================================');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppFeedback.showSuccessToast(context, 'Teks struk berhasil disalin');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Dialog
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.receipt_2,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pratinjau Struk Kasir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      Text(
                        'Order $shortId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppTheme.muted,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kertas Struk Thermal Look
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'NADI COFFEE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Point of Sale - Outlet Pusat',
                      style: TextStyle(fontSize: 11, color: AppTheme.muted),
                    ),
                  ),
                  const Divider(height: 20, color: Color(0xFFE5E7EB)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'No. Pesanan',
                        style: TextStyle(fontSize: 11, color: AppTheme.muted),
                      ),
                      Text(
                        shortId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (createdAt != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Waktu',
                          style: TextStyle(fontSize: 11, color: AppTheme.muted),
                        ),
                        Text(
                          _formatDateTime(createdAt!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (cashierName != null && cashierName!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kasir',
                          style: TextStyle(fontSize: 11, color: AppTheme.muted),
                        ),
                        Text(
                          cashierName!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  const Divider(height: 16, color: Color(0xFFE5E7EB)),

                  // Rincian Item (jika ada)
                  if (items.isNotEmpty) ...[
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formatRupiah(item.total),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 16, color: Color(0xFFE5E7EB)),
                  ],

                  // Total Tagihan & Metode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Belanja',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Metode Bayar',
                        style: TextStyle(fontSize: 11, color: AppTheme.muted),
                      ),
                      Text(
                        methodName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                  if (receivedAmount != null && change != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kembalian',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF047857),
                          ),
                        ),
                        Text(
                          formatRupiah(change!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Honest Printer Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: const [
                  Icon(Iconsax.info_circle, size: 15, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Printer thermal belum terhubung pada perangkat ini.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyReceiptText(context),
                    icon: const Icon(Iconsax.copy, size: 16),
                    label: const Text('Salin Struk'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppTheme.ink,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tutup'),
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
