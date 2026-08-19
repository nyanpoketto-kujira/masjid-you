import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/m3_pressable.dart';

class RunningTextSubtab extends StatelessWidget {
  final List<RunningTextMessage> runningTexts;
  final TextEditingController runningTextController;
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategoryChanged;
  final VoidCallback onAddMessage;
  final Function(RunningTextMessage) onEditMessage;
  final Function(String) onRemoveMessage;

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
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: runningTextController,
                  decoration: const InputDecoration(
                    labelText: 'Tambah Teks Berjalan',
                    prefixIcon: Icon(Icons.campaign),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              M3Pressable(
                child: IconButton.filled(
                  onPressed: onAddMessage,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Kategori: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) onCategoryChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              key: const PageStorageKey('running_texts_list_view'),
              itemCount: runningTexts.length,
              itemBuilder: (context, index) {
                final item = runningTexts[index];
                return Card(
                  child: ListTile(
                    title: Text(item.content),
                    subtitle: Text('Kategori: ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        M3Pressable(
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => onEditMessage(item),
                          ),
                        ),
                        M3Pressable(
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onRemoveMessage(item.id),
                          ),
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
