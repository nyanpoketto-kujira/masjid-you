import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/m3_pressable.dart';

class BannersSubtab extends StatelessWidget {
  final List<MediaBanner> banners;
  final TextEditingController headerController;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController footerController;
  final VoidCallback onAddBanner;
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
            controller: headerController,
            decoration: const InputDecoration(
              labelText: 'Kategori / Header Banner',
              hintText: 'Misal: INFO MASJID, DONASI, KAJIAN',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Judul Utama'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: contentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Isi Informasi (Max 3 Baris)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: footerController,
            decoration: const InputDecoration(labelText: 'Kaki Banner / Catatan Bawah'),
          ),
          const SizedBox(height: 16),
          M3Pressable(
            child: FilledButton.icon(
              onPressed: onAddBanner,
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
          if (banners.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada banner informasi.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ...banners.map((b) {
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
                          onChanged: (val) => onToggleBanner(b.id, val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                            onPressed: () => onEditBanner(b),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                        ),
                        M3Pressable(
                          child: TextButton.icon(
                            onPressed: () => onRemoveBanner(b.id),
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
