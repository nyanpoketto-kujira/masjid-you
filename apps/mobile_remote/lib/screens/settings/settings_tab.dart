import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/m3_pressable.dart';

class SettingsTab extends StatelessWidget {
  final MosqueConfig config;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final Map<PrayerType, TextEditingController> prayerOffsetControllers;
  final TextEditingController preAdhanController;
  final TextEditingController adhanController;
  final TextEditingController preIqomahController;
  final TextEditingController shalatController;
  final TextEditingController khutbahController;
  final TextEditingController fridayKhatibController;
  final TextEditingController fridayMuadzinController;
  final bool isFetchingLocation;
  final bool isConnected;
  final PrayerPhase tvPhase;
  final VoidRefCallback onFetchLocation;
  final VoidRefCallback onSaveConfig;
  final Function(SyncAction) onSendQuickAction;
  final Function(MosqueConfig) onShowSimulation;

  const SettingsTab({
    super.key,
    required this.config,
    required this.nameController,
    required this.addressController,
    required this.latitudeController,
    required this.longitudeController,
    required this.prayerOffsetControllers,
    required this.preAdhanController,
    required this.adhanController,
    required this.preIqomahController,
    required this.shalatController,
    required this.khutbahController,
    required this.fridayKhatibController,
    required this.fridayMuadzinController,
    required this.isFetchingLocation,
    required this.isConnected,
    required this.tvPhase,
    required this.onFetchLocation,
    required this.onSaveConfig,
    required this.onSendQuickAction,
    required this.onShowSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            'Identitas Masjid',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Masjid',
              prefixIcon: Icon(Icons.mosque),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Alamat Masjid',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Koordinat & Jadwal Sholat',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: M3Pressable(
              child: OutlinedButton.icon(
                onPressed: isFetchingLocation ? null : onFetchLocation,
                icon: isFetchingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Ambil Koordinat dari GPS'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Offset Jadwal Sholat (Menit)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: kAllPrayerTypes.map((type) {
              return TextFormField(
                controller: prayerOffsetControllers[type],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: type.displayNameForDate(DateTime.now()),
                  suffixText: 'mnt',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Durasi Siklus Waktu Shalat (Menit)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Sesuaikan durasi tampilan transisi layar TV.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: preAdhanController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Jelang Azan',
                    suffixText: 'm',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: adhanController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Azan',
                    suffixText: 'm',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: preIqomahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Jeda Ikamah',
                    suffixText: 'm',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: shalatController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Shalat',
                    suffixText: 'm',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Siklus Hari Jumat & Petugas',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: khutbahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Durasi Khutbah',
                    suffixText: 'm',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: fridayKhatibController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Khatib',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: fridayMuadzinController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Muadzin',
                    prefixIcon: Icon(Icons.campaign),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuickActionsCard(theme, colorScheme),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: M3Pressable(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final curr = MosqueConfig(
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        latitude: double.tryParse(latitudeController.text.trim()) ?? config.latitude,
                        longitude: double.tryParse(longitudeController.text.trim()) ?? config.longitude,
                        prayerOffsets: {
                          for (final type in kAllPrayerTypes)
                            type: int.tryParse(prayerOffsetControllers[type]!.text.trim()) ?? 0,
                        },
                      );
                      onShowSimulation(curr);
                    },
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('Simulasi Jadwal'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: M3Pressable(
                  child: FilledButton.icon(
                    onPressed: onSaveConfig,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan & Update'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(ThemeData theme, ColorScheme colorScheme) {
    final adhanActive = tvPhase == PrayerPhase.adhan;
    final iqomahActive = tvPhase == PrayerPhase.preIqomah || tvPhase == PrayerPhase.khutbah;
    final shalatActive = tvPhase == PrayerPhase.shalat;

    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Aksi Cepat Waktu Shalat',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Gunakan tombol di bawah ini untuk melewati fase TV saat ini.',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: M3Pressable(
                    child: FilledButton.tonal(
                      onPressed: isConnected && adhanActive
                          ? () => onSendQuickAction(SyncAction.skipAdhan)
                          : null,
                      child: const Text('Skip Azan'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: M3Pressable(
                    child: FilledButton.tonal(
                      onPressed: isConnected && iqomahActive
                          ? () => onSendQuickAction(SyncAction.startShalat)
                          : null,
                      child: const Text('Mulai Shalat'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: M3Pressable(
                    child: FilledButton.tonal(
                      onPressed: isConnected && shalatActive
                          ? () => onSendQuickAction(SyncAction.finishShalat)
                          : null,
                      child: const Text('Selesai Shalat'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

typedef VoidRefCallback = void Function();
