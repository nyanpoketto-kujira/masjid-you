import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/m3_pressable.dart';

class BannersSubtab extends StatefulWidget {
  final List<MediaBanner> banners;
  final TextEditingController headerController;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController footerController;
  final Function(String? base64Image) onAddBanner;
  final Function(MediaBanner) onEditBanner;
  final Function(String) onRemoveBanner;
  final Function(String, bool) onToggleBanner;

  const BannersSubtab({
    super.key,
    required this.banners,
    required this.headerController,
    required this.titleController,
    required this.contentController,
    required this.footerController,
    required this.onAddBanner,
    required this.onEditBanner,
    required this.onRemoveBanner,
    required this.onToggleBanner,
  });

  @override
  State<BannersSubtab> createState() => _BannersSubtabState();
}

class _BannersSubtabState extends State<BannersSubtab> {
  String? _selectedBase64Image;
  File? _imagePreviewFile;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        key: const PageStorageKey('info_masjid_list_view'),
        children: [
          Text(
            'Tambah Info Masjid',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.headerController,
            decoration: const InputDecoration(
              labelText: 'Kategori / Header Banner',
              hintText: 'Misal: INFO MASJID, DONASI, KAJIAN',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.titleController,
            decoration: const InputDecoration(labelText: 'Judul Utama'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.contentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Isi Informasi (Max 3 Baris)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.footerController,
            decoration: const InputDecoration(labelText: 'Kaki Banner / Catatan Bawah'),
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
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: _clearImage,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            'Pilih Poster / Gambar (Maks 1080p)',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Berjalan 100% Offline',
                            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          M3Pressable(
            child: FilledButton.icon(
              onPressed: () {
                widget.onAddBanner(_selectedBase64Image);
                _clearImage();
              },
              icon: const Icon(Icons.add),
              label: const Text('Simpan Banner'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Daftar Banner Aktif',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.banners.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada banner informasi.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ...widget.banners.map((b) {
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
                          label: Text(b.header),
                          visualDensity: VisualDensity.compact,
                        ),
                        Switch(
                          value: b.isActive,
                          onChanged: (val) => widget.onToggleBanner(b.id, val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (b.base64Image != null && b.base64Image!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: colorScheme.surfaceContainerLow,
                          child: Image.memory(
                            base64Decode(b.base64Image!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.broken_image));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      b.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(b.content),
                    if (b.footer.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        b.footer,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        M3Pressable(
                          child: TextButton.icon(
                            onPressed: () => widget.onEditBanner(b),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                        ),
                        M3Pressable(
                          child: TextButton.icon(
                            onPressed: () => widget.onRemoveBanner(b.id),
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text('Hapus'),
                          ),
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
