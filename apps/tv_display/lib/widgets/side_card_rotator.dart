import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../state/side_card_playlist.dart';
import 'friday_staff_card.dart';
import 'kas_summary_card.dart';
import 'special_image_card.dart';

/// Rotator kartu slot samping (kanan) TV.
///
/// Menampilkan playlist dari [buildSideCardPlaylist] secara bergiliran:
/// `[Kas] -> [Petugas Jumat] -> [Gambar 1] -> ... -> [Gambar ke-n] -> ulang`,
/// tiap kartu selama [interval] (default 10 detik, sama seperti pergantian
/// Kas/Petugas Jumat sebelumnya dan carousel banner).
///
/// - Playlist berisi 1 kartu: tampil statis, timer tidak berjalan.
/// - Playlist kosong: tampil kartu placeholder agar layout tidak jebol.
/// - Playlist berubah di tengah jalan (toggle diubah, hari berganti, daftar
///   gambar berubah): indeks dijaga tetap valid dan timer dimulai ulang.
class SideCardRotator extends StatefulWidget {
  final MosqueConfig config;
  final List<KasTransaction> transactions;
  final List<SpecialImage> images;

  /// Tanggal acuan susunan playlist (kartu Jumat hanya di hari Jumat).
  final DateTime date;

  /// Durasi tampil tiap kartu.
  final Duration interval;

  const SideCardRotator({
    super.key,
    required this.config,
    required this.transactions,
    required this.images,
    required this.date,
    this.interval = const Duration(seconds: 10),
  });

  @override
  State<SideCardRotator> createState() => _SideCardRotatorState();
}

class _SideCardRotatorState extends State<SideCardRotator> {
  Timer? _timer;
  int _currentIndex = 0;

  List<SideCardItem> get _playlist => buildSideCardPlaylist(
        config: widget.config,
        date: widget.date,
        images: widget.images,
      );

  /// Tanda tangan playlist (urutan kunci kartu) untuk mendeteksi perubahan
  /// susunan tanpa membandingkan isi gambar yang besar.
  String get _signature => _playlist.map((item) => item.key).join('|');

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(SideCardRotator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSignature = buildSideCardPlaylist(
      config: oldWidget.config,
      date: oldWidget.date,
      images: oldWidget.images,
    ).map((item) => item.key).join('|');
    if (oldSignature != _signature) {
      // Susunan berubah: jaga indeks tetap valid, mulai hitungan dari awal
      // supaya kartu yang sedang tampil mendapat durasi penuh.
      if (_currentIndex >= _playlist.length) {
        _currentIndex = 0;
      }
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_playlist.length <= 1) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _playlist.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _playlist;
    if (playlist.isEmpty) {
      return const _SidePlaceholderCard(key: ValueKey('side-placeholder'));
    }
    final index = _currentIndex < playlist.length ? _currentIndex : 0;
    final item = playlist[index];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildCard(item),
    );
  }

  Widget _buildCard(SideCardItem item) {
    return switch (item.kind) {
      SideCardKind.kas => KasSummaryCard(
          key: ValueKey(item.key),
          transactions: widget.transactions,
        ),
      SideCardKind.fridayStaff => FridayStaffCard(
          key: ValueKey(item.key),
          khatib: widget.config.fridayKhatib,
          muadzin: widget.config.fridayMuadzin,
        ),
      SideCardKind.specialImage => SpecialImageCard(
          key: ValueKey(item.key),
          image: item.image!,
        ),
    };
  }
}

/// Kartu cadangan saat playlist rotasi kosong (kas dimatikan, bukan hari
/// Jumat / Jumatan mati, dan tidak ada gambar khusus aktif).
class _SidePlaceholderCard extends StatelessWidget {
  const _SidePlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mosque_rounded,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.65),
              ),
              const SizedBox(height: 12),
              Text(
                'Jagalah Shaf dan Shalatlah Tepat Waktu',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
