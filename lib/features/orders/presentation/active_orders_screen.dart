import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/runtime/runtime_provider.dart';
import '../../../shared/formatters/currency_formatter.dart';
import '../../../shared/widgets/app_shell.dart';

/// Model terpadu untuk menampilkan transaksi beserta detail item dan pembayarannya
class DetailedOrderItem {
  const DetailedOrderItem({
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

class DetailedPayment {
  const DetailedPayment({
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

class DetailedOrder {
  const DetailedOrder({
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
  final List<DetailedOrderItem> items;
  final DetailedPayment? payment;

  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  String get shortId {
    if (id.length <= 10) return '#$id';
    final parts = id.split('-');
    if (parts.length > 1) {
      return '#${parts.last.substring(0, parts.last.length.clamp(0, 6)).toUpperCase()}';
    }
    return '#${id.substring(id.length - 6).toUpperCase()}';
  }
}

/// Provider yang menyediakan daftar transaksi lengkap
final recentDetailedOrdersProvider = StreamProvider<List<DetailedOrder>>((ref) {
  if (kIsWeb) {
    final store = ref.watch(previewRuntimeStoreProvider);
    final mapped = store.orders.map((po) {
      return DetailedOrder(
        id: po.id,
        total: po.total,
        status: po.status,
        createdAt: po.createdAt,
        shiftId: po.shiftId,
        cashierName: po.cashierName,
        items: po.items
            .map(
              (item) => DetailedOrderItem(
                id: item.id,
                productId: item.productId,
                productName: item.productName,
                unitPrice: item.unitPrice,
                quantity: item.quantity,
                total: item.total,
              ),
            )
            .toList(),
        payment: po.payment != null
            ? DetailedPayment(
                id: po.payment!.id,
                method: po.payment!.method,
                amount: po.payment!.amount,
                receivedAmount: po.payment!.receivedAmount,
                changeAmount: po.payment!.changeAmount,
                createdAt: po.payment!.createdAt,
              )
            : null,
      );
    }).toList();
    return Stream.value(mapped);
  }

  final db = ref.watch(databaseProvider);
  return db.watchRecentOrders().asyncMap((orders) async {
    final list = <DetailedOrder>[];
    for (final order in orders) {
      final dbItems = await db.getOrderItems(order.id);
      final dbPayment = await db.getOrderPayment(order.id);
      String? cashier;
      if (order.shiftId != null) {
        final shift = await db.getOrderShift(order.shiftId!);
        cashier = shift?.cashierName;
      }

      list.add(
        DetailedOrder(
          id: order.id,
          total: order.total,
          status: order.status,
          createdAt: order.createdAt,
          shiftId: order.shiftId,
          cashierName: cashier,
          items: dbItems
              .map(
                (item) => DetailedOrderItem(
                  id: item.id,
                  productId: item.productId,
                  productName: item.productName,
                  unitPrice: item.unitPrice,
                  quantity: item.quantity,
                  total: item.total,
                ),
              )
              .toList(),
          payment: dbPayment != null
              ? DetailedPayment(
                  id: dbPayment.id,
                  method: dbPayment.method,
                  amount: dbPayment.amount,
                  receivedAmount: dbPayment.receivedAmount,
                  changeAmount: dbPayment.changeAmount,
                  createdAt: dbPayment.createdAt,
                )
              : null,
        ),
      );
    }
    return list;
  });
});

// Alias untuk kompatibilitas kode lama
final recentOrdersProvider = recentDetailedOrdersProvider;

enum OrderStatusFilter { all, paid }

class ActiveOrdersScreen extends ConsumerStatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  ConsumerState<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends ConsumerState<ActiveOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  OrderStatusFilter _selectedFilter = OrderStatusFilter.all;
  String? _selectedOrderId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 45) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mnt lalu';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute WIB';
    } else {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _monthName(dateTime.month);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day $month, $hour:$minute';
    }
  }

  String _formatFullDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthName(dt.month);
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$day $month $year • $hour:$minute:$second WIB';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showReceiptDialog(DetailedOrder order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.printer,
                    color: AppTheme.primary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Cetak Ulang Struk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Order ${order.shortId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Item',
                          style: TextStyle(color: AppTheme.muted, fontSize: 13),
                        ),
                        Text(
                          '${order.totalItemCount} item',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Metode Bayar',
                          style: TextStyle(color: AppTheme.muted, fontSize: 13),
                        ),
                        Text(
                          order.payment?.method.toUpperCase() ?? 'LUNAS',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                          ),
                        ),
                        Text(
                          formatRupiah(order.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Struk berhasil dikirim ke printer thermal!',
                            ),
                            backgroundColor: Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.printer, size: 18),
                      label: const Text('Cetak'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(recentDetailedOrdersProvider);

    return AppShell(
      title: 'Pesanan & Transaksi',
      child: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Pesanan gagal dimuat: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (allOrders) {
          // Filter data berdasarkan search query dan chip filter
          final filteredOrders = allOrders.where((order) {
            // Filter status
            if (_selectedFilter == OrderStatusFilter.paid &&
                order.status.toLowerCase() != 'paid') {
              return false;
            }

            // Search query
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchesId = order.id.toLowerCase().contains(query);
              final matchesShort = order.shortId.toLowerCase().contains(query);
              final matchesItems = order.items.any(
                (item) => item.productName.toLowerCase().contains(query),
              );
              return matchesId || matchesShort || matchesItems;
            }

            return true;
          }).toList();

          // Auto-select item pertama jika belum ada seleksi atau seleksi hilang
          final currentSelectedOrder = filteredOrders.firstWhere(
            (o) => o.id == _selectedOrderId,
            orElse: () => filteredOrders.isNotEmpty
                ? filteredOrders.first
                : DetailedOrder(
                    id: '',
                    total: 0,
                    status: '',
                    createdAt: DateTime.now(),
                  ),
          );

          final hasSelected =
              currentSelectedOrder.id.isNotEmpty && filteredOrders.isNotEmpty;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // PANEL KIRI: DAFTAR TRANSAKSI
                    // ==========================================
                    SizedBox(
                      width: isWide ? 400 : constraints.maxWidth * 0.48,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE5E9E6)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Header Panel Kiri
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                16,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF0F3F1)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Daftar Transaksi',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F7F5),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${filteredOrders.length} Pesanan',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Search Bar
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val.trim();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Cari ID pesanan, produk...',
                                      hintStyle: const TextStyle(
                                        color: AppTheme.muted,
                                        fontSize: 13,
                                      ),
                                      prefixIcon: const Icon(
                                        Iconsax.search_normal_1,
                                        size: 18,
                                        color: AppTheme.muted,
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _searchQuery = '';
                                                });
                                              },
                                            )
                                          : null,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 14,
                                          ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAF9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5E9E6),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5E9E6),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppTheme.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Filter Chips (Semua & Lunas)
                                  Row(
                                    children: [
                                      _FilterChip(
                                        label: 'Semua',
                                        count: allOrders.length,
                                        isSelected:
                                            _selectedFilter ==
                                            OrderStatusFilter.all,
                                        onTap: () {
                                          setState(() {
                                            _selectedFilter =
                                                OrderStatusFilter.all;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'Lunas',
                                        count: allOrders
                                            .where(
                                              (o) =>
                                                  o.status.toLowerCase() ==
                                                  'paid',
                                            )
                                            .length,
                                        isSelected:
                                            _selectedFilter ==
                                            OrderStatusFilter.paid,
                                        onTap: () {
                                          setState(() {
                                            _selectedFilter =
                                                OrderStatusFilter.paid;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // List Pesanan
                            Expanded(
                              child: filteredOrders.isEmpty
                                  ? const _EmptyOrdersState()
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 12,
                                      ),
                                      itemCount: filteredOrders.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final order = filteredOrders[index];
                                        final isSelected =
                                            order.id == currentSelectedOrder.id;

                                        return _OrderCard(
                                          order: order,
                                          isSelected: isSelected,
                                          relativeTime: _formatRelativeTime(
                                            order.createdAt,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedOrderId = order.id;
                                            });
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // ==========================================
                    // PANEL KANAN: INSPEKSI & DETAIL TRANSAKSI
                    // ==========================================
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE5E9E6)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: hasSelected
                            ? _OrderDetailInspection(
                                order: currentSelectedOrder,
                                fullDateTime: _formatFullDateTime(
                                  currentSelectedOrder.createdAt,
                                ),
                                onCopyId: () => _copyToClipboard(
                                  currentSelectedOrder.id,
                                  'Nomor ID Transaksi',
                                ),
                                onReprint: () =>
                                    _showReceiptDialog(currentSelectedOrder),
                              )
                            : const _NoOrderSelectedPlaceholder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: FILTER CHIP
// ==========================================
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : const Color(0xFFF3F5F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.ink,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFFE2E7E4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppTheme.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: ORDER CARD (PANEL KIRI)
// ==========================================
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isSelected,
    required this.relativeTime,
    required this.onTap,
  });

  final DetailedOrder order;
  final bool isSelected;
  final String relativeTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paymentMethod = order.payment?.method.toLowerCase() ?? 'cash';
    final isCash = paymentMethod == 'cash';
    final isQris = paymentMethod == 'qris';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFECEFEF),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Nomor Pesanan + Status Lunas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.shortId,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppTheme.primary : AppTheme.ink,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Iconsax.tick_circle,
                        size: 12,
                        color: Color(0xFF059669),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Lunas',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Total Belanja & Item Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalItemCount} item',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatRupiah(order.total),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Waktu Relatif & Tag Metode Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.clock, size: 13, color: AppTheme.muted),
                    const SizedBox(width: 4),
                    Text(
                      relativeTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F4),
                    borderRadius: BorderRadius.circular(6),
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
                        size: 12,
                        color: AppTheme.ink,
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
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
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

// ==========================================
// SUB WIDGET: DETAIL INSPECTION (PANEL KANAN)
// ==========================================
class _OrderDetailInspection extends StatelessWidget {
  const _OrderDetailInspection({
    required this.order,
    required this.fullDateTime,
    required this.onCopyId,
    required this.onReprint,
  });

  final DetailedOrder order;
  final String fullDateTime;
  final VoidCallback onCopyId;
  final VoidCallback onReprint;

  @override
  Widget build(BuildContext context) {
    final payment = order.payment;
    final isCash = payment?.method.toLowerCase() == 'cash';
    final isQris = payment?.method.toLowerCase() == 'qris';

    return Column(
      children: [
        // Header Inspeksi
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFFAFCFA),
            border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Transaksi ${order.shortId}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onCopyId,
                        icon: const Icon(
                          Iconsax.copy,
                          size: 16,
                          color: AppTheme.muted,
                        ),
                        tooltip: 'Salin ID Lengkap',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Iconsax.tick_circle,
                          size: 15,
                          color: Color(0xFF059669),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Lunas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'ID Transaksi: ${order.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.muted,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 14),
              // Meta info: Waktu & Kasir
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E9E6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.calendar_1,
                          size: 14,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          fullDateTime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E9E6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.user,
                          size: 14,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.cashierName != null &&
                                  order.cashierName!.isNotEmpty
                              ? 'Kasir: ${order.cashierName}'
                              : 'Kasir tidak tercatat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: order.cashierName != null
                                ? AppTheme.ink
                                : AppTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Body: Scrollable Itemized Breakdown & Financials
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title: Item List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RINCIAN ITEM PESANAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${order.totalItemCount} Total Unit',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Table / Card of Items
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: order.items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Rincian per item tidak tersedia.',
                              style: TextStyle(color: AppTheme.muted),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0xFFEAEAEA),
                          ),
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.coffee,
                                        size: 18,
                                        color: AppTheme.primary,
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
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.quantity}x @ ${formatRupiah(item.unitPrice)}',
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
                                    formatRupiah(item.total),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),

                // Section Title: Rekapitulasi Pembayaran
                const Text(
                  'REKAPITULASI PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.muted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E9E6)),
                  ),
                  child: Column(
                    children: [
                      // Subtotal / Total Tagihan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Belanja',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                          Text(
                            formatRupiah(order.total),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFE5E9E6)),

                      // Metode Pembayaran
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCash
                                      ? Iconsax.moneys
                                      : isQris
                                      ? Iconsax.scan_barcode
                                      : Iconsax.card,
                                  size: 14,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCash
                                      ? 'Tunai (Cash)'
                                      : isQris
                                      ? 'QRIS'
                                      : 'Kartu Debit',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (payment != null) ...[
                        const SizedBox(height: 12),
                        if (isCash) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nominal Diterima',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatRupiah(payment.receivedAmount),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Kembalian',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                              Text(
                                formatRupiah(payment.changeAmount),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jumlah Dibayar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatRupiah(payment.amount),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Footer Action Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E9E6))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopyId,
                  icon: const Icon(Iconsax.copy, size: 16),
                  label: const Text('Salin ID Transaksi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onReprint,
                  icon: const Icon(Iconsax.printer, size: 18),
                  label: const Text('Cetak Ulang Struk'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// EMPTY STATES & PLACEHOLDERS
// ==========================================
class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F5F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.receipt_item,
                color: AppTheme.muted,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tidak ada transaksi',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Transaksi yang dibayar akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoOrderSelectedPlaceholder extends StatelessWidget {
  const _NoOrderSelectedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.document_text_1,
              color: AppTheme.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Transaksi untuk Melihat Detail',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Klik salah satu kartu transaksi di samping untuk melihat\nrincian item dan rekapitulasi pembayaran.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
