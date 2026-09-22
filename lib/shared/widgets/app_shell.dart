import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  static const _items = [
    (label: 'Kasir', icon: Icons.point_of_sale_outlined, path: '/pos'),
    (label: 'Pesanan', icon: Icons.receipt_long_outlined, path: '/orders'),
    (label: 'Stok', icon: Icons.inventory_2_outlined, path: '/inventory'),
    (label: 'Laporan', icon: Icons.bar_chart_outlined, path: '/reports'),
    (label: 'Pengaturan', icon: Icons.settings_outlined, path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _items.indexWhere((item) => item.path == currentPath);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDestinationSelected: (index) => context.go(_items[index].path),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.coffee, color: Colors.white),
              ),
            ),
            destinations: [
              for (final item in _items)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8E5DE))),
      ),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          const Icon(Icons.wifi, size: 18, color: Color(0xFF5D7767)),
          const SizedBox(width: 7),
          const Text('Online', style: TextStyle(color: Color(0xFF5D7767))),
          const SizedBox(width: 24),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFEFE8DE),
            child: Text('K', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          const Text('Kasir 01', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
