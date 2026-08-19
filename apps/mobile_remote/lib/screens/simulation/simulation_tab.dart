import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/m3_pressable.dart';

class SimulationTab extends StatelessWidget {
  final bool isConnected;
  final PrayerPhase tvPhase;
  final Function(PrayerPhase) onSendForcePhase;

  const SimulationTab({
    super.key,
    required this.isConnected,
    required this.tvPhase,
    required this.onSendForcePhase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const regularPhases = [
      (PrayerPhase.normal, Icons.rocket_launch_outlined, 'Normal (Standby)'),
      (PrayerPhase.preAdhan, Icons.access_time_filled, 'PRE_ADHAN · Menjelang Azan'),
      (PrayerPhase.adhan, Icons.campaign, 'ADHAN · Azan Berkumandang'),
      (PrayerPhase.preIqomah, Icons.groups, 'PRE_IQOMAH · Jeda Ikamah'),
      (PrayerPhase.shalat, Icons.dark_mode, 'SHALAT · Shalat Berlangsung'),
    ];

    const fridayPhases = [
      (PrayerPhase.khutbah, Icons.menu_book_rounded, 'KHUTBAH · Khutbah Jumat'),
    ];

    Widget phaseButtons(List<(PrayerPhase, IconData, String)> phases) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: phases.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: M3Pressable(
                child: FilledButton.tonalIcon(
                  onPressed: isConnected
                      ? () => onSendForcePhase(entry.$1)
                      : null,
                  icon: Icon(entry.$2),
                  label: Text(entry.$3),
                ),
              ),
            ),
          ),
        ).toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            color: isConnected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Tes — Simulasi Waktu Shalat',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paksa TV masuk ke fase tertentu untuk menguji overlay, state machine, dan tombol aksi cepat.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.tv : Icons.tv_off,
                        size: 18,
                        color: isConnected ? Colors.green : colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isConnected
                              ? 'Mode TV saat ini: ${tvPhase.label}'
                              : 'Belum terhubung ke TV',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paksa Fase — Hari Biasa',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  phaseButtons(regularPhases),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paksa Fase — Hari Jumat',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  phaseButtons(fridayPhases),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Catatan: fase masuk dengan durasi penuh dari konfigurasi. '
            'Setelah selesai uji, tekan "Normal (Standby)" untuk kembali ke dashboard.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
