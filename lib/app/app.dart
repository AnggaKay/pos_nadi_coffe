import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/inventory/presentation/inventory_screen.dart';
import '../features/orders/presentation/active_orders_screen.dart';
import '../features/pos/presentation/pos_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/pos',
  routes: [
    GoRoute(path: '/pos', builder: (_, __) => const PosScreen()),
    GoRoute(path: '/orders', builder: (_, __) => const ActiveOrdersScreen()),
    GoRoute(path: '/inventory', builder: (_, __) => const InventoryScreen()),
    GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nadi Coffee POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
