import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Overlay layar penuh untuk siklus waktu shalat di TV.
///
/// - `preAdhan` / `preIqomah`: circular progress ring + ikon + countdown.
/// - `adhan`: wavy progress bar dengan palet moody low-contrast.
/// - `shalat`: layar gelap redup total dengan teks statis sangat redup.
/// - `normal`: tidak menampilkan apa pun.
class PrayerStateOverlay extends StatelessWidget {
  final PrayerPhase phase;
  final String? prayerName;
  final Duration remaining;
  final Duration total;
  final DateTime? deadline;
  final String? fridayKhatib;
  final String? fridayMuadzin;

  const PrayerStateOverlay({
    super.key,
    required this.phase,
    this.prayerName,
    required this.remaining,
    required this.total,
    this.deadline,
    this.fridayKhatib,
    this.fridayMuadzin,
  });

  @override
  Widget build(BuildContext context) {
    final name = prayerName ?? '';
    switch (phase) {
      case PrayerPhase.preAdhan:
        return _CountdownOverlay(
          icon: Icons.access_time_rounded,
          headline: 'Menjelang Azan $name',
          caption: 'Bersiap menyambut azan. Mohon jaga ketenangan dan khusyuk.',
          progressColor: Theme.of(context).colorScheme.primary,
          remaining: remaining,
          total: total,
        );
      case PrayerPhase.adhan:
        return _AdhanOverlay(
          prayerName: name,
          remaining: remaining,
          total: total,
          deadline: deadline,
        );
      case PrayerPhase.khutbah:
        return _KhutbahOverlay(
          khatib: fridayKhatib,
          muadzin: fridayMuadzin,
          remaining: remaining,
          total: total,
        );
      case PrayerPhase.preIqomah:
        return _CountdownOverlay(
          icon: Icons.groups_rounded,
          headline: 'Shalat $name Sebentar Lagi',
          caption: 'Mohon merapatkan shaf dan mematikan nada dering HP.',
          progressColor: Theme.of(context).colorScheme.tertiary,
          remaining: remaining,
          total: total,
        );
      case PrayerPhase.shalat:
        return _ShalatOverlay(prayerName: name);
      case PrayerPhase.normal:
        return const SizedBox.shrink();
    }
  }
}

