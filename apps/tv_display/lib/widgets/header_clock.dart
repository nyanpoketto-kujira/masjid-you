import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

class HeaderClock extends StatelessWidget {
  final MosqueConfig config;
  final DateTime currentTime;
  final String? serverIp;
  final bool p2pActive;
  final String? p2pSsid;
  final String? p2pIp;

  const HeaderClock({
    super.key,
    required this.config,
    required this.currentTime,
    this.serverIp,
    this.p2pActive = false,
    this.p2pSsid,
    this.p2pIp,
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

    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  if (p2pSsid != null) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          onPressed: () {}, // Display only chip
                          label: Text(
                            p2pActive
                                ? 'Mode Direct: $p2pSsid (${p2pIp ?? '-'})'
                                : 'Mode Direct: menyiapkan...',
                          ),
                          avatar: Icon(
                            p2pActive ? Icons.wifi_tethering : Icons.sync,
                            size: 16,
                            color: p2pActive ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: ShapeDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: const StadiumBorder(),
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
