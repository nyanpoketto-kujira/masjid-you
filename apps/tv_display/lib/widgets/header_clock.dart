import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

import '../theme/m3_shape_border.dart';

class HeaderClock extends StatelessWidget {
  final MosqueConfig config;
  final DateTime currentTime;

  /// Mode Direct (WiFi Direct) aktif — hotspot benar-benar menyala.
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

  const HeaderClock({
    super.key,
    required this.config,
    required this.currentTime,
    this.p2pActive = false,
    this.p2pError = false,
    this.p2pSsid,
    this.p2pIp,
    this.p2pStatus,
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

    // Chip P2P (WiFi Direct) tampil SAAT hotspot benar-benar aktif.
    late String p2pChipLabel;
    if (p2pActive && p2pSsid != null) {
      p2pChipLabel = 'Mode Direct: $p2pSsid (${p2pIp ?? '-'})';
    } else {
      p2pChipLabel = p2pStatus ?? 'Mode Direct: menyiapkan...';
    }
    final p2pChipColor = p2pActive
        ? colorScheme.tertiary
        : (p2pError ? colorScheme.error : colorScheme.onSurfaceVariant);

    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 18,
                    ),
                  ),
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
              padding: const EdgeInsets.only(top: 16, bottom: 10, left: 28, right: 28),
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
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(currentTime),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
