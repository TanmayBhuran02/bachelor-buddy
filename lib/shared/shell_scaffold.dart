/// Bottom navigation shell scaffold — raw aesthetic.
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF3A3A3A), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) {
            final routes = ['/home', '/expenses', '/tiffin', '/todo', '/water'];
            context.go(routes[i]);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home, color: AppColors.paperWhite, size: 22),
              label: 'HOME',
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 22),
              selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.paperWhite, size: 22),
              label: 'SPEND',
            ),
            NavigationDestination(
              icon: const Icon(Icons.lunch_dining_outlined, size: 22),
              selectedIcon: Icon(Icons.lunch_dining, color: AppColors.paperWhite, size: 22),
              label: 'TIFFIN',
            ),
            NavigationDestination(
              icon: const Icon(Icons.checklist_outlined, size: 22),
              selectedIcon: Icon(Icons.checklist, color: AppColors.paperWhite, size: 22),
              label: 'TASKS',
            ),
            NavigationDestination(
              icon: const Icon(Icons.water_drop_outlined, size: 22),
              selectedIcon: Icon(Icons.water_drop, color: AppColors.paperWhite, size: 22),
              label: 'WATER',
            ),
          ],
        ),
      ),
    );
  }
}
