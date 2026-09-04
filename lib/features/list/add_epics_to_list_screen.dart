import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/display_list.dart';
import '../epic/pixel_flag.dart';

class AddEpicsToListScreen extends StatelessWidget {
  final DisplayList list;

  const AddEpicsToListScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allEpics = provider.epics;
    // Re-fetch current list state
    final currentList = provider.lists.firstWhere(
      (l) => l.id == list.id,
      orElse: () => list,
    );
    final currentIds = currentList.epicIds.toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить в «${list.name}»'),
      ),
      body: allEpics.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Пока нет ни одного эпика.\nСначала создай эпик кнопкой «+ Эпик».',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allEpics.length,
              itemBuilder: (context, index) {
                final epic = allEpics[index];
                final isInList = currentIds.contains(epic.id);
                final isDone = epic.isCompleted;

                return Card(
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (epic.emoji != null && epic.emoji!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              epic.emoji!,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        Opacity(
                          opacity: isDone ? 0.5 : 1,
                          child: PixelFlag(color: epic.color, size: 26),
                        ),
                      ],
                    ),
                    title: Text(
                      epic.title,
                      style: TextStyle(
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.green.shade600 : null,
                      ),
                    ),
                    subtitle: epic.description.isNotEmpty
                        ? Text(
                            epic.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: isInList
                        ? IconButton(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            tooltip: 'Уже в списке — нажми, чтобы убрать',
                            onPressed: () {
                              provider.removeEpicFromList(list.id, epic.id);
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            tooltip: 'Добавить в список',
                            onPressed: () {
                              provider.addEpicToList(list.id, epic.id);
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }
}
