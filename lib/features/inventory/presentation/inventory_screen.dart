import 'package:flutter/material.dart';

import '../../../shared/widgets/app_shell.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Stok',
      child: Center(
        child: Text(
          'Monitoring bahan dan stock ledger akan dibangun di tahap berikutnya.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
