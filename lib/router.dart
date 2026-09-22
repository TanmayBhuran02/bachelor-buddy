/// GoRouter configuration with deep links and bottom navigation shell.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/ui/home_screen.dart';
import 'features/expenses/ui/expenses_screen.dart';
import 'features/expenses/ui/add_expense_screen.dart';
import 'features/tiffin/ui/tiffin_screen.dart';
import 'features/todo/ui/todo_screen.dart';
import 'features/todo/ui/add_todo_screen.dart';
import 'features/water/ui/water_screen.dart';
import 'features/budget/ui/budget_screen.dart';
import 'features/settings/ui/settings_screen.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'shared/shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({bool showOnboarding = false}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: showOnboarding ? '/onboarding' : '/home',
    routes: [
      // Onboarding (outside shell)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app with bottom navigation shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/expenses',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExpensesScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddExpenseScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AddExpenseScreen(
                  expenseId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/tiffin',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TiffinScreen(),
            ),
          ),
          GoRoute(
            path: '/todo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodoScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddTodoScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/water',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WaterScreen(),
            ),
          ),
        ],
      ),

      // Budget (full screen, not in bottom nav)
      GoRoute(
        path: '/budget',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BudgetScreen(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
