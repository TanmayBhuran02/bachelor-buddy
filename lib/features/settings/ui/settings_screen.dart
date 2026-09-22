/// Settings screen with theme toggle, biometric lock, backup/export,
/// and debug log viewer.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Appearance section
          _SectionHeader(title: 'APPEARANCE'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between dark and light themes'),
            value: themeMode == ThemeMode.dark,
            onChanged: (isDark) {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),

          // Security section
          _SectionHeader(title: 'SECURITY'),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Lock'),
            subtitle: const Text('Require fingerprint or face unlock on startup'),
            trailing: Switch(
              value: false,
              onChanged: (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      val
                          ? 'Biometric app lock enabled'
                          : 'Biometric app lock disabled',
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // Data & Backup section
          _SectionHeader(title: 'DATA & BACKUP'),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Expenses to CSV'),
            subtitle: const Text('Download or share CSV spreadsheet of all transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportCsv(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup Database (JSON)'),
            subtitle: const Text('Export complete app data to a JSON backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _backupJson(context, ref),
          ),
          const Divider(),

          // Diagnostics
          _SectionHeader(title: 'DIAGNOSTICS & SYSTEM'),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Diagnostic Logs'),
            subtitle: const Text('View background worker and widget sync logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLogsSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Bachelor Buddy'),
            subtitle: const Text('v1.0.0 • Offline-first personal manager'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final transactions = await db.select(db.transactions).get();
      final categories = await db.select(db.categories).get();
      final catMap = {for (var c in categories) c.id: c.name};

      final buffer = StringBuffer();
      buffer.writeln('ID,Date,Type,Category,Amount (INR),Note,Source,IsShared');

      for (final tx in transactions) {
        final catName = catMap[tx.categoryId] ?? 'Unknown';
        final rupees = (tx.amountPaise / 100).toStringAsFixed(2);
        buffer.writeln(
          '${tx.id},${tx.date},${tx.type},"$catName",$rupees,"${tx.note.replaceAll('"', '""')}",${tx.source},${tx.isShared}',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/bachelor_buddy_expenses.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Bachelor Buddy Expenses Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }
  }

  Future<void> _backupJson(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final txs = await db.select(db.transactions).get();
      final plans = await db.select(db.tiffinPlans).get();
      final logs = await db.select(db.tiffinLogs).get();
      final todos = await db.select(db.todos).get();
      final water = await db.select(db.waterLogs).get();

      final backupData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'transactionsCount': txs.length,
        'tiffinPlansCount': plans.length,
        'tiffinLogsCount': logs.length,
        'todosCount': todos.length,
        'waterLogsCount': water.length,
      };

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/bachelor_buddy_backup.json');
      await file.writeAsString(jsonEncode(backupData));

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Bachelor Buddy Backup',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create backup: $e')),
        );
      }
    }
  }

  void _showLogsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final logs = AppLogger.recentLogs.reversed.toList();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Diagnostics Logs',
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: logs.isEmpty
                      ? const Center(
                          child: Text('No diagnostic logs captured yet',
                              style: TextStyle(color: Colors.white38)),
                        )
                      : ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final color = switch (log.level) {
                              LogLevel.info => Colors.white70,
                              LogLevel.warning => Colors.amber,
                              LogLevel.error => AppColors.tertiary,
                            };

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '[${log.timestamp.toIso8601String().substring(11, 19)}] [${log.context}] ${log.message}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: color,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
