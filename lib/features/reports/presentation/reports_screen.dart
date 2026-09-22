import 'package:flutter/material.dart';

import '../../../shared/widgets/app_shell.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Laporan',
      child: Center(
        child: Text(
          'Ringkasan penjualan akan tersedia setelah transaksi lokal dibuat.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
