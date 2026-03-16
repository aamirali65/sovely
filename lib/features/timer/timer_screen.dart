import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovely/core/providers/timer_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:sovely/core/providers/sound_providers.dart';
import 'package:sovely/core/theme/app_colors.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    ref.listen(timerProvider, (prev, next) {
      if (prev != null &&
          prev.isRunning &&
          !next.isRunning &&
          next.remainingSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.nightlight_round,
                    color: AppColors.cyan, size: 18),
                const SizedBox(width: 10),
                Text('Sleep well — sounds stopped',
                    style: GoogleFonts.dmSans(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    });

    final presets = [15, 30, 45, 60, 90, 120];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // ✅ Column instead of SingleChildScrollView — one page, no scroll
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Header ──────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'Sleep Timer',
                      style: GoogleFonts.sora(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(
                        begin: -0.2, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Sounds fade out automatically',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.textSecondary),
                    ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Timer Ring ──────────────────────────────
              Center(
                child: _TimerRing(timerState: timerState)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 150.ms)
                    .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),
              ),

              const SizedBox(height: 36),

              // ── Presets label ───────────────────────────
              Text(
                'QUICK PRESETS',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

              const SizedBox(height: 12),

              // ── Preset chips ────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...presets.asMap().entries.map((e) => _PresetChip(
                    label: e.value < 60
                        ? '${e.value}m'
                        : e.value % 60 == 0        // ✅ fixed label logic
                        ? '${e.value ~/ 60}hr'
                        : '${e.value ~/ 60}.5hr',
                    isSelected: timerState.selectedMinutes == e.value,
                    onTap: () => notifier.startTimer(e.value),
                  ).animate().fadeIn(
                    duration: 300.ms,
                    delay: (250 + e.key * 50).ms,
                  )),
                  _PresetChip(
                    label: 'Custom',
                    isSelected: false,
                    isCustom: true,
                    onTap: () => _showCustomInput(context, notifier),
                  ).animate().fadeIn(duration: 300.ms, delay: 550.ms),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const Spacer(), // ✅ pushes button to bottom naturally

              // ── Action button ───────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: timerState.isRunning
                    ? _ActionButton(
                  key: const ValueKey('cancel'),
                  label: 'Cancel Timer',
                  icon: Icons.stop_rounded,
                  isCancel: true,
                  onTap: notifier.cancelTimer,
                )
                    : _ActionButton(
                  key: const ValueKey('start'),
                  label: timerState.selectedMinutes > 0
                      ? 'Start Timer'
                      : 'Select a preset first',
                  icon: Icons.play_arrow_rounded,
                  isCancel: false,
                  onTap: timerState.selectedMinutes > 0
                      ? () =>
                      notifier.startTimer(timerState.selectedMinutes)
                      : null,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomInput(BuildContext context, TimerNotifier notifier) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Custom Duration',
              style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter minutes between 1 and 180',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g. 45',
                hintStyle:
                GoogleFonts.dmSans(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cyan),
                ),
                suffixText: 'min',
                suffixStyle: GoogleFonts.dmSans(color: AppColors.cyan),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  final mins = int.tryParse(controller.text) ?? 0;
                  if (mins > 0 && mins <= 180) {
                    notifier.startTimer(mins);
                    Navigator.pop(context);
                  }
                },
                child: Text('Start Timer',
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timer Ring ──────────────────────────────────────────────────────────────

class _TimerRing extends StatelessWidget {
  final TimerState timerState;
  const _TimerRing({required this.timerState});

  @override
  Widget build(BuildContext context) {
    final progress = timerState.selectedMinutes > 0
        ? timerState.remainingSeconds / (timerState.selectedMinutes * 60)
        : 0.0;

    return SizedBox(
      width: 240,        // ✅ slightly smaller to fit one page better
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (timerState.isRunning)
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => CustomPaint(
              size: const Size(240, 240),
              painter: _RingPainter(progress: value),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: timerState.isRunning
                    ? const Icon(Icons.nightlight_round,
                    color: AppColors.cyan,
                    size: 20,
                    key: ValueKey('moon'))
                    .animate()
                    .fadeIn()
                    .scale()
                    : const SizedBox(height: 20, key: ValueKey('empty')),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  timerState.isRunning || timerState.remainingSeconds > 0
                      ? timerState.formattedTime
                      : '00:00:00',
                  key: ValueKey(timerState.formattedTime),
                  style: GoogleFonts.sora(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timerState.isRunning ? 'fading out soon...' : 'set a duration',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceElevated
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final tickPaint = Paint()
      ..color = AppColors.cardBorder
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi - math.pi / 2;
      final isMajor = i % 5 == 0;
      final inner = radius - (isMajor ? 14 : 8);
      final outer = radius - 2;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
            center.dy + outer * math.sin(angle)),
        tickPaint,
      );
    }

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..shader = const LinearGradient(
            colors: [AppColors.cyan, AppColors.violet],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      final tipAngle = -math.pi / 2 + 2 * math.pi * progress;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      canvas.drawCircle(
        Offset(tipX, tipY),
        6,
        Paint()
          ..color = AppColors.cyan
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        Offset(tipX, tipY),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Preset Chip ──────────────────────────────────────────────────────────────

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyan
              : isCustom
              ? Colors.transparent
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.cyan
                : isCustom
                ? AppColors.cyan.withOpacity(0.4)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom) ...[
              Icon(Icons.tune_rounded,
                  size: 12,
                  color: AppColors.cyan.withOpacity(0.8)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.black
                    : isCustom
                    ? AppColors.cyan.withOpacity(0.9)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCancel;
  final VoidCallback? onTap;

  const _ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isCancel
              ? Colors.redAccent.withOpacity(0.12)
              : enabled
              ? AppColors.cyan
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancel
                ? Colors.redAccent.withOpacity(0.5)
                : enabled
                ? AppColors.cyan
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isCancel
                    ? Colors.redAccent
                    : enabled
                    ? Colors.black
                    : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isCancel
                    ? Colors.redAccent
                    : enabled
                    ? Colors.black
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}