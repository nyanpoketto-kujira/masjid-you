import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_models/shared_models.dart';

/// Editor kartu gambar khusus slot samping TV.
///
/// Gambar di sini tampil penuh satu kartu di slot kanan TV, bergantian
/// dengan Kas dan Petugas Jumat:
/// `[Kas] -> [Petugas Jumat] -> [Gambar 1..n] -> ulang`.
/// Urutan tampil = urutan daftar ini (tombol naik/turun), dan gambar yang
/// sakelarnya mati dilewati dari rotasi.
class SpecialImagesSubtab extends StatefulWidget {
  final List<SpecialImage> images;
  final Function(String caption, String base64Image) onAddImage;
  final Function(String) onRemoveImage;
  final Function(String, bool) onToggleImage;

  /// Geser urutan gambar: [delta] -1 = naik, +1 = turun.
  final Function(String, int) onMoveImage;

  const SpecialImagesSubtab({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onToggleImage,
    required this.onMoveImage,
  });

  @override
  State<SpecialImagesSubtab> createState() => _SpecialImagesSubtabState();
}

class _SpecialImagesSubtabState extends State<SpecialImagesSubtab> {
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

  void _submit() {
    final base64Image = _selectedBase64Image;
    if (base64Image == null) return;
    widget.onAddImage(_captionController.text.trim(), base64Image);
    _captionController.clear();
    _clearImage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        key: const PageStorageKey('gambar_khusus_list_view'),
        children: [
          Text(
            'Tambah Gambar Khusus',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Gambar tampil penuh di kartu samping TV, bergantian dengan '
            'Kas dan Petugas Jumat.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // Image upload area
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _selectedBase64Image == null ? null : _submit,
            icon: const Icon(Icons.add),
            label: const Text('Simpan Gambar'),
          ),
          const SizedBox(height: 24),
          Text(
            'Daftar Gambar Khusus',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.images.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada gambar khusus.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ...widget.images.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;
            final isFirst = index == 0;
            final isLast = index == widget.images.length - 1;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text('Gambar ${index + 1}'),
                          visualDensity: VisualDensity.compact,
                        ),
                        Switch(
                          value: image.isActive,
                          onChanged: (val) =>
                              widget.onToggleImage(image.id, val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (image.base64Image.isNotEmpty) ...[
                      _SpecialImageThumbnail(base64Image: image.base64Image),
                      const SizedBox(height: 8),
                    ],
                    if (image.caption.isNotEmpty)
                      Text(
                        image.caption,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Naikkan urutan',
                          onPressed: isFirst
                              ? null
                              : () => widget.onMoveImage(image.id, -1),
                          icon: const Icon(Icons.arrow_upward, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Turunkan urutan',
                          onPressed: isLast
                              ? null
                              : () => widget.onMoveImage(image.id, 1),
                          icon: const Icon(Icons.arrow_downward, size: 20),
                        ),
                        TextButton.icon(
                          onPressed: () => widget.onRemoveImage(image.id),
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
          }),
        ],
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
