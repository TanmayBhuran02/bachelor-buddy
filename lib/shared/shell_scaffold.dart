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
    final activeIconColor = AppColors.text(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: AppColors.border(context),
              width: 1.5,
            ),
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
              selectedIcon: Icon(Icons.home, color: activeIconColor, size: 22),
              label: 'HOME',
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 22),
              selectedIcon: Icon(Icons.account_balance_wallet, color: activeIconColor, size: 22),
              label: 'SPEND',
            ),
            NavigationDestination(
              icon: const Icon(Icons.lunch_dining_outlined, size: 22),
              selectedIcon: Icon(Icons.lunch_dining, color: activeIconColor, size: 22),
              label: 'TIFFIN',
            ),
            NavigationDestination(
              icon: const Icon(Icons.checklist_outlined, size: 22),
              selectedIcon: Icon(Icons.checklist, color: activeIconColor, size: 22),
              label: 'TASKS',
            ),
            NavigationDestination(
              icon: const Icon(Icons.water_drop_outlined, size: 22),
              selectedIcon: Icon(Icons.water_drop, color: activeIconColor, size: 22),
              label: 'WATER',
            ),
          ],
        ),
      ),
    );
  }
}
