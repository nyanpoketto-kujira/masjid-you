import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Indeks slideshow berikutnya: maju satu, kembali ke awal setelah
/// gambar terakhir (wrap-around). Aman untuk daftar kosong / satu
/// gambar — selalu 0, tidak pernah di luar rentang.
int nextSlideshowIndex(int current, int count) {
  if (count <= 1) return 0;
  final safeCurrent = current < 0 ? 0 : current;
  return (safeCurrent + 1) % count;
}

/// Latar TV sebagai slideshow gambar dari Remote (ADR-031).
///
/// Menampilkan gambar aktif ([BackgroundImage.isActive]) bergiliran
/// setiap [intervalSeconds] detik dengan crossfade halus. Daftar kosong
/// (atau semua non-aktif) -> [fallback] ditampilkan (gambar bawaan
/// `bg_mosque.jpg` dari pemanggil). Satu gambar -> statis, tanpa timer.
///
/// Overlay gelap penunjang keterbacaan BUKAN bagian widget ini — ia
/// tetap lapisan terpisah di layar utama agar urutan tumpukan sama
/// untuk slideshow maupun fallback.
class BackgroundSlideshow extends StatefulWidget {
  final List<BackgroundImage> images;
  final int intervalSeconds;

  /// Widget yang ditampilkan bila tidak ada gambar aktif (dan sebagai
  /// pengganti per gambar yang bytes-nya rusak).
  final Widget fallback;

  const BackgroundSlideshow({
    super.key,
    required this.images,
    required this.intervalSeconds,
    required this.fallback,
  });

  @override
  State<BackgroundSlideshow> createState() => _BackgroundSlideshowState();
}

class _BackgroundSlideshowState extends State<BackgroundSlideshow> {
  int _index = 0;
  Timer? _timer;

  /// Cache bytes ter-decode per id gambar (decode base64 berulang tiap
  /// rebuild itu mahal untuk gambar besar).
  final Map<String, Uint8List?> _bytesCache = {};

  List<BackgroundImage> get _activeImages => [
        for (final image in widget.images)
          if (image.isActive) image
      ];

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant BackgroundSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Daftar menyusut: jaga indeks tetap di dalam rentang.
    final count = _activeImages.length;
    if (_index >= count) _index = 0;
    if (oldWidget.intervalSeconds != widget.intervalSeconds ||
        oldWidget.images != widget.images) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (_activeImages.length <= 1) return;
    final seconds = widget.intervalSeconds <= 0 ? 30 : widget.intervalSeconds;
    _timer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (!mounted) return;
      setState(() {
        _index = nextSlideshowIndex(_index, _activeImages.length);
      });
    });
  }

  Uint8List? _bytesFor(BackgroundImage image) {
    if (_bytesCache.containsKey(image.id)) return _bytesCache[image.id];
    Uint8List? bytes;
    try {
      bytes =
          image.base64Image.isEmpty ? null : base64Decode(image.base64Image);
    } catch (_) {
      bytes = null;
    }
    _bytesCache[image.id] = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeImages;
    if (active.isEmpty) return widget.fallback;
    final image = active[_index % active.length];
    final bytes = _bytesFor(image);
    if (bytes == null) return widget.fallback;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        children: [...previousChildren, if (currentChild != null) currentChild],
      ),
      child: Image.memory(
        bytes,
        key: ValueKey('bg-${image.id}'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => widget.fallback,
      ),
    );
  }
}
