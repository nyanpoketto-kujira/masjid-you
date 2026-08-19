import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

/// `ShapeBorder` untuk membungkus [RoundedPolygon] M3 Expressive
/// sehingga bisa dipakai sebagai shape Card/Container/Button.
///
/// Polygon dari `MaterialShapes.*` bersifat ternormalisasi (0..1),
/// maka [getOuterPath] menskalakan path ke ukuran [Rect] yang diberikan.
///
/// Turunan [OutlinedBorder] agar juga sah dipakai di
/// `ButtonStyle.shape` (yang bertipe `OutlinedBorder?`).
class M3ShapeBorder extends OutlinedBorder {
  const M3ShapeBorder(this.polygon, {super.side = BorderSide.none});

  final RoundedPolygon polygon;

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return M3ShapeBorder(polygon, side: side ?? this.side);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _scaledPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _scaledPath(rect);
  }

  Path _scaledPath(Rect rect) {
    final path = polygon.toPath();
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, rect.width)
      ..setEntry(1, 1, rect.height)
      ..setEntry(0, 3, rect.left)
      ..setEntry(1, 3, rect.top);
    return path.transform(matrix.storage);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        canvas.drawPath(
          getOuterPath(rect, textDirection: textDirection),
          side.toPaint(),
        );
    }
  }

  @override
  ShapeBorder scale(double t) {
    return M3ShapeBorder(polygon, side: BorderSide.lerp(side, BorderSide.none, t));
  }
}

/// Arch (pintu masjid) manual — dome di bagian atas, sudut bawah rounded.
///
/// Dibuat manual (bukan `MaterialShapes.arch` dari package) karena polygon
/// package ternormalisasi sehingga saat di-stretch ke container lebar kubahnya
/// jadi terlalu besar & makan ruang vertikal.
class ArchBorder extends OutlinedBorder {
  const ArchBorder({
    super.side = BorderSide.none,
    this.bottomRadius = 28,
    this.domeFactor = 0.2,
  });

  /// Radius sudut bawah.
  final double bottomRadius;

  /// Tinggi kubah = [domeFactor] × lebar, di-clamp agar tidak lebih dari
  /// 40% tinggi container.
  final double domeFactor;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return ArchBorder(
      side: side ?? this.side,
      bottomRadius: bottomRadius,
      domeFactor: domeFactor,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final w = rect.width;
    final h = rect.height;
    final r = math.min(bottomRadius, math.min(w, h) / 2);
    final rise = math.min(w * domeFactor, h * 0.4);
    final cx = rect.left + w / 2;

    return Path()
      ..moveTo(rect.left, rect.bottom - r)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left + r, rect.bottom)
      ..lineTo(rect.right - r, rect.bottom)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - r)
      ..lineTo(rect.right, rect.top + rise)
      ..quadraticBezierTo(rect.right, rect.top, cx, rect.top)
      ..quadraticBezierTo(rect.left, rect.top, rect.left, rect.top + rise)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return ArchBorder(
      side: BorderSide.lerp(side, BorderSide.none, t),
      bottomRadius: bottomRadius * t,
      domeFactor: domeFactor,
    );
  }
}
