/// Granular notification preferences screen.
/// Allows enabling/disabling notifications for each section,
/// configuring Android Notification Access for auto-expense detection,
/// and toggling whitelisted UPI apps (GPay, PhonePe, Paytm, super.money, WhatsApp).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/notifications/notification_preferences.dart';
import 'package:bachelor_buddy/core/notifications/notification_scheduler.dart';
import 'package:bachelor_buddy/core/notifications/notification_service.dart';
import 'package:bachelor_buddy/providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _isLoading = true;
  bool _listenerPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final prefs = await NotificationPreferences.load(db);
    final granted =
        await NotificationPreferences.isNotificationListenerGranted();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _listenerPermissionGranted = granted;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermission() async {
    final granted =
        await NotificationPreferences.isNotificationListenerGranted();
    if (mounted) {
      setState(() {
        _listenerPermissionGranted = granted;
      });
    }
  }

  Future<void> _updatePrefs(NotificationPreferences newPrefs) async {
    setState(() => _prefs = newPrefs);
    final db = ref.read(databaseProvider);
    await NotificationPreferences.save(db, newPrefs);
    await NotificationScheduler.syncAllReminders(db, newPrefs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('NOTIFICATION SETTINGS')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATION SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Section reminders
          _SectionTitle(title: 'SECTION REMINDERS'),
          SwitchListTile(
            secondary: const Icon(Icons.water_drop_outlined, color: AppColors.secondary),
            title: const Text('Hydration Reminders'),
            subtitle: const Text('Periodic alerts during active hours to drink water'),
            value: _prefs.notifyWater,
            onChanged: (val) => _updatePrefs(_prefs.copyWith(notifyWater: val)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lunch_dining_outlined, color: AppColors.warning),
            title: const Text('Tiffin Reminders'),
            subtitle: const Text('Daily meal arrival alerts for active tiffin plans'),
            value: _prefs.notifyTiffin,
            onChanged: (val) => _updatePrefs(_prefs.copyWith(notifyTiffin: val)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.check_circle_outline, color: AppColors.budgetGreen),
            title: const Text('Task Reminders'),
            subtitle: const Text('Due date and scheduled time notifications for to-dos'),
            value: _prefs.notifyTodo,
            onChanged: (val) => _updatePrefs(_prefs.copyWith(notifyTodo: val)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber_rounded, color: AppColors.tertiary),
            title: const Text('Budget & Bill Alerts'),
            subtitle: const Text('Alerts when spending reaches 75%, 90%, and 100% of budget'),
            value: _prefs.notifyBudget,
            onChanged: (val) => _updatePrefs(_prefs.copyWith(notifyBudget: val)),
          ),

          const Divider(height: 32),

          // Auto-expense transaction detection
          _SectionTitle(title: 'TRANSACTION AUTO-DETECTION'),
          SwitchListTile(
            secondary: const Icon(Icons.bolt, color: AppColors.primary),
            title: const Text('Auto-Detect Expenses'),
            subtitle: const Text('Scan incoming banking and UPI notifications to create expenses'),
            value: _prefs.notifyTxnListener,
            onChanged: (val) async {
              await _updatePrefs(_prefs.copyWith(notifyTxnListener: val));
              if (val && !_listenerPermissionGranted) {
                await _checkPermission();
              }
            },
          ),

          if (_prefs.notifyTxnListener) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 0,
                color: _listenerPermissionGranted
                    ? AppColors.budgetGreen.withValues(alpha: 0.1)
                    : AppColors.tertiary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _listenerPermissionGranted
                        ? AppColors.budgetGreen.withValues(alpha: 0.4)
                        : AppColors.tertiary.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _listenerPermissionGranted
                                ? Icons.verified_user_outlined
                                : Icons.security_update_warning_outlined,
                            color: _listenerPermissionGranted
                                ? AppColors.budgetGreen
                                : AppColors.tertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _listenerPermissionGranted
                                  ? 'Android Notification Access: Granted'
                                  : 'Android Notification Access: Required',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _listenerPermissionGranted
                                    ? AppColors.budgetGreen
                                    : AppColors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _listenerPermissionGranted
                            ? 'Bachelor Buddy will passively detect UPI & bank transactions and prompt you with confirmation.'
                            : 'Bachelor Buddy needs Android Notification Access permission to read UPI transaction alerts.',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (!_listenerPermissionGranted) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tertiary,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.settings, size: 18),
                            label: const Text('Grant Notification Access'),
                            onPressed: () =>
                                NotificationPreferences.openNotificationListenerSettings(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'MONITORED UPI & BANK APPS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            ...kSupportedUpiApps.map((app) {
              final isChecked =
                  _prefs.enabledTxnPackages.contains(app.packageName);
              return CheckboxListTile(
                title: Text(app.displayName),
                subtitle: Text(
                  app.packageName,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                value: isChecked,
                onChanged: (enabled) {
                  final newSet = Set<String>.from(_prefs.enabledTxnPackages);
                  if (enabled == true) {
                    newSet.add(app.packageName);
                  } else {
                    newSet.remove(app.packageName);
                  }
                  _updatePrefs(_prefs.copyWith(enabledTxnPackages: newSet));
                },
              );
            }),
          ],

          const Divider(height: 32),

          // Test notification buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Test (Now)'),
                    onPressed: () async {
                      AppLogger.info('Triggered manual immediate test notification', context: 'Notifications');
                      final notifService = NotificationService();
                      await notifService.showBudgetAlert(
                        id: 9999,
                        title: '🔔 Immediate Test',
                        body: 'Bachelor Buddy immediate notifications are active!',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Immediate test notification sent!')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.timer_outlined),
                    label: const Text('Test (in 5s)'),
                    onPressed: () async {
                      AppLogger.info('Triggered manual scheduled test reminder (5s)', context: 'Notifications');
                      final notifService = NotificationService();
                      final testTime =
                          DateTime.now().add(const Duration(seconds: 5));
                      await notifService.scheduleTodoReminder(
                        id: 9998,
                        title: 'Scheduled Test Reminder',
                        dueAt: testTime,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Scheduled reminder set for 5s from now!',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
