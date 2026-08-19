import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Bungkus tombol/konten interaktif dengan feedback tekan spring M3 Expressive.
///
/// Skala mengecil halus saat ditekan lalu "pegas" kembali dengan satu
/// [SpringDescription] konsisten (mengikuti prinsip motion M3 Expressive:
/// satu spring dipakai lintas transisi).
class M3Pressable extends StatefulWidget {
  const M3Pressable({
    super.key,
    required this.child,
    this.pressedScale = 0.96,
  });

  final Widget child;
  final double pressedScale;

  @override
  State<M3Pressable> createState() => _M3PressableState();
}

class _M3PressableState extends State<M3Pressable>
    with SingleTickerProviderStateMixin {
  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 210,
    damping: 22,
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown() {
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
    );
  }

  void _springBack() {
    _controller.animateWith(
      SpringSimulation(_spring, _controller.value, 0, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _pressDown(),
      onPointerUp: (_) => _springBack(),
      onPointerCancel: (_) => _springBack(),
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(_controller.value);
          final scale = 1 - (1 - widget.pressedScale) * t;
          return Transform.scale(scale: scale, child: child);
        },
      ),
    );
  }
}
