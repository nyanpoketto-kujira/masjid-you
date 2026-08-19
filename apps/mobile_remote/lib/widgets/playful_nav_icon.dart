import 'package:flutter/material.dart';

/// Ikon navigasi dengan mikro-animasi saat dipilih: lompatan vertikal,
/// efek membal (elastic bounce), dan putaran opsional (mis. ikon Settings).
class PlayfulNavIcon extends StatefulWidget {
  final IconData unselectedIcon;
  final IconData selectedIcon;
  final bool isSelected;
  final bool shouldRotate;

  const PlayfulNavIcon({
    super.key,
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.isSelected,
    this.shouldRotate = false,
  });

  @override
  State<PlayfulNavIcon> createState() => _PlayfulNavIconState();
}

class _PlayfulNavIconState extends State<PlayfulNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Offset> _jump;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _jump = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.18))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, -0.18), end: Offset.zero)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    // Gear 8 gigi simetris tiap 45° -> putaran 360° & posisi 45° tak terlihat.
    // Ayun lewat sudut tak-simetris (135°) agar gerakan jelas, lalu mendarat
    // di 22.5° (separuh pitch) supaya miring saat terpilih benar-benar terlihat.
    _rotate = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.375) // ayun lambat ke 135°
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.375, end: 0.0625) // balik, mendarat di 22.5°
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
    ]).animate(_controller);

    if (widget.isSelected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(PlayfulNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected == oldWidget.isSelected) return;
    if (widget.isSelected) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(
      widget.isSelected ? widget.selectedIcon : widget.unselectedIcon,
    );
    if (widget.shouldRotate) {
      icon = RotationTransition(turns: _rotate, child: icon);
    }
    return SlideTransition(
      position: _jump,
      child: ScaleTransition(scale: _scale, child: icon),
    );
  }
}
