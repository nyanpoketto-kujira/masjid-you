import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

import '../theme/m3_shape_border.dart';

class HeaderClock extends StatelessWidget {
  final MosqueConfig config;
  final DateTime currentTime;
  final String? serverIp;
  final bool p2pActive;

  /// True bila Mode Direct gagal/nonaktif (P2pMode.directIpOnly) ->
  /// chip tampil sebagai peringatan berwarna error.
  final bool p2pError;
  final String? p2pSsid;
  final String? p2pIp;

  /// Teks status Mode Direct saat hotspot belum aktif (menyiapkan/gagal).
  /// Chip P2P tampil bila [p2pSsid] ATAU [p2pStatus] tidak null — sehingga
  /// kegagalan/mode IP Saja tetap terlihat di TV, bukan hilang diam-diam.
  final String? p2pStatus;

  /// Status Mode Bluetooth (jalur sync langsung utama).
  final bool btActive;
  final bool btError;
  final String? btStatus;

  /// Callback dipanggil saat chip Bluetooth diketuk dalam keadaan error
  /// untuk memulai ulang host Bluetooth di TV.
  final VoidCallback? onBtRestart;

  const HeaderClock({
    super.key,
    required this.config,
    required this.currentTime,
    this.serverIp,
    this.p2pActive = false,
    this.p2pError = false,
    this.p2pSsid,
    this.p2pIp,
    this.p2pStatus,
    this.btActive = false,
    this.btError = false,
    this.btStatus,
    this.onBtRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final timeFormat = DateFormat('HH:mm:ss');
    late final DateFormat dateFormat;
    try {
      dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    } catch (_) {
      dateFormat = DateFormat('EEEE, d MMMM yyyy');
    }

    // Chip P2P (WiFi Direct) tampil SAHA saat hotspot benar-benar aktif.
    // Chip Bluetooth menjadi indikator utama mode sync langsung.
    late String p2pChipLabel;
    if (p2pActive && p2pSsid != null) {
      p2pChipLabel = 'Mode Direct: $p2pSsid (${p2pIp ?? '-'})';
    } else {
      p2pChipLabel = p2pStatus ??
          'Mode Direct: menyiapkan...';
    }
    final p2pChipColor = p2pActive
        ? colorScheme.tertiary
        : (p2pError ? colorScheme.error : colorScheme.onSurfaceVariant);

    final btChipVisible = btActive || btStatus != null;
    final btChipLabel = btActive
        ? (btStatus ?? 'Mode Bluetooth: aktif')
        : (btStatus ?? 'Mode Bluetooth: menyiapkan...');
    final btChipColor = btActive
        ? colorScheme.tertiary
        : (btError ? colorScheme.error : colorScheme.onSurfaceVariant);

    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Mosque Name & Address (flexible, ellipsize if narrow)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (serverIp != null) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          onPressed: () {}, // Display only chip
                          label: Text('Remote Sync IP: $serverIp:8080'),
                          avatar: Icon(Icons.wifi, size: 16, color: colorScheme.primary),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                  if (btChipVisible) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          onPressed: btError ? () => onBtRestart?.call() : null,
                          tooltip: btError ? 'Ketuk untuk ulang Bluetooth' : null,
                          label: Text(btChipLabel),
                          avatar: Icon(
                            btActive
                                ? Icons.bluetooth_connected
                                : (btError
                                    ? Icons.bluetooth_disabled
                                    : Icons.bluetooth_searching),
                            size: 16,
                            color: btChipColor,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                  if (p2pActive && p2pSsid != null) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          onPressed: () {}, // Display only chip
                          label: Text(p2pChipLabel),
                          avatar: Icon(
                            Icons.wifi_tethering,
                            size: 16,
                            color: p2pChipColor,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 16),
  
            // Right: Real-time Large Clock & Date in Capsule/Pill Shape
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 12, left: 28, right: 28),
              decoration: ShapeDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: const ArchBorder(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeFormat.format(currentTime),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      height: 1.0,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(currentTime),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
