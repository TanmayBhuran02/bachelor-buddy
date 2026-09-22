/// Bottom navigation shell scaffold.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/tiffin')) return 2;
    if (location.startsWith('/todo')) return 3;
    if (location.startsWith('/water')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          final routes = ['/home', '/expenses', '/tiffin', '/todo', '/water'];
          context.go(routes[i]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: const Icon(Icons.lunch_dining_outlined),
            selectedIcon: Icon(Icons.lunch_dining, color: AppColors.primary),
            label: 'Tiffin',
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist, color: AppColors.primary),
            label: 'To-do',
          ),
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop, color: AppColors.primary),
            label: 'Water',
          ),
        ],
      ),
    );
  }
}
