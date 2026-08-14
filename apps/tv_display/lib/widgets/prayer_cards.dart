import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class PrayerCardsRow extends StatelessWidget {
  final PrayerSchedule schedule;

  const PrayerCardsRow({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: schedule.items.map((item) {
        final isNext = item.type == schedule.nextPrayer;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Card(
              color: isNext ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: isNext
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: isNext ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge "SELANJUTNYA" in pill shape (StadiumBorder)
                    if (isNext)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: ShapeDecoration(
                            color: colorScheme.primary,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'SELANJUTNYA',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      item.type.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isNext
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isNext && schedule.timeUntilNextPrayer != null)
                      _NextPrayerTimer(
                        formattedTime: item.formattedTime,
                        remaining: schedule.timeUntilNextPrayer!,
                        progress: _remainingFraction(schedule),
                      )
                    else ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.formattedTime,
                          maxLines: 1,
                          softWrap: false,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  double _remainingFraction(PrayerSchedule schedule) {
    final remaining = schedule.timeUntilNextPrayer;
    if (remaining == null) return 0;
    final items = schedule.items;
    final idx = items.indexWhere((i) => i.type == schedule.nextPrayer);
    if (idx < 0) return 0;

    Duration total;
    if (idx > 0) {
      total = items[idx].time.difference(items[idx - 1].time);
    } else {
      // Next is Fajr: interval between yesterday's Isha and today's Fajr.
      final isha = items.last.time;
      total = items[0].time.difference(isha.subtract(const Duration(days: 1)));
    }

    if (total.inMilliseconds <= 0) return 0;
    final fraction = remaining.inMilliseconds / total.inMilliseconds;
    return fraction.clamp(0.0, 1.0);
  }
}

class _NextPrayerTimer extends StatefulWidget {
  final String formattedTime;
  final Duration remaining;
  final double progress;

  const _NextPrayerTimer({
    required this.formattedTime,
    required this.remaining,
    required this.progress,
  });

  @override
  State<_NextPrayerTimer> createState() => _NextPrayerTimerState();
}

class _NextPrayerTimerState extends State<_NextPrayerTimer> {
  bool _showCountdown = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _showCountdown = !_showCountdown;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: widget.progress,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
              color: colorScheme.primary,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0, 0.6),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: Column(
              key: ValueKey(_showCountdown),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showCountdown
                      ? _formatDuration(widget.remaining)
                      : widget.formattedTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  _showCountdown ? 'tersisa' : 'waktu',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      duration = Duration.zero;
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
