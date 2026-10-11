/// Water Tracker screen — minimal: gradient progress ring + "+1 Glass" button + settings.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

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
      backgroundColor: AppColors.card(context),
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

    final isNeo = AppColors.styleOf(context) == AppThemeStyle.neobrutalism;
    final progressColor = isNeo ? AppColors.neoCyan : AppColors.secondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Header summary stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                label: 'DRANK TODAY',
                value: '${_formatMl(status.intakeMl)} ML',
                color: progressColor,
              ),
              Container(
                height: 28,
                width: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.border(context),
              ),
              _StatItem(
                label: 'DAILY GOAL',
                value: '${_formatMl(status.goalMl)} ML',
                color: AppColors.text(context),
              ),
              Container(
                height: 28,
                width: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.border(context),
              ),
              _StatItem(
                label: 'REMAINING',
                value: '${_formatMl(remaining)} ML',
                color: remaining == 0 ? AppColors.secondary : AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: 36),

          // ── The Interactive Circular +1 Glass Button & Progress Border ──
          _CircularHydrationButton(
            status: status,
            percent: percent,
            progressColor: progressColor,
            isNeo: isNeo,
            onTap: () async {
              await HapticFeedback.mediumImpact();
              await repo.addWater(status.glassMl);
            },
          ),

          const SizedBox(height: 28),

          // Glasses summary text
          Text(
            '${status.glassesDrank} OF ${status.totalGlasses} GLASSES COMPLETED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted(context),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: 24),

          // Secondary Action (Undo last glass)
          if (status.logs.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () async {
                await HapticFeedback.lightImpact();
                await repo.deleteWaterLog(status.logs.first.id);
              },
              icon: const Icon(Icons.undo, size: 16),
              label: Text(
                'UNDO LAST GLASS (-${status.logs.first.amountMl} ML)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.border(context),
                  width: isNeo ? 2.0 : 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isNeo ? 4 : 2),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(ml % 1000 == 0 ? 0 : 1)}K';
    }
    return '$ml';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: AppColors.textMuted(context),
                letterSpacing: 0.8,
              ),
        ),
      ],
    );
  }
}

// ─── Circular Hydration Button ─────────────────────────────────────────────

class _CircularHydrationButton extends StatefulWidget {
  final TodayWaterStatus status;
  final int percent;
  final Color progressColor;
  final bool isNeo;
  final VoidCallback onTap;

  const _CircularHydrationButton({
    required this.status,
    required this.percent,
    required this.progressColor,
    required this.isNeo,
    required this.onTap,
  });

  @override
  State<_CircularHydrationButton> createState() =>
      _CircularHydrationButtonState();
}

class _CircularHydrationButtonState extends State<_CircularHydrationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const size = 250.0;
    const strokeWidth = 11.0;

    final cardBg = widget.isNeo
        ? (Theme.of(context).brightness == Brightness.dark
            ? AppColors.neoCardDark
            : const Color(0xFFFFFFFF))
        : AppColors.card(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _HydrationRingPainter(
              progress: widget.status.progress,
              trackColor: AppColors.track(context),
              progressColor: widget.progressColor,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Container(
                width: size - (strokeWidth * 2) - 16,
                height: size - (strokeWidth * 2) - 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  border: Border.all(
                    color: AppColors.border(context),
                    width: widget.isNeo ? 2.5 : 1.5,
                  ),
                  boxShadow: widget.isNeo
                      ? const [
                          BoxShadow(
                            color: Color(0xFF000000),
                            offset: Offset(3.5, 3.5),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Water drop icon with ripple container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isNeo
                            ? AppColors.neoCyan
                            : widget.progressColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.border(context),
                          width: widget.isNeo ? 2.0 : 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: widget.isNeo
                            ? const Color(0xFF000000)
                            : widget.progressColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // +1 GLASS prominent button label
                    Text(
                      '+1 GLASS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.text(context),
                          ),
                    ),

                    // Portion label
                    Text(
                      '+${widget.status.glassMl} ML',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: widget.progressColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Progress percentage pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.isNeo ? 4 : 2),
                        color: widget.isNeo
                            ? AppColors.neoYellow
                            : widget.progressColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.border(context),
                          width: widget.isNeo ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        '${widget.percent}% GOAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: widget.isNeo
                              ? const Color(0xFF000000)
                              : widget.progressColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tap prompt
                    Text(
                      'TAP TO DRINK',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Progress Ring Painter ──────────────────────────────────────────

class _HydrationRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _HydrationRingPainter({
    required this.progress,
    required this.trackColor,
    this.progressColor = AppColors.secondary,
    this.strokeWidth = 11.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - (strokeWidth / 2);
    const startAngle = -math.pi / 2; // 12 o'clock

    // Track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: center, radius: radius);

      final arcPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_HydrationRingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.strokeWidth != strokeWidth;
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
