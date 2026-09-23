import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatters/currency_input_formatter.dart';
import '../../../shared/widgets/app_shell.dart';
import '../data/inventory_service.dart';
import 'inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedUnitFilter = 'all';
  String? _selectedIngredientId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIngredientIcon(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('coffee') || lower.contains('bean')) {
      return Iconsax.coffee;
    } else if (lower.contains('milk') || lower.contains('susu')) {
      return Iconsax.cup;
    } else if (lower.contains('ice') || lower.contains('es')) {
      return Iconsax.drop;
    }
    return Iconsax.box;
  }

  Color _getIngredientColor(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('coffee') || lower.contains('bean')) {
      return const Color(0xFF8B5CF6);
    } else if (lower.contains('milk') || lower.contains('susu')) {
      return const Color(0xFF0EA5E9);
    } else if (lower.contains('ice') || lower.contains('es')) {
      return const Color(0xFF06B6D4);
    }
    return AppTheme.primary;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _openMovementSheet(
    List<StockBalance> items, {
    StockBalance? preselected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StockMovementSheet(
        items: items,
        initialItem: preselected ?? items.first,
        onSuccess: () {
          ref.invalidate(stockBalancesProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(stockBalancesProvider);

    return AppShell(
      title: 'Stok & Bahan Baku',
      child: balancesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.danger, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat inventaris stok: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(stockBalancesProvider),
                  icon: const Icon(Iconsax.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data stok bahan baku.',
                style: TextStyle(color: AppTheme.muted, fontSize: 14),
              ),
            );
          }

          // Filter by search and unit
          final filtered = items.where((item) {
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchesName = item.name.toLowerCase().contains(query);
              final matchesId = item.id.toLowerCase().contains(query);
              if (!matchesName && !matchesId) return false;
            }
            if (_selectedUnitFilter != 'all') {
              if (item.unit.toLowerCase() !=
                  _selectedUnitFilter.toLowerCase()) {
                return false;
              }
            }
            return true;
          }).toList();

          final selectedItem = items.firstWhere(
            (it) => it.id == _selectedIngredientId,
            orElse: () => filtered.isNotEmpty ? filtered.first : items.first,
          );

          final units = items.map((e) => e.unit).toSet().toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. TOP SUMMARY METRICS & QUICK ACTIONS
                    // ==========================================
                    Row(
                      children: [
                        _SummaryMetricCard(
                          title: 'Total Bahan Aktif',
                          value: '${items.length} Bahan',
                          subtitle: 'Terhubung resep & mutasi',
                          icon: Iconsax.box_1,
                          accentColor: AppTheme.primary,
                        ),
                        const SizedBox(width: 16),
                        _SummaryMetricCard(
                          title: 'Status Inventaris',
                          value: 'Tersedia',
                          subtitle: 'Stok siap untuk pesanan',
                          icon: Iconsax.tick_circle,
                          accentColor: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _openMovementSheet(items),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              height: 98,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primary, Color(0xFF0F281E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Iconsax.add_circle,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Catat Mutasi Stok',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Restock pembelian, waste, atau adjustment',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Iconsax.arrow_right_3,
                                    color: Colors.white,
                                    size: 20,
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
                    // 2. SEARCH BAR & UNIT FILTER CHIPS
                    // ==========================================
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari nama bahan baku atau kode...',
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
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                        ),
                        const SizedBox(width: 14),
                        // Unit Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterPill(
                                label: 'Semua',
                                isSelected: _selectedUnitFilter == 'all',
                                onTap: () =>
                                    setState(() => _selectedUnitFilter = 'all'),
                              ),
                              for (final u in units) ...[
                                const SizedBox(width: 8),
                                _FilterPill(
                                  label: u.toUpperCase(),
                                  isSelected: _selectedUnitFilter == u,
                                  onTap: () =>
                                      setState(() => _selectedUnitFilter = u),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ==========================================
                    // 3. MAIN CONTENT: SPLIT VIEW DASHBOARD
                    // ==========================================
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Panel: Daftar Bahan Baku
                          Expanded(
                            flex: 6,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Color(0xFFE5E9E6),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      18,
                                      20,
                                      14,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Daftar Inventaris Bahan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.ink,
                                          ),
                                        ),
                                        Text(
                                          '${filtered.length} item ditemukan',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.muted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFF0F3F1),
                                  ),
                                  Expanded(
                                    child: filtered.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'Bahan baku tidak ditemukan.',
                                              style: TextStyle(
                                                color: AppTheme.muted,
                                              ),
                                            ),
                                          )
                                        : ListView.separated(
                                            padding: const EdgeInsets.all(16),
                                            itemCount: filtered.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 10),
                                            itemBuilder: (context, index) {
                                              final item = filtered[index];
                                              final isSelected =
                                                  item.id == selectedItem.id;
                                              final icon = _getIngredientIcon(
                                                item.id,
                                              );
                                              final color = _getIngredientColor(
                                                item.id,
                                              );

                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedIngredientId =
                                                        item.id;
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 150,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppTheme.primaryLight
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppTheme.primary
                                                          : const Color(
                                                              0xFFECEFEF,
                                                            ),
                                                      width: isSelected
                                                          ? 1.5
                                                          : 1.0,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                          color: color
                                                              .withValues(
                                                                alpha: 0.12,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          icon,
                                                          color: color,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item.name,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color:
                                                                    isSelected
                                                                    ? AppTheme
                                                                          .primary
                                                                    : AppTheme
                                                                          .ink,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              'Kode: #${item.id}',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: AppTheme
                                                                    .muted,
                                                                fontFamily:
                                                                    'monospace',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            '${_formatNumber(item.quantity)} ${item.unit}',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color:
                                                                  item.quantity <=
                                                                      0
                                                                  ? Colors.red
                                                                  : AppTheme
                                                                        .ink,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  item.quantity <=
                                                                      0
                                                                  ? const Color(
                                                                      0xFFFEF2F2,
                                                                    )
                                                                  : const Color(
                                                                      0xFFECFDF5,
                                                                    ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              item.quantity <= 0
                                                                  ? 'Habis'
                                                                  : 'Tersedia',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    item.quantity <=
                                                                        0
                                                                    ? Colors.red
                                                                    : const Color(
                                                                        0xFF059669,
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 12),
                                                      IconButton(
                                                        onPressed: () =>
                                                            _openMovementSheet(
                                                              items,
                                                              preselected: item,
                                                            ),
                                                        icon: const Icon(
                                                          Iconsax.add_square,
                                                          color:
                                                              AppTheme.primary,
                                                          size: 24,
                                                        ),
                                                        tooltip:
                                                            'Mutasi bahan ini',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (isWide) ...[
                            const SizedBox(width: 20),
                            // Right Panel: Inspeksi Detail Bahan & Panduan
                            Expanded(
                              flex: 4,
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E9E6),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.white,
                                child: _IngredientDetailPanel(
                                  item: selectedItem,
                                  onAddMovement: () => _openMovementSheet(
                                    items,
                                    preselected: selectedItem,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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
// SUB WIDGET: SUMMARY METRIC CARD
// ==========================================
class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 98,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E9E6)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: FILTER PILL
// ==========================================
class _FilterPill extends StatelessWidget {
  const _FilterPill({
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE5E9E6),
          ),
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
// SUB WIDGET: RIGHT PANEL INSPECTION
// ==========================================
class _IngredientDetailPanel extends StatelessWidget {
  const _IngredientDetailPanel({
    required this.item,
    required this.onAddMovement,
  });

  final StockBalance item;
  final VoidCallback onAddMovement;

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detail Bahan Baku',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Text(
                  'Aktif Operasional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Big Stock Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E9E6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${item.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted,
                    fontFamily: 'monospace',
                  ),
                ),
                const Divider(height: 24, color: Color(0xFFE5E9E6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo Tersedia',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.muted,
                      ),
                    ),
                    Text(
                      '${_formatNumber(item.quantity)} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Operational Notes & Information
          const Text(
            'KETENTUAN MUTASI STOK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Iconsax.box_add,
            title: 'Restock / Pembelian',
            desc: 'Menambah stok bahan dan mencatat total biaya belanja bahan.',
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Iconsax.trash,
            title: 'Waste / Terbuang',
            desc: 'Mengurangi stok karena tumpah, basi, atau gagal racik.',
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Iconsax.refresh_2,
            title: 'Adjustment',
            desc: 'Penyesuaian stok manual setelah opname fisik barista.',
          ),

          const SizedBox(height: 16),

          // Catat Mutasi Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onAddMovement,
              icon: const Icon(Iconsax.add_circle, size: 18),
              label: Text('Catat Mutasi "${item.name}"'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F3F1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SUB WIDGET: MODERN BOTTOM SHEET FOR MOVEMENT
// ==========================================
class _StockMovementSheet extends ConsumerStatefulWidget {
  const _StockMovementSheet({
    required this.items,
    required this.initialItem,
    required this.onSuccess,
  });

  final List<StockBalance> items;
  final StockBalance initialItem;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_StockMovementSheet> createState() =>
      _StockMovementSheetState();
}

class _StockMovementSheetState extends ConsumerState<_StockMovementSheet> {
  late StockBalance _selectedItem;
  StockMovementType _type = StockMovementType.restock;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah kuantitas harus lebih dari 0!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? totalCost;
    if (_type == StockMovementType.restock) {
      totalCost = int.tryParse(parseRupiah(_costController.text)) ?? 0;
      if (totalCost <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Total biaya restock wajib diisi dan lebih dari 0!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(inventoryServiceProvider)
          .addMovement(
            ingredientId: _selectedItem.id,
            quantity: qty,
            type: _type,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            totalCost: totalCost,
          );

      if (!mounted) return;
      widget.onSuccess();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mutasi stok "${_selectedItem.name}" berhasil dicatat!',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencatat mutasi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final int estimatedBalance;
    if (_type == StockMovementType.waste) {
      estimatedBalance = _selectedItem.quantity - qty;
    } else {
      estimatedBalance = _selectedItem.quantity + qty;
    }

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
            // Handle Bar
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Catat Mutasi Stok',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pilih bahan baku dan masukkan perubahan jumlah stok.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. Pilih Bahan
            const Text(
              'BAHAN BAKU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E9E6)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<StockBalance>(
                  isExpanded: true,
                  value: _selectedItem,
                  items: widget.items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Row(
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Saldo: ${item.quantity} ${item.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedItem = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Jenis Mutasi
            const Text(
              'JENIS MUTASI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MovementTypeOption(
                  title: 'Restock (+)',
                  icon: Iconsax.box_add,
                  isSelected: _type == StockMovementType.restock,
                  onTap: () =>
                      setState(() => _type = StockMovementType.restock),
                ),
                const SizedBox(width: 10),
                _MovementTypeOption(
                  title: 'Waste (-)',
                  icon: Iconsax.trash,
                  isSelected: _type == StockMovementType.waste,
                  onTap: () => setState(() => _type = StockMovementType.waste),
                ),
                const SizedBox(width: 10),
                _MovementTypeOption(
                  title: 'Adjustment (+)',
                  icon: Iconsax.refresh_2,
                  isSelected: _type == StockMovementType.adjustment,
                  onTap: () =>
                      setState(() => _type = StockMovementType.adjustment),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Input Kuantitas
            Text(
              'JUMLAH KUANTITAS (${_selectedItem.unit.toUpperCase()})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Contoh: 1000',
                suffixText: _selectedItem.unit,
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted,
                ),
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
            const SizedBox(height: 16),

            // 4. Input Biaya (Jika Restock)
            if (_type == StockMovementType.restock) ...[
              const Text(
                'TOTAL BIAYA BELANJA RESTOCK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.muted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
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
              const SizedBox(height: 16),
            ],

            // 5. Catatan / Alasan
            const Text(
              'CATATAN / ALASAN (OPSIONAL)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: _type == StockMovementType.waste
                    ? 'Misal: Susu pecah / basi'
                    : 'Misal: Beli di pasar induk / supplier',
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
            const SizedBox(height: 20),

            // Live Simulation Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E9E6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimasi Saldo Akhir:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                  Text(
                    '${_selectedItem.quantity} ➔ $estimatedBalance ${_selectedItem.unit}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Simpan Mutasi Stok',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementTypeOption extends StatelessWidget {
  const _MovementTypeOption({
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryLight : const Color(0xFFF8FAF9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : const Color(0xFFE5E9E6),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppTheme.primary : AppTheme.muted,
              ),
              const SizedBox(height: 6),
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
