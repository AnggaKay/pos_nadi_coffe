import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/formatters/currency_formatter.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../inventory/presentation/inventory_provider.dart';
import '../../orders/presentation/active_orders_screen.dart';
import '../../shifts/presentation/shift_provider.dart';

enum ReportPeriod { today, last7Days, thisMonth, allTime }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.last7Days;

  bool _isOrderInPeriod(DateTime date, ReportPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case ReportPeriod.last7Days:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(sevenDaysAgo) &&
            date.isBefore(now.add(const Duration(days: 1)));
      case ReportPeriod.thisMonth:
        return date.year == now.year && date.month == now.month;
      case ReportPeriod.allTime:
        return true;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _periodLabel(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 'Hari Ini';
      case ReportPeriod.last7Days:
        return '7 Hari Terakhir';
      case ReportPeriod.thisMonth:
        return 'Bulan Ini';
      case ReportPeriod.allTime:
        return 'Semua Waktu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(recentDetailedOrdersProvider);
    final shiftAsync = ref.watch(activeShiftProvider);
    final stockAsync = ref.watch(stockBalancesProvider);

    return AppShell(
      title: 'Laporan & Analitik',
      child: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Gagal memuat data laporan: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (allOrders) {
          // 1. Filter orders based on paid status & selected period
          final validOrders = allOrders.where((order) {
            final isPaid = order.status.toLowerCase() == 'paid';
            return isPaid && _isOrderInPeriod(order.createdAt, _selectedPeriod);
          }).toList();

          // 2. Calculate core financial metrics
          final totalSales = validOrders.fold<int>(
            0,
            (sum, order) => sum + order.total,
          );
          final totalTransactions = validOrders.length;
          final totalItemsSold = validOrders.fold<int>(
            0,
            (sum, order) => sum + order.totalItemCount,
          );
          final avgOrderValue = totalTransactions > 0
              ? totalSales ~/ totalTransactions
              : 0;

          // Estimasi Laba Kotor tercatat (berdasarkan margin perkiraan 65% bila belum ada ledger HPP)
          final estimatedGrossProfit = (totalSales * 0.65).round();

          // 3. Payment Method Distribution
          var cashTotal = 0;
          var cashCount = 0;
          var cashReceived = 0;
          var cashChange = 0;

          var qrisTotal = 0;
          var qrisCount = 0;

          var debitTotal = 0;
          var debitCount = 0;

          for (final order in validOrders) {
            final pay = order.payment;
            final method = pay?.method.toLowerCase() ?? 'cash';
            final amt = order.total;

            if (method == 'cash') {
              cashTotal += amt;
              cashCount++;
              if (pay != null) {
                cashReceived += pay.receivedAmount;
                cashChange += pay.changeAmount;
              }
            } else if (method == 'qris') {
              qrisTotal += amt;
              qrisCount++;
            } else {
              debitTotal += amt;
              debitCount++;
            }
          }

          // 4. Product Sales Ranking
          final productStats =
              <String, ({String name, int qty, int revenue})>{};
          for (final order in validOrders) {
            for (final item in order.items) {
              final current = productStats[item.productId];
              if (current == null) {
                productStats[item.productId] = (
                  name: item.productName,
                  qty: item.quantity,
                  revenue: item.total,
                );
              } else {
                productStats[item.productId] = (
                  name: item.productName,
                  qty: current.qty + item.quantity,
                  revenue: current.revenue + item.total,
                );
              }
            }
          }

          final topProducts = productStats.values.toList()
            ..sort((a, b) => b.qty.compareTo(a.qty));

          // 5. Daily trend aggregation (7 days or days in range)
          final dailySalesMap = <String, int>{};
          final now = DateTime.now();
          for (var i = 6; i >= 0; i--) {
            final d = now.subtract(Duration(days: i));
            final key = '${d.day}/${d.month}';
            dailySalesMap[key] = 0;
          }

          for (final order in validOrders) {
            final key = '${order.createdAt.day}/${order.createdAt.month}';
            if (dailySalesMap.containsKey(key)) {
              dailySalesMap[key] = (dailySalesMap[key] ?? 0) + order.total;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER SECTION & PERIOD CONTROLS
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Penjualan & Operasional',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Data transaksi resmi tercatat dari kasir Nadi Coffee (${_periodLabel(_selectedPeriod)}).',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Period Selector Pills
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E9E6)),
                      ),
                      child: Row(
                        children: [
                          _PeriodPill(
                            label: 'Hari Ini',
                            isSelected: _selectedPeriod == ReportPeriod.today,
                            onTap: () => setState(
                              () => _selectedPeriod = ReportPeriod.today,
                            ),
                          ),
                          _PeriodPill(
                            label: '7 Hari',
                            isSelected:
                                _selectedPeriod == ReportPeriod.last7Days,
                            onTap: () => setState(
                              () => _selectedPeriod = ReportPeriod.last7Days,
                            ),
                          ),
                          _PeriodPill(
                            label: 'Bulan Ini',
                            isSelected:
                                _selectedPeriod == ReportPeriod.thisMonth,
                            onTap: () => setState(
                              () => _selectedPeriod = ReportPeriod.thisMonth,
                            ),
                          ),
                          _PeriodPill(
                            label: 'Semua',
                            isSelected: _selectedPeriod == ReportPeriod.allTime,
                            onTap: () => setState(
                              () => _selectedPeriod = ReportPeriod.allTime,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ==========================================
                // 1. TOP 5 FINANCIAL METRIC CARDS
                // ==========================================
                Row(
                  children: [
                    _MetricSummaryCard(
                      title: 'TOTAL PENJUALAN',
                      value: formatRupiah(totalSales),
                      subtitle: '$totalTransactions transaksi lunas',
                      icon: Iconsax.wallet_3,
                      accentColor: AppTheme.primary,
                      isHighlighted: true,
                    ),
                    const SizedBox(width: 14),
                    _MetricSummaryCard(
                      title: 'TRANSAKSI SELESAI',
                      value: _formatNumber(totalTransactions),
                      subtitle: 'Pesanan telah dibayar',
                      icon: Iconsax.receipt_2,
                      accentColor: const Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 14),
                    _MetricSummaryCard(
                      title: 'ITEM TERJUAL',
                      value: '${_formatNumber(totalItemsSold)} cup/pcs',
                      subtitle: 'Total volume pesanan',
                      icon: Iconsax.coffee,
                      accentColor: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 14),
                    _MetricSummaryCard(
                      title: 'RATA-RATA TRANSAKSI',
                      value: formatRupiah(avgOrderValue),
                      subtitle: 'Per pesanan pelanggan',
                      icon: Iconsax.chart_1,
                      accentColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 14),
                    _MetricSummaryCard(
                      title: 'ESTIMASI LABA KOTOR',
                      value: formatRupiah(estimatedGrossProfit),
                      subtitle: '~65% Margin estimasi',
                      icon: Iconsax.trend_up,
                      accentColor: const Color(0xFFD97706),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ==========================================
                // 2. TREN PENJUALAN HARIAN (VISUAL BAR CHART)
                // ==========================================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE5E9E6)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tren Omset Harian',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Grafik pendapatan transaksi yang berstatus lunas.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Iconsax.calendar_tick,
                                    size: 14,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Periode Aktif',
                                    style: TextStyle(
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
                        const SizedBox(height: 24),

                        // Custom Bar Chart Render
                        _SimpleBarChart(
                          dailySales: dailySalesMap,
                          totalSales: totalSales,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ==========================================
                // 3. DUA KOLOM: METODE PEMBAYARAN & PRODUK TERLARIS
                // ==========================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Rincian Metode Pembayaran
                    Expanded(
                      flex: 5,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE5E9E6)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Distribusi Metode Pembayaran',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  Icon(
                                    Iconsax.card_tick,
                                    size: 20,
                                    color: AppTheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Rekapitulasi omset berdasarkan saluran penerimaan kasir.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.muted,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Payment Row: Tunai (Cash)
                              _PaymentBreakdownCard(
                                title: 'Tunai (Cash)',
                                totalAmount: cashTotal,
                                count: cashCount,
                                overallTotal: totalSales,
                                icon: Iconsax.moneys,
                                color: const Color(0xFF10B981),
                                extraNote: cashCount > 0
                                    ? 'Diterima: ${formatRupiah(cashReceived)} • Kembalian: ${formatRupiah(cashChange)}'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              // Payment Row: QRIS
                              _PaymentBreakdownCard(
                                title: 'QRIS Dinamis / Statis',
                                totalAmount: qrisTotal,
                                count: qrisCount,
                                overallTotal: totalSales,
                                icon: Iconsax.scan_barcode,
                                color: const Color(0xFF0EA5E9),
                                extraNote: 'Pembayaran instan e-wallet',
                              ),
                              const SizedBox(height: 12),

                              // Payment Row: Kartu Debit
                              _PaymentBreakdownCard(
                                title: 'Kartu Debit (EDC)',
                                totalAmount: debitTotal,
                                count: debitCount,
                                overallTotal: totalSales,
                                icon: Iconsax.card,
                                color: const Color(0xFF8B5CF6),
                                extraNote: 'Gesek / tap mesin EDC',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Kolom Kanan: Peringkat Produk Terlaris
                    Expanded(
                      flex: 5,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE5E9E6)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Peringkat Menu Terlaris',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Top Produk',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Menu kopi dan minuman dengan volume pesanan tertinggi.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.muted,
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (topProducts.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Text(
                                      'Belum ada data penjualan menu pada periode ini.',
                                      style: TextStyle(color: AppTheme.muted),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: topProducts.length.clamp(0, 5),
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        height: 16,
                                        color: Color(0xFFF0F3F1),
                                      ),
                                  itemBuilder: (context, index) {
                                    final prod = topProducts[index];
                                    final rank = index + 1;

                                    return Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: rank == 1
                                                ? const Color(0xFFFEF3C7)
                                                : rank == 2
                                                ? const Color(0xFFE0E7FF)
                                                : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#$rank',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: rank == 1
                                                    ? const Color(0xFFD97706)
                                                    : rank == 2
                                                    ? const Color(0xFF4338CA)
                                                    : AppTheme.muted,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                prod.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.ink,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Terjual ${prod.qty} cup • Omset ${formatRupiah(prod.revenue)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.muted,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${prod.qty}x',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ==========================================
                // 4. BAGIAN REKONSILIASI SHIFT & KASIR AKTIF
                // ==========================================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE5E9E6)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Iconsax.user_tag,
                                  size: 20,
                                  color: AppTheme.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Rekonsiliasi Shift & Kasir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                            shiftAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (e, stack) => const SizedBox.shrink(),
                              data: (shift) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: shift != null
                                      ? const Color(0xFFECFDF5)
                                      : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  shift != null
                                      ? 'Shift Aktif Berjalan'
                                      : 'Tidak Ada Shift Aktif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: shift != null
                                        ? const Color(0xFF059669)
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pemeriksaan modal kas awal dan perkiraan uang tunai laci kasir.',
                          style: TextStyle(fontSize: 12, color: AppTheme.muted),
                        ),
                        const SizedBox(height: 18),

                        shiftAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Gagal memuat shift: $e'),
                          data: (shift) {
                            if (shift == null) {
                              return Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE5E9E6),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Belum ada kasir yang membuka shift saat ini. Buka shift di menu Pengaturan.',
                                    style: TextStyle(
                                      color: AppTheme.muted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAF9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E9E6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _ShiftDataBox(
                                    label: 'Nama Kasir Bertugas',
                                    value: shift.cashierName,
                                    subtext: 'ID: ${shift.id}',
                                    icon: Iconsax.user,
                                  ),
                                  const SizedBox(width: 20),
                                  _ShiftDataBox(
                                    label: 'Modal Awal Kasir',
                                    value: formatRupiah(shift.openingCash),
                                    subtext: 'Modal saat buka laci',
                                    icon: Iconsax.moneys,
                                  ),
                                  const SizedBox(width: 20),
                                  _ShiftDataBox(
                                    label: 'Tunai Diharapkan',
                                    value: formatRupiah(shift.expectedCash),
                                    subtext: 'Modal + Pemasukan Tunai',
                                    icon: Iconsax.wallet_check,
                                    highlightColor: AppTheme.primary,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ==========================================
                // 5. BAGIAN AKTIVITAS STOK & BAHAN BAKU
                // ==========================================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE5E9E6)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Status Ketersediaan Inventaris',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink,
                              ),
                            ),
                            Icon(
                              Iconsax.box_time,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pantau sisa bahan baku utama pasca transaksi penjualan.',
                          style: TextStyle(fontSize: 12, color: AppTheme.muted),
                        ),
                        const SizedBox(height: 18),

                        stockAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Gagal memuat stok: $e'),
                          data: (stocks) {
                            if (stocks.isEmpty) {
                              return const Center(
                                child: Text('Tidak ada bahan baku terdata.'),
                              );
                            }

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: stocks.map((stk) {
                                return Container(
                                  width: 220,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE5E9E6),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stk.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppTheme.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${_formatNumber(stk.quantity)} ${stk.unit}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: PERIOD PILL
// ==========================================
class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: METRIC SUMMARY CARD
// ==========================================
class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.isHighlighted = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isHighlighted ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted ? AppTheme.primary : const Color(0xFFE5E9E6),
            width: isHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isHighlighted ? AppTheme.primary : AppTheme.muted,
                  ),
                ),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isHighlighted ? AppTheme.primary : AppTheme.ink,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: SIMPLE BAR CHART
// ==========================================
class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({required this.dailySales, required this.totalSales});

  final Map<String, int> dailySales;
  final int totalSales;

  @override
  Widget build(BuildContext context) {
    var maxVal = 0;
    for (final v in dailySales.values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 100000;

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailySales.entries.map((e) {
          final heightFactor = (e.value / maxVal).clamp(0.06, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (e.value > 0)
                    Text(
                      formatRupiah(e.value).replaceAll('Rp ', ''),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    height: 100 * heightFactor,
                    decoration: BoxDecoration(
                      color: e.value > 0
                          ? AppTheme.primary
                          : const Color(0xFFE5E9E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: PAYMENT BREAKDOWN CARD
// ==========================================
class _PaymentBreakdownCard extends StatelessWidget {
  const _PaymentBreakdownCard({
    required this.title,
    required this.totalAmount,
    required this.count,
    required this.overallTotal,
    required this.icon,
    required this.color,
    this.extraNote,
  });

  final String title;
  final int totalAmount;
  final int count;
  final int overallTotal;
  final IconData icon;
  final Color color;
  final String? extraNote;

  @override
  Widget build(BuildContext context) {
    final percentage = overallTotal > 0
        ? ((totalAmount / overallTotal) * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    Text(
                      '$count transaksi ($percentage%)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(totalAmount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
            ],
          ),
          if (extraNote != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE5E9E6)),
              ),
              child: Text(
                extraNote!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: SHIFT DATA BOX
// ==========================================
class _ShiftDataBox extends StatelessWidget {
  const _ShiftDataBox({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    this.highlightColor,
  });

  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E9E6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: highlightColor ?? AppTheme.muted),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: highlightColor ?? AppTheme.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
