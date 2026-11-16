import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Kartu gambar khusus di slot samping TV: satu gambar tampil penuh
/// memenuhi kartu, dengan caption (bila ada) sebagai pita di bagian bawah.
///
/// Bingkai kartu dibuat serasi dengan kartu Kas / Petugas Jumat
/// (radius 28, border outline tipis) agar slot kanan tetap konsisten.
class SpecialImageCard extends StatelessWidget {
  final SpecialImage image;

  const SpecialImageCard({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Uint8List? bytes;
    if (image.base64Image.isNotEmpty) {
      try {
        bytes = base64Decode(image.base64Image);
      } catch (_) {
        bytes = null; // base64 rusak -> tampilkan fallback, jangan crash.
      }
    }

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bytes != null)
            Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallback(context),
            )
          else
            _buildFallback(context),
          if (image.caption.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.black.withValues(alpha: 0.55),
                child: Text(
                  image.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 64,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
