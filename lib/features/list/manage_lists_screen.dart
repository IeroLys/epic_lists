import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/display_list.dart';

class ManageListsScreen extends StatelessWidget {
  const ManageListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final lists = provider.lists;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Списки отображения'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: lists.length,
        itemBuilder: (context, index) {
          final list = lists[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  '${list.epicIds.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${list.epicIds.length} эпиков'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Переименовать',
                    onPressed: () => _rename(context, list),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: lists.length <= 1 ? null : Colors.red,
                    ),
                    tooltip: 'Удалить список',
                    onPressed: lists.length <= 1
                        ? null
                        : () => _delete(context, list),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новый список'),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final name = await _showNameDialog(context, title: 'Новый список');
    if (name != null && name.isNotEmpty) {
      await context.read<AppProvider>().createList(name);
    }
  }

  Future<void> _rename(BuildContext context, DisplayList list) async {
    final name = await _showNameDialog(
      context,
      title: 'Переименовать',
      initial: list.name,
    );
    if (name != null && name.isNotEmpty) {
      await context.read<AppProvider>().renameList(list.id, name);
    }
  }

  Future<void> _delete(BuildContext context, DisplayList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить список?'),
        content: Text(
          'Список «${list.name}» будет удалён.\nЭпики останутся в глобальном пуле.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppProvider>().deleteList(list.id);
    }
  }

  Future<String?> _showNameDialog(
    BuildContext context, {
    required String title,
    String initial = '',
  }) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
