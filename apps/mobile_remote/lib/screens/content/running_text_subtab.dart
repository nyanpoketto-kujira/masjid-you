import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/editor_empty_state.dart';

/// Editor Running Text (Fase 3, ADR-025): tambah lewat Extended FAB yang
/// membuka form dalam dialog full-screen; daftar berupa
/// [ReorderableListView] dengan handle drag terlihat + nomor urut; hapus
/// rutin diurungkan lewat SnackBar (ditangani pemanggil).
class RunningTextSubtab extends StatelessWidget {
  final List<RunningTextMessage> runningTexts;
  final TextEditingController runningTextController;
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategoryChanged;
  final VoidCallback onAddMessage;
  final Function(RunningTextMessage) onEditMessage;
  final Function(String) onRemoveMessage;

  /// Dipanggil saat urutan daftar diubah (drag & drop).
  final void Function(int oldIndex, int newIndex)? onReorder;

  const RunningTextSubtab({
    super.key,
    required this.runningTexts,
    required this.runningTextController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onAddMessage,
    required this.onEditMessage,
    required this.onRemoveMessage,
    this.onReorder,
  });

  void _openAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return RunningTextFormDialog(
          title: 'Tambah Teks Berjalan',
          textController: runningTextController,
          category: selectedCategory,
          categories: categories,
          onCategoryChanged: onCategoryChanged,
          onSave: onAddMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Teks'),
      ),
      body: runningTexts.isEmpty
          ? EditorEmptyState(
              icon: Icons.campaign,
              title: 'Belum ada teks berjalan',
              message: 'Tambahkan pengumuman, kajian, atau himbauan '
                  'untuk tampil di TV.',
              actionLabel: 'Tambah Teks',
              onAction: () => _openAddDialog(context),
            )
          : ReorderableListView.builder(
              key: const PageStorageKey('running_texts_list_view'),
              padding: const EdgeInsets.all(16.0),
              buildDefaultDragHandles: false,
              itemCount: runningTexts.length,
              onReorderItem: onReorder ?? (_, __) {},
              itemBuilder: (context, index) {
                final item = runningTexts[index];
                return Card(
                  key: ValueKey(item.id),
                  child: ListTile(
                    leading: _OrderNumber(index + 1),
                    title: Text(item.content),
                    subtitle: Text('Kategori: ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit teks',
                          onPressed: () => onEditMessage(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: colorScheme.error),
                          tooltip: 'Hapus teks',
                          onPressed: () => onRemoveMessage(item.id),
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

/// Nomor urut item dalam daftar putar (1-based).
class _OrderNumber extends StatelessWidget {
  const _OrderNumber(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

/// Form tambah/edit teks berjalan dalam dialog full-screen: field isi +
/// dropdown kategori + tombol Simpan eksplisit di AppBar (non-aktif bila
/// isi kosong). Kategori dipilih secara lokal di dialog; nilai akhirnya
/// diteruskan ke pemanggil lewat [onCategoryChanged] saat Simpan ditekan.
class RunningTextFormDialog extends StatefulWidget {
  const RunningTextFormDialog({
    super.key,
    required this.title,
    required this.textController,
    required this.category,
    required this.categories,
    required this.onCategoryChanged,
    required this.onSave,
  });

  final String title;
  final TextEditingController textController;
  final String category;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onSave;

  @override
  State<RunningTextFormDialog> createState() => RunningTextFormDialogState();
}

class RunningTextFormDialogState extends State<RunningTextFormDialog> {
  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
  }

  void _save() {
    widget.onCategoryChanged(_category);
    widget.onSave();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.title),
          actions: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.textController,
              builder: (context, value, _) {
                final canSave = value.text.trim().isNotEmpty;
                return TextButton(
                  onPressed: canSave ? _save : null,
                  child: const Text('Simpan'),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: widget.textController,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Isi Pesan',
                  prefixIcon: Icon(Icons.campaign),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Kategori: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _category,
                    items: widget.categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _category = val);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
