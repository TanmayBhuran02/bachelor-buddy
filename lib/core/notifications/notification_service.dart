/// Notification service using flutter_local_notifications.
/// Handles tiffin reminders, water reminders, todo reminders, and bill alerts.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:go_router/go_router.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Channel IDs
  static const String tiffinChannelId = 'tiffin_reminders';
  static const String waterChannelId = 'water_reminders';
  static const String todoChannelId = 'todo_reminders';
  static const String billChannelId = 'bill_reminders';
  static const String txnChannelId = 'txn_detected';

  /// Deterministic ID generator from string keys
  static int hashId(String key, [int prefix = 0]) {
    return prefix + (key.hashCode.abs() % 50000);
  }

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo));
      AppLogger.info('Timezone configured: $timeZoneInfo', context: 'Notification');
    } catch (e) {
      AppLogger.warn('Failed to get local timezone from system: $e', context: 'Notification');
      try {
        final offset = DateTime.now().timeZoneOffset;
        if (offset.inHours == 5 && offset.inMinutes % 60 == 30) {
          tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        } else {
          tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
        }
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          tiffinChannelId,
          'Tiffin Reminders',
          description: 'Daily meal reminders and confirmations',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          waterChannelId,
          'Water Reminders',
          description: 'Hydration reminders during active hours',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          todoChannelId,
          'Task Reminders',
          description: 'Reminders for scheduled to-do items',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          billChannelId,
          'Budget & Bill Alerts',
          description: 'Monthly budget warnings and bill due alerts',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          txnChannelId,
          'Transaction Detected',
          description: 'Auto-detected expense confirmations',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    // Check if app was launched from a notification
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      pendingPayload = launchDetails?.notificationResponse?.payload;
      AppLogger.info(
        'App launched from notification payload: $pendingPayload',
        context: 'Notification',
      );
    }

    _initialized = true;
    AppLogger.info('NotificationService initialized', context: 'Notification');
  }

  static String? pendingPayload;

  /// Route to appropriate screen based on notification payload
  static void handlePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;
    AppLogger.info('Routing payload: $payload', context: 'Notification');

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      pendingPayload = payload;
      return;
    }

    try {
      if (payload.startsWith('todo:')) {
        context.go('/todo');
      } else if (payload.startsWith('water:')) {
        context.go('/water');
      } else if (payload.startsWith('tiffin:')) {
        context.go('/tiffin');
      } else if (payload.startsWith('budget:')) {
        context.go('/budget');
      } else if (payload.startsWith('txn_recorded:')) {
        final txId = payload.replaceFirst('txn_recorded:', '');
        context.go('/expenses/edit/$txId');
      } else if (payload.startsWith('txn:') || payload.contains('amountPaise')) {
        context.go('/expenses');
      }
    } catch (e) {
      AppLogger.error('Failed to navigate to payload $payload: $e', context: 'Notification');
    }
  }

  /// Process any pending notification payload that arrived before navigation was ready
  static void processPendingPayload() {
    if (pendingPayload != null) {
      final payload = pendingPayload;
      pendingPayload = null;
      handlePayload(payload);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info(
      'Notification tapped: ${response.payload}',
      context: 'Notification',
    );
    handlePayload(response.payload);
  }

  /// Request notification & exact alarm permissions on Android
  Future<bool?> requestPermissions() async {
    if (kIsWeb) return false;
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidImplementation?.requestExactAlarmsPermission();
    } catch (e) {
      AppLogger.warn('requestExactAlarmsPermission error: $e', context: 'Notification');
    }
    return await androidImplementation?.requestNotificationsPermission();
  }

  /// Check whether exact alarms can be scheduled on Android
  Future<bool> canScheduleExactNotifications() async {
    if (kIsWeb) return false;
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImplementation?.canScheduleExactNotifications() ?? true;
  }

  /// Schedule daily tiffin reminder
  Future<void> scheduleTiffinReminder({
    required int id,
    required String providerName,
    required String mealType,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          tiffinChannelId,
          'Tiffin Reminders',
          channelDescription: 'Daily meal reminders and confirmations',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      try {
        await _plugin.zonedSchedule(
          id,
          'Tiffin Reminder ($mealType)',
          'Did you receive your $mealType from $providerName?',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'tiffin:$id',
        );
      } catch (e) {
        AppLogger.warn('Exact alarm for tiffin failed, falling back to inexact: $e', context: 'Notification');
        await _plugin.zonedSchedule(
          id,
          'Tiffin Reminder ($mealType)',
          'Did you receive your $mealType from $providerName?',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'tiffin:$id',
        );
      }

      AppLogger.info('Scheduled tiffin reminder ($mealType) at $scheduledDate (id=$id)', context: 'Notification');
    } catch (e) {
      AppLogger.error('Failed to schedule tiffin reminder: $e', context: 'Notification');
    }
  }

  /// Schedule water reminder intervals
  Future<void> scheduleWaterReminders({
    required int intervalMinutes,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    if (kIsWeb) return;
    await cancelWaterReminders();

    final now = tz.TZDateTime.now(tz.local);
    int notificationId = 1000;

    var currentSlot = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      startHour,
      startMinute,
    );
    final endSlot = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      endHour,
      endMinute,
    );

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        waterChannelId,
        'Water Reminders',
        channelDescription: 'Hydration reminders during active hours',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        enableVibration: true,
      ),
    );

    while (currentSlot.isBefore(endSlot) && notificationId < 1050) {
      var target = currentSlot;
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }

      try {
        await _plugin.zonedSchedule(
          notificationId,
          'Time to Hydrate! 💧',
          'Drink a glass of water to hit your daily goal.',
          target,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'water:$notificationId',
        );
      } catch (e) {
        try {
          await _plugin.zonedSchedule(
            notificationId,
            'Time to Hydrate! 💧',
            'Drink a glass of water to hit your daily goal.',
            target,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'water:$notificationId',
          );
        } catch (err) {
          AppLogger.error('Error scheduling water reminder slot $notificationId: $err', context: 'Notification');
        }
      }

      currentSlot = currentSlot.add(Duration(minutes: intervalMinutes));
      notificationId++;
    }
    AppLogger.info('Scheduled water reminder slots from $startHour:$startMinute to $endHour:$endMinute', context: 'Notification');
  }

  /// Cancel all scheduled water reminders (IDs 1000..1050)
  Future<void> cancelWaterReminders() async {
    for (var i = 1000; i < 1050; i++) {
      await _plugin.cancel(i);
    }
  }

  /// Schedule a todo reminder with exact alarm delivery
  Future<void> scheduleTodoReminder({
    required int id,
    required String title,
    required DateTime dueAt,
  }) async {
    if (kIsWeb) return;

    final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.local,
      dueAt.millisecondsSinceEpoch,
    );
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) {
      AppLogger.warn(
        'Skipping todo reminder for "$title": scheduled $scheduledDate is before now $now',
        context: 'Notification',
      );
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        todoChannelId,
        'Task Reminders',
        channelDescription: 'Reminders for scheduled to-do items',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        'Task Due: $title',
        'Don\'t forget: $title',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'todo:$id',
      );
      AppLogger.info(
        'Successfully scheduled exact todo reminder for "$title" at $scheduledDate (id=$id)',
        context: 'Notification',
      );
    } catch (e) {
      AppLogger.warn(
        'Exact alarm for todo failed ($e), falling back to inexact',
        context: 'Notification',
      );
      try {
        await _plugin.zonedSchedule(
          id,
          'Task Due: $title',
          'Don\'t forget: $title',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'todo:$id',
        );
        AppLogger.info(
          'Scheduled inexact fallback todo reminder for "$title" at $scheduledDate (id=$id)',
          context: 'Notification',
        );
      } catch (err) {
        AppLogger.error('Failed to schedule todo reminder: $err', context: 'Notification');
      }
    }
  }

  /// Show instant budget alert
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        billChannelId,
        'Budget & Bill Alerts',
        channelDescription: 'Monthly budget warnings and bill due alerts',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    try {
      await _plugin.show(id, title, body, details, payload: 'budget:$id');
      AppLogger.info('Showed budget alert: $title', context: 'Notification');
    } catch (e) {
      AppLogger.error('Failed to show budget alert: $e', context: 'Notification');
    }
  }

  /// Show transaction detected notification
  Future<void> showTxnDetectedNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        txnChannelId,
        'Transaction Detected',
        channelDescription: 'Auto-detected expense confirmations',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    try {
      await _plugin.show(id, title, body, details, payload: payload);
      AppLogger.info('Showed txn detected notification: $title', context: 'Notification');
    } catch (e) {
      AppLogger.error('Failed to show txn detected notification: $e', context: 'Notification');
    }
  }

  /// Cancel notification by ID
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    AppLogger.info('Cancelled notification id=$id', context: 'Notification');
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    AppLogger.info('Cancelled all notifications', context: 'Notification');
  }
}
