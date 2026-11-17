import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

import '../../widgets/kas_stat_card.dart';

/// Label bahasa Indonesia untuk fase siklus shalat TV.
String tvPhaseLabel(PrayerPhase phase) => switch (phase) {
      PrayerPhase.normal => 'Normal',
      PrayerPhase.preAdhan => 'Jelang Azan',
      PrayerPhase.adhan => 'Azan Berlangsung',
      PrayerPhase.khutbah => 'Khutbah Jumat',
      PrayerPhase.preIqomah => 'Jeda Ikamah',
      PrayerPhase.shalat => 'Shalat Berlangsung',
    };

const List<String> _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// "Senin, 16 November 2026" — format manual agar deterministik di test
/// (tanpa inisialisasi locale intl).
String formatTanggalId(DateTime date) =>
    '${_namaHari[date.weekday - 1]}, ${date.day} ${_namaBulan[date.month - 1]} ${date.year}';

String _dua(int n) => n.toString().padLeft(2, '0');

/// "21:04:05".
String formatJam(DateTime time) =>
    '${_dua(time.hour)}:${_dua(time.minute)}:${_dua(time.second)}';

/// "01:23:45" (negatif ditahan di nol).
String formatHitungMundur(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  return '${_dua(d.inHours)}:${_dua(d.inMinutes % 60)}:${_dua(d.inSeconds % 60)}';
}

/// Sholat berikutnya menurut jadwal [config] dihitung dari [now]
/// (termasuk Subuh besok bila semua waktu hari ini sudah lewat).
({PrayerType type, DateTime time})? nextPrayerInfo(
  MosqueConfig config,
  DateTime now,
) {
  final schedule = PrayerSchedule.calculate(config, now);
  final next = schedule.nextPrayer;
  final until = schedule.timeUntilNextPrayer;
  if (next == null || until == null) return null;
  return (type: next, time: now.add(until));
}

/// Beranda Remote (Fase 1 refaktor UI, keputusan D5): status TV & jam
/// aktif, hitung mundur sholat berikutnya, Aksi Cepat 56dp
/// (Senyap, Standby, Sinkron), dan ringkasan saldo kas.
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.mosqueName,
    required this.transportLabel,
    required this.tvPhase,
    required this.tvMuted,
    required this.tvStandby,
    required this.config,
    required this.totalKasMasuk,
    required this.totalKasKeluar,
    required this.onToggleMuted,
    required this.onToggleStandby,
    required this.onSyncNow,
  });

  final String mosqueName;
  final String transportLabel;
  final PrayerPhase tvPhase;
  final bool tvMuted;
  final bool tvStandby;
  final MosqueConfig config;
  final int totalKasMasuk;
  final int totalKasKeluar;
  final VoidCallback onToggleMuted;
  final VoidCallback onToggleStandby;
  final VoidCallback onSyncNow;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late DateTime _now;
  Timer? _ticker;
  ({PrayerType type, DateTime time})? _nextPrayer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _nextPrayer = nextPrayerInfo(widget.config, _now);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        if (_nextPrayer == null || !_now.isBefore(_nextPrayer!.time)) {
          _nextPrayer = nextPrayerInfo(widget.config, _now);
        }
      });
    });
  }

  @override
  void didUpdateWidget(HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _nextPrayer = nextPrayerInfo(widget.config, _now);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final moneyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final next = _nextPrayer;
    final saldo = widget.totalKasMasuk - widget.totalKasKeluar;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status TV.
        Card(
          color: colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.tv,
                  size: 40,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tvStandby ? 'TV Standby' : 'TV Terhubung',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'via ${widget.transportLabel} • '
                        'Fase: ${tvPhaseLabel(widget.tvPhase)}'
                        '${widget.tvMuted ? ' • Senyap' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Jam aktif + hitung mundur sholat berikutnya.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mosqueName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatJam(_now),
                  style: theme.textTheme.displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  formatTanggalId(_now),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Divider(height: 32),
                Text(
                  'Sholat Berikutnya',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                if (next == null)
                  Text(
                    'Jadwal tidak tersedia',
                    style: theme.textTheme.titleLarge,
                  )
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          next.type.displayNameForDate(
                            next.time,
                            hasFridayPrayer: widget.config.hasFridayPrayer,
                          ),
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'pukul ${next.time.hour.toString().padLeft(2, '0')}:'
                          '${next.time.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mulai dalam ${formatHitungMundur(next.time.difference(_now))}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Aksi Cepat 56dp.
        Text(
          'Aksi Cepat',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: widget.tvMuted
                    ? FilledButton.tonalIcon(
                        onPressed: widget.onToggleMuted,
                        icon: const Icon(Icons.volume_off),
                        label: const Text('Senyap'),
                      )
                    : OutlinedButton.icon(
                        onPressed: widget.onToggleMuted,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Senyap'),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: widget.tvStandby
                    ? FilledButton.tonalIcon(
                        onPressed: widget.onToggleStandby,
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Standby'),
                      )
                    : OutlinedButton.icon(
                        onPressed: widget.onToggleStandby,
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Standby'),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: widget.onSyncNow,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sinkron'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Ringkasan kas.
        Text(
          'Ringkasan Kas',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        KasStatCard(
          title: 'SALDO KAS',
          amount: moneyFormat.format(saldo),
          icon: Icons.account_balance_wallet,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: KasStatCard(
                title: 'PEMASUKAN',
                amount: moneyFormat.format(widget.totalKasMasuk),
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KasStatCard(
                title: 'PENGELUARAN',
                amount: moneyFormat.format(widget.totalKasKeluar),
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
