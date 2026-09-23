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
    GoRoute(
      path: '/pos',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PosScreen()),
    ),
    GoRoute(
      path: '/orders',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ActiveOrdersScreen()),
    ),
    GoRoute(
      path: '/inventory',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: InventoryScreen()),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ReportsScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SettingsScreen()),
    ),
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
