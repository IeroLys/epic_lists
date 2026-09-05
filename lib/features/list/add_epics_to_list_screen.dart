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

                final titleStyle = TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.green.shade600 : null,
                );

                final subtitleStyle = TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone
                      ? Colors.green.shade400.withOpacity(0.8)
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (epic.emoji != null && epic.emoji!.isNotEmpty)
                          Text(epic.emoji!, style: const TextStyle(fontSize: 28))
                        else
                          Opacity(
                            opacity: isDone ? 0.5 : 1,
                            child: PixelFlag(color: epic.color, size: 28),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(epic.title, style: titleStyle),
                              if (epic.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  epic.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: subtitleStyle,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isInList)
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            tooltip: 'Уже в списке — нажми, чтобы убрать',
                            onPressed: () {
                              provider.removeEpicFromList(list.id, epic.id);
                            },
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            tooltip: 'Добавить в список',
                            onPressed: () {
                              provider.addEpicToList(list.id, epic.id);
                            },
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