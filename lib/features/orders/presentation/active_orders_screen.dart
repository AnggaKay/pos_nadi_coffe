import 'package:flutter/material.dart';

import '../../../shared/widgets/app_shell.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(title: 'Pesanan aktif', child: _OrdersPlaceholder());
  }
}

class _OrdersPlaceholder extends StatelessWidget {
  const _OrdersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Pesanan yang sudah dibayar akan tampil di sini.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
