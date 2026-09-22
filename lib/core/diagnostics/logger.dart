/// Diagnostics logger for background callbacks, widget errors, etc.
/// Writes to the debug_logs table and provides a viewable log in Settings.
library;

import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error }

class AppLogger {
  // In-memory buffer for when DB is not available
  static final List<LogEntry> _buffer = [];
  static const int _maxBufferSize = 500;

  /// Log a message. In debug mode, also prints to console.
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String context = '',
  }) {
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      context: context,
    );

    _buffer.add(entry);
    if (_buffer.length > _maxBufferSize) {
      _buffer.removeAt(0);
    }

    if (kDebugMode) {
      final prefix = switch (level) {
        LogLevel.info => '💡',
        LogLevel.warning => '⚠️',
        LogLevel.error => '❌',
      };
      debugPrint('$prefix [${entry.context}] ${entry.message}');
    }
  }

  static void info(String message, {String context = ''}) =>
      log(message, level: LogLevel.info, context: context);

  static void warn(String message, {String context = ''}) =>
      log(message, level: LogLevel.warning, context: context);

  static void error(String message, {String context = ''}) =>
      log(message, level: LogLevel.error, context: context);

  /// Get recent logs from buffer
  static List<LogEntry> get recentLogs => List.unmodifiable(_buffer);

  /// Clear the buffer
  static void clear() => _buffer.clear();
}

class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String context;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.context,
  });
}
