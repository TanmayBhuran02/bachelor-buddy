/// Water Tracker screen — minimal: gradient progress ring + "+1 Glass" button + settings.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/features/water/domain/water_providers.dart';
import 'package:bachelor_buddy/features/water/data/water_repository.dart';

// ─── Gradient / Glow Colors ────────────────────────────────────────────────
const _kCyanStart = Color(0xFF00E5FF);
const _kTealEnd = Color(0xFF00F5D4);
const _kTrackColor = Color(0xFF222332);

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(todayWaterStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

        // ── Progress Ring ──────────────────────────────────────────────
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _HydrationRingPainter(progress: status.progress),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Water drop icon in tinted circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kTealEnd.withValues(alpha: 0.15),
                      border: Border.all(
                        color: _kTealEnd.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: _kTealEnd,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),

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
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                        TextSpan(
                          text: ' ml',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _kTealEnd,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Goal text
                  Text(
                    '/ ${_formatMl(status.goalMl)} ml',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Percentage pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _kTealEnd.withValues(alpha: 0.10),
                      border: Border.all(
                        color: _kTealEnd.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$percent% of daily goal',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _kTealEnd,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Remaining / glasses info
        Text(
          '${status.glassesDrank} glasses \u2022 ${_formatMl(remaining)} ml left',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),

        const Spacer(flex: 3),

        // ── +1 Glass Button ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2B4), _kTealEnd, Color(0xFF06B6D4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kTealEnd.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await repo.addWater(status.glassMl);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_drink,
                          color: Color(0xFF0A1A1A), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        '+1 Glass (${status.glassMl}ml)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A1A1A),
                        ),
                      ),
                    ],
                  ),
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
      return '${(ml / 1000).toStringAsFixed(ml % 1000 == 0 ? 0 : 1)}k';
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
    const strokeWidth = 12.0;
    const startAngle = -math.pi / 2; // 12 o'clock

    // Track ring
    final trackPaint = Paint()
      ..color = _kTrackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: center, radius: radius);

      // Glow layer
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            _kCyanStart.withValues(alpha: 0.4),
            _kTealEnd.withValues(alpha: 0.4),
          ],
          stops: const [0.0, 1.0],
          transform: GradientRotation(startAngle),
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

      // Main arc
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: const [_kCyanStart, _kTealEnd],
          stops: const [0.0, 1.0],
          transform: GradientRotation(startAngle),
        ).createShader(rect);

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
                  Text('Water Goal & Reminders',
                      style: Theme.of(context).textTheme.titleLarge),
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
                  labelText: 'Daily Goal (ml)',
                  suffixText: 'ml',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _glassController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Glass Size (ml)',
                  suffixText: 'ml',
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _interval,
                decoration: const InputDecoration(labelText: 'Reminder Interval'),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('Every 30 mins')),
                  DropdownMenuItem(value: 45, child: Text('Every 45 mins')),
                  DropdownMenuItem(value: 60, child: Text('Every 1 hour')),
                  DropdownMenuItem(value: 90, child: Text('Every 1.5 hours')),
                  DropdownMenuItem(value: 120, child: Text('Every 2 hours')),
                ],
                onChanged: (val) => setState(() => _interval = val!),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Reminders'),
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
                  child: const Text('Save Settings'),
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
