import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import '../../theme/theme_preferences.dart';
import '../../widgets/stepper_row.dart';

/// Tab Pengaturan (Fase 2 refaktor UI, ADR-024): form dikelompokkan dalam
/// grup bertajuk ala pola settings M3; offset & durasi memakai baris
/// stepper (− nilai +) yang tetap menulis ke [TextEditingController] yang
/// sama (alur simpan tidak berubah); tombol simpan menjadi sticky bottom
/// bar yang hanya aktif saat ada perubahan ([isDirty]).
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

  /// Toggle tampil/tidaknya kartu Kas di slot samping TV.
  final bool showKas;

  /// Toggle ada/tidaknya shalat Jumat (dimatikan untuk musholla).
  final bool hasFridayPrayer;
  final ValueChanged<bool> onShowKasChanged;
  final ValueChanged<bool> onHasFridayPrayerChanged;
  final bool isFetchingLocation;
  final bool isConnected;
  final PrayerPhase tvPhase;
  final VoidRefCallback onFetchLocation;
  final VoidRefCallback onSaveConfig;
  final Function(SyncAction) onSendQuickAction;
  final Function(MosqueConfig) onShowSimulation;
  final VoidRefCallback onExportBackup;
  final VoidRefCallback onImportBackup;

  /// Preferensi tampilan aplikasi (mode tema + sumber warna).
  final ThemeMode themeMode;
  final AppColorSource colorSource;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<AppColorSource>? onColorSourceChanged;

  /// Ada perubahan config yang belum disimpan (dilacak di
  /// `_RemoteHomeScreenState` lewat listener semua controller config).
  /// Tombol "Simpan & Update Ke TV" di sticky bottom bar hanya aktif
  /// bila `true`.
  final bool isDirty;

  /// Logo masjid (ADR-032): bytes gambar untuk pratinjau 1:1 di grup
  /// Masjid (`null` = belum ada logo). Logo berlaku seketika lewat
  /// aksi sync-nya sendiri — bukan bagian dari alur dirty/simpan
  /// config — sama seperti editor konten.
  final Uint8List? logoBytes;

  /// Progress pengiriman logo via Bluetooth (0.0-1.0); `null` = tidak
  /// ada pengiriman berjalan.
  final double? logoSendProgress;
  final VoidRefCallback? onPickLogo;
  final VoidRefCallback? onRemoveLogo;

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
    required this.showKas,
    required this.hasFridayPrayer,
    required this.onShowKasChanged,
    required this.onHasFridayPrayerChanged,
    required this.isFetchingLocation,
    required this.isConnected,
    required this.tvPhase,
    required this.onFetchLocation,
    required this.onSaveConfig,
    required this.onSendQuickAction,
    required this.onShowSimulation,
    required this.onExportBackup,
    required this.onImportBackup,
    this.themeMode = ThemeMode.system,
    this.colorSource = AppColorSource.dynamic,
    this.onThemeModeChanged,
    this.onColorSourceChanged,
    this.isDirty = false,
    this.logoBytes,
    this.logoSendProgress,
    this.onPickLogo,
    this.onRemoveLogo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _SettingsGroup(
                title: 'Masjid',
                footer: 'Nama dan alamat masjid yang tampil di layar TV.',
                children: [
                  // Logo masjid (ADR-032): pratinjau 1:1 persis seperti
                  // tampilnya di header TV. Berlaku seketika saat
                  // dipilih/dihapus (aksi sync sendiri), tidak menunggu
                  // tombol Simpan config.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        key: const Key('settings-logo-preview'),
                        borderRadius: BorderRadius.circular(12),
                        child: logoBytes != null
                            ? Image.memory(
                                logoBytes!,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 72,
                                  height: 72,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(Icons.mosque,
                                      color: colorScheme.primary),
                                ),
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logo Masjid',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              logoBytes != null
                                  ? 'Tampil persegi (1:1) di kiri nama masjid '
                                      'pada header TV.'
                                  : 'Belum ada logo. Header TV tampil seperti '
                                      'biasa, tanpa logo.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: onPickLogo,
                                  icon: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 18),
                                  label: Text(logoBytes != null
                                      ? 'Ganti Logo'
                                      : 'Pilih Logo'),
                                ),
                                if (logoBytes != null)
                                  TextButton.icon(
                                    onPressed: onRemoveLogo,
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18),
                                    label: const Text('Hapus'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorScheme.error,
                                    ),
                                  ),
                              ],
                            ),
                            if (logoSendProgress != null) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: logoSendProgress,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mengirim logo '
                                '${(logoSendProgress! * 100).round()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
              _SettingsGroup(
                title: 'Lokasi & Jadwal',
                footer: 'Jadwal dihitung untuk lokasi ini.',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Latitude'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Longitude'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          isFetchingLocation ? null : onFetchLocation,
                      icon: isFetchingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: const Text('Ambil Koordinat dari GPS'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final curr = MosqueConfig(
                          name: nameController.text.trim(),
                          address: addressController.text.trim(),
                          latitude: double.tryParse(
                                  latitudeController.text.trim()) ??
                              config.latitude,
                          longitude: double.tryParse(
                                  longitudeController.text.trim()) ??
                              config.longitude,
                          prayerOffsets: {
                            for (final type in kAllPrayerTypes)
                              type: int.tryParse(
                                      prayerOffsetControllers[type]!
                                          .text
                                          .trim()) ??
                                  0,
                          },
                          showKas: showKas,
                          hasFridayPrayer: hasFridayPrayer,
                        );
                        onShowSimulation(curr);
                      },
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('Simulasi Jadwal'),
                    ),
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'Penyesuaian Waktu',
                footer:
                    'Geser nilai untuk menggeser jadwal sholat (dalam menit).',
                children: [
                  for (final type in kAllPrayerTypes)
                    StepperRow(
                      label: type.displayNameForDate(
                        DateTime.now(),
                        hasFridayPrayer: hasFridayPrayer,
                      ),
                      controller: prayerOffsetControllers[type]!,
                      min: -60,
                      max: 60,
                    ),
                ],
              ),
              _SettingsGroup(
                title: 'Durasi Tampilan TV',
                footer: 'Sesuaikan durasi tampilan transisi layar TV.',
                children: [
                  StepperRow(
                    label: 'Jelang Azan',
                    controller: preAdhanController,
                    unit: 'm',
                  ),
                  StepperRow(
                    label: 'Azan',
                    controller: adhanController,
                    unit: 'm',
                  ),
                  StepperRow(
                    label: 'Jeda Ikamah',
                    controller: preIqomahController,
                    unit: 'm',
                  ),
                  StepperRow(
                    label: 'Shalat',
                    controller: shalatController,
                    unit: 'm',
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'Tampilan TV',
                footer:
                    'Kartu samping bergantian tampil: Kas -> Petugas Jumat -> Gambar Khusus.',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tampilkan Kas Masjid'),
                    subtitle: const Text(
                        'Matikan bila kartu kas tidak perlu tampil di TV'),
                    value: showKas,
                    onChanged: onShowKasChanged,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ada Shalat Jumat (Jumatan)'),
                    subtitle: const Text(
                      'Matikan untuk musholla: kartu Petugas Jumat, label "Jumat", '
                      'dan fase khutbah tidak ditampilkan',
                    ),
                    value: hasFridayPrayer,
                    onChanged: onHasFridayPrayerChanged,
                  ),
                  const SizedBox(height: 4),
                  StepperRow(
                    label: 'Durasi Khutbah',
                    controller: khutbahController,
                    enabled: hasFridayPrayer,
                    unit: 'm',
                    max: 120,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fridayKhatibController,
                    enabled: hasFridayPrayer,
                    decoration: const InputDecoration(
                      labelText: 'Nama Khatib',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fridayMuadzinController,
                    enabled: hasFridayPrayer,
                    decoration: const InputDecoration(
                      labelText: 'Nama Muadzin',
                      prefixIcon: Icon(Icons.campaign),
                    ),
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'Aksi Cepat Waktu Shalat',
                footer:
                    'Gunakan tombol di bawah ini untuk melewati fase TV saat ini.',
                children: [
                  _buildQuickActionsCard(theme, colorScheme),
                ],
              ),
              _SettingsGroup(
                title: 'Tampilan Aplikasi',
                footer: 'Tema dan warna aplikasi remote di HP ini.',
                children: [
                  Text(
                    'Tema',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Sistem'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Terang'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Gelap'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: onThemeModeChanged == null
                        ? null
                        : (selection) =>
                            onThemeModeChanged!(selection.first),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Warna',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<AppColorSource>(
                    segments: const [
                      ButtonSegment(
                        value: AppColorSource.dynamic,
                        icon: Icon(Icons.wallpaper),
                        label: Text('Ikuti Wallpaper'),
                      ),
                      ButtonSegment(
                        value: AppColorSource.seed,
                        icon: Icon(Icons.mosque),
                        label: Text('Hijau Masjid'),
                      ),
                    ],
                    selected: {colorSource},
                    onSelectionChanged: onColorSourceChanged == null
                        ? null
                        : (selection) =>
                            onColorSourceChanged!(selection.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ikuti Wallpaper hanya tersedia di Android 12 ke atas; '
                    'di perangkat lain otomatis memakai Hijau Masjid.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              _SettingsGroup(
                title: 'Data',
                footer:
                    'Simpan salinan seluruh data masjid atau pulihkan dari file backup.',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onExportBackup,
                          icon: const Icon(Icons.backup_outlined),
                          label: const Text('Export Backup'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onImportBackup,
                          icon: const Icon(Icons.restore),
                          label: const Text('Import Backup'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildStickySaveBar(theme, colorScheme),
      ],
    );
  }

  /// Bilah simpan yang selalu menempel di bawah tab Pengaturan; tombol
  /// hanya aktif bila ada perubahan config yang belum disimpan.
  Widget _buildStickySaveBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDirty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ada perubahan belum disimpan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              FilledButton.icon(
                onPressed: isDirty ? onSaveConfig : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Simpan & Update Ke TV'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(ThemeData theme, ColorScheme colorScheme) {
    final adhanActive = tvPhase == PrayerPhase.adhan;
    final iqomahActive =
        tvPhase == PrayerPhase.preIqomah || tvPhase == PrayerPhase.khutbah;
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
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isConnected && adhanActive
                        ? () => onSendQuickAction(SyncAction.skipAdhan)
                        : null,
                    child: const Text('Skip Azan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isConnected && iqomahActive
                        ? () => onSendQuickAction(SyncAction.startShalat)
                        : null,
                    child: const Text('Mulai Shalat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isConnected && shalatActive
                        ? () => onSendQuickAction(SyncAction.finishShalat)
                        : null,
                    child: const Text('Selesai Shalat'),
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

/// Satu grup bertajuk di tab Pengaturan: judul + isi + catatan kaki satu
/// kalimat, mengikuti pola settings M3.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
        if (footer != null) ...[
          const SizedBox(height: 8),
          Text(
            footer!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

typedef VoidRefCallback = void Function();
