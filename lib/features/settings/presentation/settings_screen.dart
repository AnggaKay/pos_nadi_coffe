import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatters/currency_formatter.dart';
import '../../../shared/formatters/currency_input_formatter.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../shifts/presentation/shift_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftAsync = ref.watch(activeShiftProvider);

    return AppShell(
      title: 'Pengaturan & Shift',
      child: shiftAsync.when(
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
                  'Gagal memuat status shift: $error',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(activeShiftProvider),
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
        data: (currentShift) => SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. PAGE HEADER
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pengaturan Operasional Kasir',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola sesi kerja kasir, modal kas awal laci, dan rekonsiliasi kas masuk.',
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
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: currentShift != null
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentShift != null
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentShift != null
                              ? Iconsax.tick_circle
                              : Iconsax.info_circle,
                          size: 16,
                          color: currentShift != null
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentShift != null
                              ? 'Shift Aktif'
                              : 'Shift Belum Dibuka',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: currentShift != null
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 2. MAIN CONTENT (OPEN vs ACTIVE SHIFT)
              // ==========================================
              if (currentShift == null)
                _OpenShiftSection(ref: ref)
              else
                _ActiveShiftSection(ref: ref, shift: currentShift),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SECTION A: KETIKA BELUM ADA SHIFT AKTIF (BUKA SHIFT)
// ==========================================
class _OpenShiftSection extends StatefulWidget {
  const _OpenShiftSection({required this.ref});
  final WidgetRef ref;

  @override
  State<_OpenShiftSection> createState() => _OpenShiftSectionState();
}

class _OpenShiftSectionState extends State<_OpenShiftSection> {
  final TextEditingController _cashierController = TextEditingController(
    text: 'Kasir 01',
  );
  final TextEditingController _openingController = TextEditingController(
    text: '200.000',
  );
  bool _isOpening = false;

  final List<int> _quickOpeningAmounts = [100000, 200000, 300000, 500000];

  @override
  void dispose() {
    _cashierController.dispose();
    _openingController.dispose();
    super.dispose();
  }

  void _onSelectQuickAmount(int amount) {
    setState(() {
      _openingController.text = formatRupiah(amount).replaceFirst('Rp ', '');
    });
  }

  Future<void> _handleOpenShift() async {
    final cashierName = _cashierController.text.trim();
    if (cashierName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kasir wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final openingCash = int.tryParse(parseRupiah(_openingController.text)) ?? 0;
    if (openingCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modal kas awal tidak boleh negatif!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isOpening = true);

    try {
      await widget.ref
          .read(shiftServiceProvider)
          .open(cashierName: cashierName, openingCash: openingCash);
      widget.ref.invalidate(activeShiftProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shift kasir "$cashierName" berhasil dibuka!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isOpening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka shift: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final openingAmount =
        int.tryParse(parseRupiah(_openingController.text)) ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Buka Shift (Kiri)
        Expanded(
          flex: 6,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE5E9E6)),
            ),
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.key,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Formulir Pembukaan Shift',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Masukkan nama kasir dan modal fisik awal di laci kas.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFF0F3F1)),

                  // 1. Nama Kasir
                  const Text(
                    'NAMA KASIR BERTUGAS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cashierController,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Kasir 01',
                      prefixIcon: const Icon(
                        Iconsax.user,
                        color: AppTheme.muted,
                        size: 20,
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
                  const SizedBox(height: 20),

                  // 2. Modal Kas Awal
                  const Text(
                    'MODAL KAS AWAL LACI (OPENING CASH)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _openingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppTheme.ink,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Iconsax.wallet_3,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      prefixText: 'Rp ',
                      prefixStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
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

                  // Quick Chips Nominal Modal
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickOpeningAmounts.map((amt) {
                      final isSelected = openingAmount == amt;
                      return InkWell(
                        onTap: () => _onSelectQuickAmount(amt),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryLight
                                : const Color(0xFFF6F8F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : const Color(0xFFE5E9E6),
                            ),
                          ),
                          child: Text(
                            formatRupiah(amt),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.ink,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isOpening ? null : _handleOpenShift,
                      icon: _isOpening
                          ? const SizedBox.shrink()
                          : const Icon(Iconsax.play, size: 20),
                      label: _isOpening
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Buka Shift Kasir Sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Panel Petunjuk & Prosedur Laci Kas (Kanan)
        Expanded(
          flex: 4,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE5E9E6)),
            ),
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Petunjuk Operasional Shift',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Penting untuk menjaga akurasi pembukuan harian.',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                  SizedBox(height: 20),
                  _ShiftGuidelineStep(
                    stepNumber: '1',
                    title: 'Hitung Uang Fisik Laci',
                    desc:
                        'Pastikan uang pecahan modal awal dihitung secara manual sebelum shift dimulai.',
                  ),
                  SizedBox(height: 16),
                  _ShiftGuidelineStep(
                    stepNumber: '2',
                    title: 'Sinkronisasi Otomatis',
                    desc:
                        'Setelah dibuka, setiap transaksi tunai kasir akan otomatis terakumulasi ke dalam kas.',
                  ),
                  SizedBox(height: 16),
                  _ShiftGuidelineStep(
                    stepNumber: '3',
                    title: 'Penutupan di Akhir Jam',
                    desc:
                        'Tutup shift ketika jam kerja berakhir untuk melihat selisih fisik vs perhitungan sistem.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SECTION B: KETIKA SHIFT AKTIF BERJALAN (TUTUP SHIFT)
// ==========================================
class _ActiveShiftSection extends StatefulWidget {
  const _ActiveShiftSection({required this.ref, required this.shift});

  final WidgetRef ref;
  final Shift shift;

  @override
  State<_ActiveShiftSection> createState() => _ActiveShiftSectionState();
}

class _ActiveShiftSectionState extends State<_ActiveShiftSection> {
  final TextEditingController _closingController = TextEditingController();
  bool _isClosing = false;

  @override
  void dispose() {
    _closingController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
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
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute WIB';
  }

  void _showCloseConfirmationDialog({
    required int actualCash,
    required int variance,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: variance == 0
                        ? const Color(0xFFECFDF5)
                        : variance > 0
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    variance == 0
                        ? Iconsax.tick_circle
                        : variance > 0
                        ? Iconsax.info_circle
                        : Iconsax.danger,
                    color: variance == 0
                        ? const Color(0xFF059669)
                        : variance > 0
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFDC2626),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Konfirmasi Penutupan Shift',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Kasir: ${widget.shift.cashierName}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
              ),
              const SizedBox(height: 20),

              // Rincian Rekonsiliasi Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E9E6)),
                ),
                child: Column(
                  children: [
                    _DialogRow(
                      label: 'Modal Awal Kasir',
                      value: formatRupiah(widget.shift.openingCash),
                    ),
                    const SizedBox(height: 8),
                    _DialogRow(
                      label: 'Penjualan Tunai Masuk',
                      value: formatRupiah(
                        widget.shift.expectedCash - widget.shift.openingCash,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DialogRow(
                      label: 'Total Tunai Diharapkan',
                      value: formatRupiah(widget.shift.expectedCash),
                      isBold: true,
                    ),
                    const Divider(height: 20),
                    _DialogRow(
                      label: 'Kas Fisik Aktual',
                      value: formatRupiah(actualCash),
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _DialogRow(
                      label: 'Selisih Kas Laci',
                      value: variance == 0
                          ? 'Pas (Rp 0)'
                          : variance > 0
                          ? '+ ${formatRupiah(variance)}'
                          : '- ${formatRupiah(variance.abs())}',
                      valueColor: variance == 0
                          ? const Color(0xFF059669)
                          : variance > 0
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFDC2626),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _executeCloseShift(actualCash);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ya, Tutup Shift'),
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

  Future<void> _executeCloseShift(int actualCash) async {
    setState(() => _isClosing = true);

    try {
      final closed = await widget.ref
          .read(shiftServiceProvider)
          .close(shiftId: widget.shift.id, closingCash: actualCash);
      widget.ref.invalidate(activeShiftProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shift berhasil ditutup. Selisih: ${formatRupiah(closed.variance ?? 0)}',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isClosing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menutup shift: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final cashSales = shift.expectedCash - shift.openingCash;
    final enteredCash = int.tryParse(parseRupiah(_closingController.text)) ?? 0;
    final variance = enteredCash - shift.expectedCash;
    final hasEntered = _closingController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // 1. REKONSILIASI KAS METRIC CARDS
        // ==========================================
        Row(
          children: [
            _ShiftMetricCard(
              title: 'MODAL KAS AWAL',
              value: formatRupiah(shift.openingCash),
              subtitle: 'Modal awal laci',
              icon: Iconsax.wallet_add_1,
              accentColor: AppTheme.muted,
            ),
            const SizedBox(width: 16),
            _ShiftMetricCard(
              title: 'PENJUALAN TUNAI',
              value: formatRupiah(cashSales),
              subtitle: 'Akumulasi transaksi cash',
              icon: Iconsax.moneys,
              accentColor: const Color(0xFF0EA5E9),
            ),
            const SizedBox(width: 16),
            _ShiftMetricCard(
              title: 'TOTAL TUNAI DIHARAPKAN',
              value: formatRupiah(shift.expectedCash),
              subtitle: 'Modal + Pemasukan Tunai',
              icon: Iconsax.wallet_check,
              accentColor: AppTheme.primary,
              isHighlighted: true,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ==========================================
        // 2. FORM PENUTUPAN SHIFT & INFO AUDIT
        // ==========================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Form Input Tutup Shift (Kiri)
            Expanded(
              flex: 6,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE5E9E6)),
                ),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Iconsax.lock,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Formulir Penutupan Shift',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Hitung seluruh uang fisik di laci kasir dan masukkan nominalnya.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: Color(0xFFF0F3F1)),

                      // Input Kas Akhir Aktual
                      const Text(
                        'KAS AKHIR AKTUAL FISIK (DI LACI)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.muted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _closingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [RupiahInputFormatter()],
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppTheme.ink,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Iconsax.money_tick,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
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
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E9E6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E9E6),
                            ),
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

                      // Live Calculation Selisih Banner
                      if (hasEntered)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: variance == 0
                                ? const Color(0xFFECFDF5)
                                : variance > 0
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: variance == 0
                                  ? const Color(0xFFA7F3D0)
                                  : variance > 0
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    variance == 0
                                        ? Iconsax.tick_circle
                                        : variance > 0
                                        ? Iconsax.info_circle
                                        : Iconsax.danger,
                                    size: 18,
                                    color: variance == 0
                                        ? const Color(0xFF059669)
                                        : variance > 0
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    variance == 0
                                        ? 'Selisih Kas: Pas / Seimbang'
                                        : variance > 0
                                        ? 'Selisih Kas: Lebih'
                                        : 'Selisih Kas: Kurang',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: variance == 0
                                          ? const Color(0xFF059669)
                                          : variance > 0
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                variance == 0
                                    ? 'Rp 0'
                                    : variance > 0
                                    ? '+ ${formatRupiah(variance)}'
                                    : '- ${formatRupiah(variance.abs())}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: variance == 0
                                      ? const Color(0xFF059669)
                                      : variance > 0
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFDC2626),
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
                        child: FilledButton.icon(
                          onPressed: _isClosing || !hasEntered
                              ? null
                              : () => _showCloseConfirmationDialog(
                                  actualCash: enteredCash,
                                  variance: variance,
                                ),
                          icon: _isClosing
                              ? const SizedBox.shrink()
                              : const Icon(Iconsax.lock, size: 20),
                          label: _isClosing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Tutup & Rekonsiliasi Shift',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Panel Audit & Informasi Sesi Shift (Kanan)
            Expanded(
              flex: 4,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE5E9E6)),
                ),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audit Sesi Shift Berjalan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Data rujukan rekonsiliasi kasir aktif.',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                      const Divider(height: 24, color: Color(0xFFF0F3F1)),

                      _ShiftMetaRow(
                        label: 'Kasir Bertugas',
                        value: shift.cashierName,
                        icon: Iconsax.user,
                      ),
                      const SizedBox(height: 14),
                      _ShiftMetaRow(
                        label: 'Waktu Mulai Shift',
                        value: _formatDateTime(shift.openedAt),
                        icon: Iconsax.calendar_1,
                      ),
                      const SizedBox(height: 14),
                      _ShiftMetaRow(
                        label: 'ID Transaksi Shift',
                        value:
                            '#${shift.id.substring(0, shift.id.length.clamp(0, 16))}',
                        icon: Iconsax.document_code,
                        isMonospace: true,
                        onCopy: () {
                          Clipboard.setData(ClipboardData(text: shift.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ID Shift disalin ke clipboard'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 24, color: Color(0xFFF0F3F1)),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Iconsax.shield_tick,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Setiap penutupan shift dicatat ke audit log lokal demi transparansi kas.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.muted,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// SUB WIDGETS & HELPER COMPONENTS
// ==========================================
class _ShiftMetricCard extends StatelessWidget {
  const _ShiftMetricCard({
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
        height: 110,
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

class _ShiftGuidelineStep extends StatelessWidget {
  const _ShiftGuidelineStep({
    required this.stepNumber,
    required this.title,
    required this.desc,
  });

  final String stepNumber;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
    );
  }
}

class _ShiftMetaRow extends StatelessWidget {
  const _ShiftMetaRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isMonospace = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isMonospace;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Iconsax.copy, size: 14, color: AppTheme.muted),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
      ],
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppTheme.ink : AppTheme.muted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? AppTheme.ink,
          ),
        ),
      ],
    );
  }
}
