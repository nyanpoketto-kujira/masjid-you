import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

import '../theme/m3_shape_border.dart';

class HeaderClock extends StatelessWidget {
  final MosqueConfig config;
  final DateTime currentTime;

  /// Bytes gambar logo masjid (ADR-032), sudah di-decode dari base64
  /// oleh pemanggil. `null` = tidak ada logo: header tampil persis
  /// seperti sebelum fitur logo ada. Bila ada, logo tampil sebagai
  /// kotak **1:1** di kiri dan kolom nama/alamat bergeser ke kanan.
  final Uint8List? logoBytes;

  /// Ukuran sisi kotak logo (persegi 1:1), kurang lebih setinggi blok
  /// dua baris nama + alamat di sebelahnya.
  static const double logoSize = 76;

  const HeaderClock({
    super.key,
    required this.config,
    required this.currentTime,
    this.logoBytes,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo masjid (ADR-032): hanya bila DKM memasang logo.
            // Kotak 1:1 dengan fit cover (sumber non-persegi di-crop
            // simetris); tanpa logo, baris ini tidak menyumbang apa
            // pun dan tata letak nama/alamat persis seperti semula.
            if (logoBytes != null) ...[
              ClipRRect(
                key: const Key('header-logo'),
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  logoBytes!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: logoSize,
                    height: logoSize,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.mosque,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
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
