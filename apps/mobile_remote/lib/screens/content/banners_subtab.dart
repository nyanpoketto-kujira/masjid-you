import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/editor_empty_state.dart';

/// Editor Info Masjid / Banner (Fase 3, ADR-025): tambah lewat Extended
/// FAB yang membuka form dalam dialog full-screen (termasuk pilih gambar);
/// daftar berupa [ReorderableListView] dengan handle drag terlihat +
/// nomor urut; hapus rutin diurungkan lewat SnackBar (ditangani pemanggil).
class BannersSubtab extends StatelessWidget {
  final List<MediaBanner> banners;
  final TextEditingController headerController;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController footerController;
  final Function(String? base64Image) onAddBanner;
  final Function(MediaBanner) onEditBanner;
  final Function(String) onRemoveBanner;
  final Function(String, bool) onToggleBanner;

  /// Dipanggil saat urutan daftar diubah (drag & drop).
  final void Function(int oldIndex, int newIndex)? onReorder;

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
    this.onReorder,
  });

  void _openAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddBannerDialog(
          headerController: headerController,
          titleController: titleController,
          contentController: contentController,
          footerController: footerController,
          onAddBanner: onAddBanner,
        );
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
        label: const Text('Tambah Banner'),
      ),
      body: banners.isEmpty
          ? EditorEmptyState(
              icon: Icons.newspaper,
              title: 'Belum ada banner informasi',
              message: 'Buat banner info masjid, donasi, atau kajian '
                  'untuk tampil di TV.',
              actionLabel: 'Tambah Banner',
              onAction: () => _openAddDialog(context),
            )
          : ReorderableListView.builder(
              key: const PageStorageKey('info_masjid_list_view'),
              padding: const EdgeInsets.all(16.0),
              buildDefaultDragHandles: false,
              itemCount: banners.length,
              onReorderItem: onReorder ?? (_, __) {},
              itemBuilder: (context, index) {
                final b = banners[index];
                return Card(
                  key: ValueKey(b.id),
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
                                  label: Text('Banner ${index + 1} · ${b.header}'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            Switch(
                              value: b.isActive,
                              onChanged: (val) =>
                                  onToggleBanner(b.id, val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (b.base64Image != null &&
                            b.base64Image!.isNotEmpty) ...[
                          _BannerThumbnail(base64Image: b.base64Image!),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          b.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                            TextButton.icon(
                              onPressed: () => onEditBanner(b),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () => onRemoveBanner(b.id),
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

/// Form tambah banner dalam dialog full-screen: 4 field + pilih gambar
/// (opsional) + tombol Simpan eksplisit di AppBar. Status gambar dipilih
/// hidup di dialog ini; controller field dipakai ulang dari pemanggil
/// (dibersihkan pemanggil saat banner tersimpan).
class _AddBannerDialog extends StatefulWidget {
  const _AddBannerDialog({
    required this.headerController,
    required this.titleController,
    required this.contentController,
    required this.footerController,
    required this.onAddBanner,
  });

  final TextEditingController headerController;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController footerController;
  final Function(String? base64Image) onAddBanner;

  @override
  State<_AddBannerDialog> createState() => _AddBannerDialogState();
}

class _AddBannerDialogState extends State<_AddBannerDialog> {
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

  void _save() {
    widget.onAddBanner(_selectedBase64Image);
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
          title: const Text('Tambah Banner'),
          actions: [
            ListenableBuilder(
              listenable: Listenable.merge([
                widget.titleController,
                widget.contentController,
              ]),
              builder: (context, _) {
                // Validasi sama seperti `_addBanner`: minimal judul, isi,
                // atau gambar terisi.
                final canSave = widget.titleController.text.trim().isNotEmpty ||
                    widget.contentController.text.trim().isNotEmpty ||
                    _selectedBase64Image != null;
                return TextButton(
                  onPressed: canSave ? _save : null,
                  child: const Text('Simpan'),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
              decoration:
                  const InputDecoration(labelText: 'Judul Utama'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Isi Informasi (Max 3 Baris)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.footerController,
              decoration: const InputDecoration(
                  labelText: 'Kaki Banner / Catatan Bawah'),
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
                              'Pilih Poster / Gambar (Maks 1080p)',
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

class _BannerThumbnail extends StatefulWidget {
  final String base64Image;

  const _BannerThumbnail({required this.base64Image});

  @override
  State<_BannerThumbnail> createState() => _BannerThumbnailState();
}

class _BannerThumbnailState extends State<_BannerThumbnail> {
  late Uint8List _cachedImageBytes;

  @override
  void initState() {
    super.initState();
    _cachedImageBytes = base64Decode(widget.base64Image);
  }

  @override
  void didUpdateWidget(covariant _BannerThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Image != widget.base64Image) {
      _cachedImageBytes = base64Decode(widget.base64Image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        width: double.infinity,
        color: colorScheme.surfaceContainerLow,
        child: Image.memory(
          _cachedImageBytes,
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
