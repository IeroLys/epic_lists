import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/display_list.dart';
import '../epic/pixel_flag.dart';

class AddEpicsToListScreen extends StatelessWidget {
  final DisplayList list;
  const AddEpicsToListScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allEpics = provider.epics;
    final currentList = provider.lists.firstWhere((l) => l.id == list.id, orElse: () => list);
    final currentIds = currentList.epicIds.toSet();

    return Scaffold(
      backgroundColor: context.pxBg,
      appBar: AppBar(
        title: Text('В «${list.name}»', style: AppTheme.pixelTitle(color: context.pxFg, size: 10)),
      ),
      body: allEpics.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Пока нет ни одного эпика.\nСначала создай эпик кнопкой «+ ЭПИК».', textAlign: TextAlign.center, style: AppTheme.body(color: context.pxMuted)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allEpics.length,
              itemBuilder: (context, index) {
                final epic = allEpics[index];
                final isInList = currentIds.contains(epic.id);
                final isDone = epic.isCompleted;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: context.pxPanel,
                    border: Border.all(color: context.pxLine, width: 2),
                    boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2), blurRadius: 0)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (epic.emoji != null && epic.emoji!.isNotEmpty)
                          Text(epic.emoji!, style: const TextStyle(fontSize: 28))
                        else
                          Opacity(opacity: isDone ? 0.5 : 1, child: PixelFlag(color: epic.color, size: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(epic.title, style: AppTheme.body(size: 13, weight: FontWeight.w600, color: isDone ? AppTheme.ok : context.pxFg)),
                              if (epic.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(epic.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.body(size: 11, color: isDone ? AppTheme.okDim.withOpacity(0.8) : context.pxMuted)),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.pxLine, width: 2),
                            boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2))],
                          ),
                          child: Material(
                            color: context.pxPanel,
                            child: InkWell(
                              onTap: () {
                                if (isInList) {
                                  provider.removeEpicFromList(list.id, epic.id);
                                } else {
                                  provider.addEpicToList(list.id, epic.id);
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  isInList ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                  color: isInList ? AppTheme.ok : context.pxMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
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