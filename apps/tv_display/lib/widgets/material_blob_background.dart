import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

/// Latar belakang M3 Expressive: bentuk-bentuk Material Shapes
/// (cookie, clover, flower, sunny) berputar dan melayang pelan
/// dengan warna teal/emerald transparan ala media player.
///
/// Tidak memakai `BackdropFilter` (mahal); hanya `MaskFilter.blur` kecil
/// agar tepi tetap tajam. Performa 60 FPS: animasi digerakkan lewat
/// `AnimationController.repeat()` dan dibaca langsung di painter via
/// `super(repaint:)` — tanpa rebuild widget tree tiap frame.
class MaterialBlobBackground extends StatefulWidget {
  const MaterialBlobBackground({super.key});

  @override
  State<MaterialBlobBackground> createState() => _MaterialBlobBackgroundState();
}

class _MaterialBlobBackgroundState extends State<MaterialBlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00897B);
    const emerald = Color(0xFF00A86B);
    const darkTeal = Color(0xFF00796B);

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _M3ShapePainter(
              animation: _controller,
              blobs: [
                _ShapeSpec(
                  polygon: MaterialShapes.cookie4Sided,
                  color: teal.withValues(alpha: 0.15),
                  centerX: 0.22,
                  centerY: 0.30,
                  radiusX: 0.30,
                  radiusY: 0.32,
                  rotationSpeed: 0.18,
                  driftSpeed: 0.26,
                  driftPhase: 0.0,
                  size: 160,
                ),
                _ShapeSpec(
                  polygon: MaterialShapes.clover4Leaf,
                  color: emerald.withValues(alpha: 0.12),
                  centerX: 0.78,
                  centerY: 0.68,
                  radiusX: 0.32,
                  radiusY: 0.28,
                  rotationSpeed: -0.14,
                  driftSpeed: 0.20,
                  driftPhase: 2.1,
                  size: 160,
                ),
                _ShapeSpec(
                  polygon: MaterialShapes.flower,
                  color: darkTeal.withValues(alpha: 0.10),
                  centerX: 0.78,
                  centerY: 0.26,
                  radiusX: 0.26,
                  radiusY: 0.30,
                  rotationSpeed: 0.22,
                  driftSpeed: 0.30,
                  driftPhase: 4.2,
                  size: 120,
                ),
                _ShapeSpec(
                  polygon: MaterialShapes.sunny,
                  color: teal.withValues(alpha: 0.13),
                  centerX: 0.30,
                  centerY: 0.74,
                  radiusX: 0.28,
                  radiusY: 0.26,
                  rotationSpeed: -0.20,
                  driftSpeed: 0.24,
                  driftPhase: 1.2,
                  size: 140,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Spesifikasi satu bentuk M3: posisi pusat, radius drift, kecepatan rotasi,
/// dan ukuran. Path ternormalisasi sudah "dipusatkan" sekali saat dibuat.
class _ShapeSpec {
  final RoundedPolygon polygon;
  final Color color;
  final double centerX;
  final double centerY;
  final double radiusX;
  final double radiusY;
  final double rotationSpeed;
  final double driftSpeed;
  final double driftPhase;
  final double size;

  late final Path centeredPath = _buildCenteredPath();

  _ShapeSpec({
    required this.polygon,
    required this.color,
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    required this.rotationSpeed,
    required this.driftSpeed,
    required this.driftPhase,
    required this.size,
  });

  /// Path ternormalisasi (0..1) diskalakan ke [size] dan dipusatkan ke (0,0),
  /// sehingga tinggal di-translate & di-rotate canvas saat menggambar.
  Path _buildCenteredPath() {
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, size)
      ..setEntry(1, 1, size)
      ..setEntry(0, 3, -size / 2)
      ..setEntry(1, 3, -size / 2);
    return polygon.toPath().transform(matrix.storage);
  }
}

/// Melukis bentuk-bentuk M3 yang berotasi mengelilingi pusatnya dan
/// melayang mengikuti lintasan Lissajous organik (60 FPS repaint).
class _M3ShapePainter extends CustomPainter {
  final Animation<double> animation;
  final List<_ShapeSpec> blobs;

  _M3ShapePainter({
    required this.animation,
    required this.blobs,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (blobs.isEmpty) return;
    final t = animation.value * 2 * math.pi;

    for (final blob in blobs) {
      final x = size.width *
          (blob.centerX +
              blob.radiusX * math.sin(t * blob.driftSpeed + blob.driftPhase));
      final y = size.height *
          (blob.centerY +
              blob.radiusY *
                  math.cos(t * blob.driftSpeed * 0.8 + blob.driftPhase * 1.3));
      final angle = t * blob.rotationSpeed;

      final paint = Paint()
        ..color = blob.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawPath(blob.centeredPath, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _M3ShapePainter oldDelegate) {
    return oldDelegate.blobs != blobs;
  }
}
