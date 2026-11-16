import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/editor_empty_state.dart';

/// Editor kartu gambar khusus slot samping TV (Fase 3, ADR-025).
///
/// Gambar di sini tampil penuh satu kartu di slot kanan TV, bergantian
/// dengan Kas dan Petugas Jumat:
/// `[Kas] -> [Petugas Jumat] -> [Gambar 1..n] -> ulang`.
/// Urutan tampil = urutan daftar ini (drag & drop), dan gambar yang
/// sakelarnya mati dilewati dari rotasi. Tambah lewat Extended FAB yang
/// membuka form dalam dialog full-screen; hapus rutin diurungkan lewat
/// SnackBar (ditangani pemanggil).
class SpecialImagesSubtab extends StatelessWidget {
  final List<SpecialImage> images;
  final Function(String caption, String base64Image) onAddImage;
  final Function(String) onRemoveImage;
  final Function(String, bool) onToggleImage;

  /// Dipanggil saat urutan daftar diubah (drag & drop).
  final void Function(int oldIndex, int newIndex)? onReorder;

  const SpecialImagesSubtab({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onToggleImage,
    this.onReorder,
  });

  void _openAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddImageDialog(onAddImage: onAddImage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Gambar'),
      ),
      body: images.isEmpty
          ? EditorEmptyState(
              icon: Icons.photo_library,
              title: 'Belum ada gambar khusus',
              message: 'Tambahkan gambar untuk tampil penuh di kartu '
                  'samping TV.',
              actionLabel: 'Tambah Gambar',
              onAction: () => _openAddDialog(context),
            )
          : ReorderableListView.builder(
              key: const PageStorageKey('gambar_khusus_list_view'),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  label: Text('Gambar ${index + 1}'),
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
                          'Gambar tampil penuh di kartu samping TV, '
                          'bergantian dengan Kas dan Petugas Jumat.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                        if (image.base64Image.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _SpecialImageThumbnail(
                              base64Image: image.base64Image),
                        ],
                        if (image.caption.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            image.caption,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => onRemoveImage(image.id),
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
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
    );
  }
}

/// Form tambah gambar khusus dalam dialog full-screen: pilih gambar +
/// keterangan (opsional) + tombol Simpan eksplisit di AppBar (non-aktif
/// sebelum gambar dipilih). Status gambar & caption hidup di dialog ini.
class _AddImageDialog extends StatefulWidget {
  const _AddImageDialog({required this.onAddImage});

  final Function(String caption, String base64Image) onAddImage;

  @override
  State<_AddImageDialog> createState() => _AddImageDialogState();
}

class _AddImageDialogState extends State<_AddImageDialog> {
  final _captionController = TextEditingController();
  String? _selectedBase64Image;
  File? _imagePreviewFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
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
    widget.onAddImage(_captionController.text.trim(), base64Image);
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
          title: const Text('Tambah Gambar Khusus'),
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
              'Gambar tampil penuh di kartu samping TV, bergantian dengan '
              'Kas dan Petugas Jumat.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 160,
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
                            Icon(Icons.image,
                                size: 40, color: colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih Gambar (Maks 1080p)',
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Keterangan Gambar (opsional)',
                hintText: 'Misal: Pembangunan Ruang Belajar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialImageThumbnail extends StatefulWidget {
  final String base64Image;

  const _SpecialImageThumbnail({required this.base64Image});

  @override
  State<_SpecialImageThumbnail> createState() => _SpecialImageThumbnailState();
}

class _SpecialImageThumbnailState extends State<_SpecialImageThumbnail> {
  Uint8List? _cachedImageBytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant _SpecialImageThumbnail oldWidget) {
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
