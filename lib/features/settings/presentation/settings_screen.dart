import 'package:flutter/material.dart';

import '../../../shared/widgets/app_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Pengaturan',
      child: Center(
        child: Text(
          'Pengaturan perangkat dan printer akan tersedia setelah service hardware dibuat.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
