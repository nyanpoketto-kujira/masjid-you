import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/editor_empty_state.dart';
import '../../widgets/stepper_row.dart';

/// Editor gambar latar TV (ADR-031) — sejajar editor Gambar Khusus.
///
/// Gambar di sini menjadi latar penuh layar TV, tampil bergiliran
/// sebagai slideshow dengan crossfade. Urutan tampil = urutan daftar
/// (drag & drop); gambar non-aktif dilewati. Gambar ASLI selalu
/// tersimpan utuh di HP — kompresi hanya terjadi sesaat saat pengiriman
/// via Bluetooth bila opsi "tanpa kompresi" mati (lihat kartu opsi).
///
/// Bagian atas editor:
/// - Stepper interval slideshow (field config `backgroundSlideSeconds`,
///   ditulis ke [intervalController] — pola StepperRow Fase 2 yang sama
///   seperti durasi lain di Pengaturan; tersimpan lewat alur simpan
///   config yang sudah ada).
/// - Sakelar "Kirim tanpa kompresi" khusus jalur Bluetooth.
/// - Indikator progress determinate selama pengiriman Bluetooth
///   ter-chunk berjalan ([sendProgress] 0.0-1.0; `null` = diam).
class BackgroundImagesSubtab extends StatelessWidget {
  final List<BackgroundImage> images;
  final Function(String base64Image) onAddImage;
  final Function(String) onRemoveImage;
  final Function(String, bool) onToggleImage;

  /// Dipanggil saat urutan daftar diubah (drag & drop).
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Controller nilai interval slideshow (detik per gambar).
  final TextEditingController intervalController;

  /// Opsi kirim Bluetooth tanpa kompresi (kualitas asli, lebih lambat).
  final bool sendUncompressed;
  final ValueChanged<bool> onSendUncompressedChanged;

  /// Progress pengiriman Bluetooth ter-chunk (0.0-1.0), `null` bila
  /// tidak ada pengiriman berjalan.
  final double? sendProgress;

  const BackgroundImagesSubtab({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onToggleImage,
    this.onReorder,
    required this.intervalController,
    required this.sendUncompressed,
    required this.onSendUncompressedChanged,
    this.sendProgress,
  });

  void _openAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddBackgroundDialog(onAddImage: onAddImage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = sendProgress;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Gambar'),
      ),
      body: Column(
        children: [
          // Kartu opsi slideshow & pengiriman.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepperRow(
                      label: 'Interval Slideshow',
                      controller: intervalController,
                      min: MosqueConfig.minBackgroundSlideSeconds,
                      max: MosqueConfig.maxBackgroundSlideSeconds,
                      unit: 'dtk',
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Kirim tanpa kompresi'),
                      subtitle: Text(
                        'Khusus Bluetooth: gambar dikirim kualitas asli '
                        '(lebih lambat). Bila mati, gambar dikompresi dulu '
                        'agar cepat sampai. Jalur Wi-Fi selalu asli.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      value: sendUncompressed,
                      onChanged: onSendUncompressedChanged,
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(value: progress),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mengirim ${(progress * 100).round()}%',
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: images.isEmpty
                ? EditorEmptyState(
                    icon: Icons.wallpaper,
                    title: 'Belum ada gambar latar',
                    message: 'Tambahkan gambar untuk slideshow latar TV. '
                        'Kosong berarti TV memakai gambar bawaan.',
                    actionLabel: 'Tambah Gambar',
                    onAction: () => _openAddDialog(context),
                  )
                : ReorderableListView.builder(
                    key: const PageStorageKey('gambar_latar_list_view'),
                    padding: const EdgeInsets.all(16.0),
                    buildDefaultDragHandles: false,
                    itemCount: images.length,
                    onReorderItem: onReorder ?? (_, __) {},
                    itemBuilder: (context, index) {
                      final image = images[index];
                      return Card(
                        key: ValueKey(image.id),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(Icons.drag_handle),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text('Latar ${index + 1}'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: image.isActive,
                                    onChanged: (val) =>
                                        onToggleImage(image.id, val),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tampil sebagai latar TV bergiliran '
                                '(slideshow) sesuai interval di atas.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                              if (image.base64Image.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _BackgroundThumbnail(
                                    base64Image: image.base64Image),
                              ],
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => onRemoveImage(image.id),
                                    icon: Icon(Icons.delete,
                                        size: 18, color: colorScheme.error),
                                    label: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Form tambah gambar latar dalam dialog full-screen. Gambar dipilih
/// TANPA penurunan kualitas oleh picker — file asli tersimpan utuh di
/// HP; kompresi hanya terjadi saat pengiriman Bluetooth (ADR-031).
class _AddBackgroundDialog extends StatefulWidget {
  const _AddBackgroundDialog({required this.onAddImage});

  final Function(String base64Image) onAddImage;

  @override
  State<_AddBackgroundDialog> createState() => _AddBackgroundDialogState();
}

class _AddBackgroundDialogState extends State<_AddBackgroundDialog> {
  String? _selectedBase64Image;
  File? _imagePreviewFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // Tanpa maxWidth/maxHeight/imageQuality: pertahankan file asli.
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedBase64Image = base64Encode(bytes);
          _imagePreviewFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _clearImage() {
    setState(() {
      _selectedBase64Image = null;
      _imagePreviewFile = null;
    });
  }

  void _save() {
    final base64Image = _selectedBase64Image;
    if (base64Image == null) return;
    widget.onAddImage(base64Image);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Tambah Gambar Latar'),
          actions: [
            TextButton(
              onPressed: _selectedBase64Image == null ? null : _save,
              child: const Text('Simpan'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Gambar menjadi latar TV dan tampil bergiliran sebagai '
              'slideshow. File asli tersimpan utuh di HP.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imagePreviewFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _imagePreviewFile!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.6),
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: _clearImage,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wallpaper,
                                size: 40, color: colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih Gambar Latar',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Berjalan 100% Offline',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundThumbnail extends StatefulWidget {
  final String base64Image;

  const _BackgroundThumbnail({required this.base64Image});

  @override
  State<_BackgroundThumbnail> createState() => _BackgroundThumbnailState();
}

class _BackgroundThumbnailState extends State<_BackgroundThumbnail> {
  Uint8List? _cachedImageBytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant _BackgroundThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Image != widget.base64Image) {
      _decode();
    }
  }

  void _decode() {
    try {
      _cachedImageBytes = base64Decode(widget.base64Image);
    } catch (_) {
      _cachedImageBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bytes = _cachedImageBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        width: double.infinity,
        color: colorScheme.surfaceContainerLow,
        child: bytes == null
            ? const Center(child: Icon(Icons.broken_image))
            : Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                cacheWidth: 360,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
      ),
    );
  }
}
