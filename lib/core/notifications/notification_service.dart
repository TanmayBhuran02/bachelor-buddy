/// Notification service using flutter_local_notifications.
/// Handles tiffin reminders, water reminders, todo reminders, and bill alerts.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:bachelor_buddy/core/diagnostics/logger.dart';

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

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo));
    } catch (e) {
      AppLogger.warn('Failed to get local timezone, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    AppLogger.info('NotificationService initialized', context: 'Notification');
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info(
      'Notification tapped: ${response.payload}',
      context: 'Notification',
    );
  }

  /// Request permissions on Android 13+
  Future<bool?> requestPermissions() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImplementation?.requestNotificationsPermission();
  }

  /// Schedule daily tiffin reminder
  Future<void> scheduleTiffinReminder({
    required int id,
    required String providerName,
    required String mealType,
    required int hour,
    required int minute,
  }) async {
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
        channelDescription: 'Daily reminder to confirm meal delivery',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

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
  }

  /// Schedule water reminder intervals
  Future<void> scheduleWaterReminders({
    required int intervalMinutes,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    // Cancel existing water reminders (IDs 1000..1050)
    for (var i = 1000; i < 1050; i++) {
      await _plugin.cancel(i);
    }

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
      ),
    );

    while (currentSlot.isBefore(endSlot) && notificationId < 1050) {
      var target = currentSlot;
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }

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

      currentSlot = currentSlot.add(Duration(minutes: intervalMinutes));
      notificationId++;
    }
  }

  /// Schedule a todo reminder
  Future<void> scheduleTodoReminder({
    required int id,
    required String title,
    required DateTime dueAt,
  }) async {
    final scheduledDate = tz.TZDateTime.from(dueAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        todoChannelId,
        'Task Reminders',
        channelDescription: 'Reminders for scheduled to-do items',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      'Task Due: $title',
      'Don\'t forget: $title',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'todo:$id',
    );
  }

  /// Cancel notification by ID
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
