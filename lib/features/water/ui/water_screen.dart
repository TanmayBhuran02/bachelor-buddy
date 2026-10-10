/// Water Tracker screen — minimal: gradient progress ring + "+1 Glass" button + settings.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/features/water/domain/water_providers.dart';
import 'package:bachelor_buddy/features/water/data/water_repository.dart';

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(todayWaterStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WATER TRACKER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showSettingsModal(context, ref),
          ),
        ],
      ),
      body: statusAsync.when(
        data: (status) => _WaterBody(status: status),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showSettingsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (ctx) => const _WaterSettingsSheet(),
    );
  }
}

// ─── Main Body ─────────────────────────────────────────────────────────────

class _WaterBody extends ConsumerWidget {
  final TodayWaterStatus status;

  const _WaterBody({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(waterRepositoryProvider);
    final percent = (status.progress * 100).round();
    final remaining = (status.goalMl - status.intakeMl).clamp(0, status.goalMl);

    return Column(
      children: [
        const Spacer(flex: 2),

        // ── Raw Progress Ring ──────────────────────────────────────────
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _HydrationRingPainter(progress: status.progress),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Water drop icon in square container
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xFF1F1F1F),
                      border: Border.all(
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Large ml amount
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatMl(status.intakeMl),
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.paperWhite,
                              ),
                        ),
                        TextSpan(
                          text: ' ML',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Goal text
                  Text(
                    '/ ${_formatMl(status.goalMl)} ML',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF777777),
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Percentage pill badge (square corners)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xFF1F1F1F),
                      border: Border.all(
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                    child: Text(
                      '$percent% OF GOAL',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Remaining / glasses info
        Text(
          '${status.glassesDrank} GLASSES • ${_formatMl(remaining)} ML LEFT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF777777),
                letterSpacing: 0.8,
              ),
        ),

        const Spacer(flex: 3),

        // ── +1 Glass Button ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () async {
                await repo.addWater(status.glassMl);
              },
              icon: const Icon(Icons.local_drink, size: 20),
              label: Text(
                '+1 GLASS (${status.glassMl}ML)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(ml % 1000 == 0 ? 0 : 1)}K';
    }
    return '$ml';
  }
}

// ─── Custom Progress Ring Painter ──────────────────────────────────────────

class _HydrationRingPainter extends CustomPainter {
  final double progress;

  _HydrationRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 8;
    const strokeWidth = 8.0;
    const startAngle = -math.pi / 2; // 12 o'clock

    // Track ring (raw dark grey)
    final trackPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (solid raw teal, no glow, square cap)
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: center, radius: radius);

      final arcPaint = Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square;

      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_HydrationRingPainter old) => old.progress != progress;
}

// ─── Settings Bottom Sheet ─────────────────────────────────────────────────

class _WaterSettingsSheet extends ConsumerStatefulWidget {
  const _WaterSettingsSheet();

  @override
  ConsumerState<_WaterSettingsSheet> createState() =>
      _WaterSettingsSheetState();
}

class _WaterSettingsSheetState extends ConsumerState<_WaterSettingsSheet> {
  final _goalController = TextEditingController();
  final _glassController = TextEditingController();
  int _interval = 60;
  bool _enabled = true;
  bool _initialized = false;

  @override
  void dispose() {
    _goalController.dispose();
    _glassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(waterSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        if (!_initialized) {
          _goalController.text = '${settings.dailyGoalMl}';
          _glassController.text = '${settings.glassMl}';
          _interval = settings.reminderIntervalMin;
          _enabled = settings.remindersEnabled;
          _initialized = true;
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('WATER GOAL & REMINDERS',
                      style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'DAILY GOAL (ML)',
                  suffixText: 'ml',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _glassController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'GLASS SIZE (ML)',
                  suffixText: 'ml',
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _interval,
                decoration: const InputDecoration(labelText: 'REMINDER INTERVAL'),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('EVERY 30 MINS')),
                  DropdownMenuItem(value: 45, child: Text('EVERY 45 MINS')),
                  DropdownMenuItem(value: 60, child: Text('EVERY 1 HOUR')),
                  DropdownMenuItem(value: 90, child: Text('EVERY 1.5 HOURS')),
                  DropdownMenuItem(value: 120, child: Text('EVERY 2 HOURS')),
                ],
                onChanged: (val) => setState(() => _interval = val!),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('ENABLE REMINDERS'),
                subtitle: const Text('Notifications during active daytime'),
                value: _enabled,
                onChanged: (val) => setState(() => _enabled = val),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    final goal = int.tryParse(_goalController.text) ?? 2500;
                    final glass = int.tryParse(_glassController.text) ?? 200;

                    final repo = ref.read(waterRepositoryProvider);
                    await repo.updateSettings(
                      dailyGoalMl: goal,
                      glassMl: glass,
                      dayStart: settings.dayStart,
                      dayEnd: settings.dayEnd,
                      reminderIntervalMin: _interval,
                      remindersEnabled: _enabled,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE SETTINGS'),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