/// Circular progress ring countdown untuk PRE_ADHAN / PRE_IQOMAH.
class _CountdownOverlay extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String caption;
  final Color progressColor;
  final Duration remaining;
  final Duration total;

  const _CountdownOverlay({
    required this.icon,
    required this.headline,
    required this.caption,
    required this.progressColor,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction =
        total > Duration.zero ? (remaining.inMilliseconds / total.inMilliseconds) : 0.0;

    return Container(
      color: Colors.black.withValues(alpha: 0.78),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedProgressRing(
            progress: fraction.clamp(0.0, 1.0),
            size: 210,
            strokeWidth: 14,
            color: progressColor,
            trackColor: Colors.white.withValues(alpha: 0.10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 34, color: Colors.white.withValues(alpha: 0.85)),
                const SizedBox(height: 6),
                Text(
                  _formatCountdown(remaining),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                Text(
                  'menuju azan',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan khusyuk azan: wavy progress bar dengan palet moody low-contrast.
class _AdhanOverlay extends StatelessWidget {
  final String prayerName;
  final Duration remaining;
  final Duration total;
  final DateTime? deadline;

  const _AdhanOverlay({
    required this.prayerName,
    required this.remaining,
    required this.total,
    this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: _moodyBackground,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _moodyPanel,
                border: Border.all(color: _moodyAmber.withValues(alpha: 0.35), width: 2),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                size: 56,
                color: _moodyAmber,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Azan $prayerName Berkumandang',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: _moodyText,
                fontSize: 38,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon khusyuk mendengarkan azan',
              style: theme.textTheme.bodyLarge?.copyWith(color: _moodyMuted),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _WavyProgressBar(
                remaining: remaining,
                total: total,
                deadline: deadline,
                activeColor: _moodySage,
                trackColor: _moodyTeal.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatCountdown(remaining),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: _moodyAmber,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layar redup saat khutbah Jumat berlangsung (fase `khutbah`).
///
/// Menampilkan ring countdown durasi khutbah yang tenang, plus nama khatib &
/// muadzin yang di-input dari Remote. Menggantikan "Jeda Ikamah" di hari Jumat.
class _KhutbahOverlay extends StatelessWidget {
  final String? khatib;
  final String? muadzin;
  final Duration remaining;
  final Duration total;

  const _KhutbahOverlay({
    required this.khatib,
    required this.muadzin,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed =
        (total - remaining).isNegative ? Duration.zero : (total - remaining);

    return Container(
      color: _moodyBackground,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _moodyPanel,
                border: Border.all(
                  color: _moodySage.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 56,
                color: _moodySage,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Khutbah Jumat Sedang Berlangsung',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: _moodyText,
                fontSize: 38,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon khusyuk mendengarkan khutbah',
              style: theme.textTheme.bodyLarge?.copyWith(color: _moodyMuted),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _WavyProgressBar(
                remaining: const Duration(seconds: 1),
                total: const Duration(seconds: 1),
                deadline: null,
                activeColor: _moodySage,
                trackColor: _moodyTeal.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatCountdown(elapsed),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: _moodySage,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 40,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _StaffChip(
                  icon: Icons.person_rounded,
                  label: 'Khatib',
                  name: khatib,
                ),
                _StaffChip(
                  icon: Icons.campaign_rounded,
                  label: 'Muadzin',
                  name: muadzin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? name;

  const _StaffChip({
    required this.icon,
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: _moodyTeal.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _moodySage.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: _moodySage),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                name ?? '-',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Layar gelap redup total saat shalat berlangsung.
class _ShalatOverlay extends StatelessWidget {
  final String prayerName;

  const _ShalatOverlay({required this.prayerName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        'Sedang Melangsungkan Shalat $prayerName',
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.24),
          fontSize: 26,
        ),
      ),
    );
  }
}

/// Circular progress ring dengan animasi halus berbasis CustomPainter.
class _AnimatedProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final Widget child;

  const _AnimatedProgressRing({
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CircularRingPainter(
                    progress: value,
                    trackColor: trackColor,
                    progressColor: color,
                    strokeWidth: strokeWidth,
                  ),
                ),
              ),
              child,
            ],
          );
        },
      ),
    );
  }
}

/// Wavy progress bar beranimasi (single sine wave stroke line) — 60 FPS via `repaint`.
///
/// Progress dihitung dari [deadline] (waktu mutlak berakhir fase) terhadap
/// `DateTime.now()` saat `paint`, sehingga cursor bergerak mulus sub-detik
/// tanpa menunggu tick 1 detik dari state machine.
class _WavyProgressBar extends StatefulWidget {
  final Duration remaining;
  final Duration total;
  final DateTime? deadline;
  final Color activeColor;
  final Color trackColor;

  const _WavyProgressBar({
    required this.remaining,
    required this.total,
    this.deadline,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  State<_WavyProgressBar> createState() => _WavyProgressBarState();
}

class _WavyProgressBarState extends State<_WavyProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavyProgressPainter(
        animation: _controller,
        remaining: widget.remaining,
        total: widget.total,
        deadline: widget.deadline,
        activeColor: widget.activeColor,
        trackColor: widget.trackColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

String _formatCountdown(Duration duration) {
  if (duration.isNegative) duration = Duration.zero;
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Custom Painters
// ---------------------------------------------------------------------------

/// Melukis ring circular progress (jalur track + busur progress).
class _CircularRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arcPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Melukis **single wavy stroke line** ala media player Material You
/// (bukan liquid fill): track garis redup + garis gelombang sinus aktif +
/// cursor bar vertikal `|` di ujung kanannya.
/// Fase gelombang dibaca langsung dari [animation] saat paint, sehingga
/// animasi 60 FPS berjalan tanpa rebuild widget (hanya repaint).
/// Progress aktif dihitung sub-detik dari [deadline] terhadap `DateTime.now()`
/// di tiap frame paint → pergerakan cursor mulus 60 FPS.
class _WavyProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final Duration remaining;
  final Duration total;
  final DateTime? deadline;
  final Color activeColor;
  final Color trackColor;

  _WavyProgressPainter({
    required this.animation,
    required this.remaining,
    required this.total,
    required this.deadline,
    required this.activeColor,
    required this.trackColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Progress sub-detik: utamakan deadline (wall-clock), fallback ke
    // snapshot `remaining` dari state machine bila deadline tidak tersedia.
    final totalMs = total.inMilliseconds;
    final end = deadline;
    final double smoothProgress;
    if (totalMs > 0 && end != null) {
      final remainingMs = end.difference(DateTime.now()).inMilliseconds;
      smoothProgress = (remainingMs / totalMs).clamp(0.0, 1.0);
    } else if (totalMs > 0) {
      smoothProgress = (remaining.inMilliseconds / totalMs).clamp(0.0, 1.0);
    } else {
      smoothProgress = 0.0;
    }
    final activeWidth = size.width * smoothProgress;

    // Track latar belakang (dimmed line) selebar container.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      trackPaint,
    );

    if (activeWidth <= 0) return;

    // Batas akhir gelombang: offset ke kiri sebesar strokeWidth/2 (4.0) + 3.0
    // agar StrokeCap.round berhenti rapi sedikit di belakang garis cursor
    // di x = activeWidth (jarak ekstra agar tidak terlihat menempel).
    final waveEndX = math.max(0.0, activeWidth - 7.0);

    // Garis gelombang aktif: y = centerY + amplitude * sin((x/λ)·2π - phase).
    const amplitude = 5.0;
    const wavelength = 52.0;
    final phase = animation.value * 2 * math.pi;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, centerY + amplitude * math.sin(-phase));
    const step = 2.0;
    for (double x = step; x <= waveEndX; x += step) {
      final y = centerY +
          amplitude * math.sin((x / wavelength) * 2 * math.pi - phase);
      path.lineTo(x, y);
    }
    final endY = centerY +
        amplitude * math.sin((waveEndX / wavelength) * 2 * math.pi - phase);
    path.lineTo(waveEndX, endY);
    canvas.drawPath(path, activePaint);

    // Cursor bar vertikal tegak lurus di ujung kanan garis aktif.
    const cursorHeight = 22.0;
    final cursorPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(activeWidth, centerY - cursorHeight / 2),
      Offset(activeWidth, centerY + cursorHeight / 2),
      cursorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) {
    return oldDelegate.remaining != remaining ||
        oldDelegate.total != total ||
        oldDelegate.deadline != deadline ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

// Palet moody low-contrast untuk tampilan azan (muted teal/olive/amber/sage).
const _moodyBackground = Color(0xFF141814);
const _moodyPanel = Color(0xFF232A24);
const _moodySage = Color(0xFF9AA79B);
const _moodyTeal = Color(0xFF6B7D74);
const _moodyAmber = Color(0xFFC9AF7D);
const _moodyText = Color(0xFFD9DCCF);
const _moodyMuted = Color(0xFFA8AFA3);
