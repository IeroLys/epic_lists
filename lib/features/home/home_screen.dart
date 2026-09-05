import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../data/models/display_list.dart';
import '../../data/models/epic.dart';
import '../epic/epic_form_screen.dart';
import '../epic/pixel_flag.dart';
import '../list/manage_lists_screen.dart';
import '../list/add_epics_to_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.watch<AppProvider>();
    final lists = provider.lists;

    if (_tabController == null || _tabController!.length != lists.length) {
      final oldIndex = _tabController?.index ?? provider.currentListIndex;
      _tabController?.dispose();
      _tabController = TabController(
        length: lists.isEmpty ? 1 : lists.length,
        vsync: this,
        initialIndex: oldIndex.clamp(0, lists.isEmpty ? 0 : lists.length - 1),
      );
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          context.read<AppProvider>().setCurrentListIndex(_tabController!.index);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final lists = provider.lists;

    if (lists.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Epic Lists'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: lists.map((l) => Tab(text: l.name)).toList(),
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.icon),
            tooltip: 'Тема: ${themeProvider.label}',
            onPressed: () => themeProvider.cycleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_check_rounded),
            tooltip: 'Управление списками',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageListsScreen()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: lists
            .map((list) => _EpicListView(
                  key: ValueKey(list.id),
                  listId: list.id,
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final current = provider.currentList;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EpicFormScreen(
                defaultListId: current?.id,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Эпик'),
      ),
    );
  }
}

class _EpicListView extends StatelessWidget {
  final String listId;

  const _EpicListView({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    DisplayList? list;
    for (final l in provider.lists) {
      if (l.id == listId) {
        list = l;
        break;
      }
    }

    if (list == null) {
      return const Center(child: Text('Список не найден'));
    }

    final epics = provider.epicsForList(list);
    final filter = provider.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Фильтры
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Активные',
                  selected: filter == EpicFilter.active,
                  onTap: () => provider.setFilter(EpicFilter.active),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Выполненные',
                  selected: filter == EpicFilter.completed,
                  onTap: () => provider.setFilter(EpicFilter.completed),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Все',
                  selected: filter == EpicFilter.all,
                  onTap: () => provider.setFilter(EpicFilter.all),
                ),
              ],
            ),
          ),
        ),

        // Как в первой версии: счётчик + «Добавить»
        if (epics.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Text(
                  '${epics.length} ${_pluralEpics(epics.length)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEpicsToListScreen(list: list!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          ),

        Expanded(
          child: epics.isEmpty
              ? _EmptyState(list: list, filter: filter)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: epics.length,
                  onReorder: (oldIndex, newIndex) {
                    provider.reorderVisibleEpics(
                      list!.id,
                      epics,
                      oldIndex,
                      newIndex,
                    );
                  },
                  itemBuilder: (context, index) {
                    final epic = epics[index];
                    return _EpicTile(
                      key: ValueKey(epic.id),
                      epic: epic,
                      list: list!,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _pluralEpics(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'эпик';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'эпика';
    }
    return 'эпиков';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DisplayList list;
  final EpicFilter filter;

  const _EmptyState({required this.list, required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      EpicFilter.active => 'Нет активных эпиков',
      EpicFilter.completed => 'Нет выполненных эпиков',
      EpicFilter.all => 'Список пуст',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filter == EpicFilter.completed
                ? Icons.check_circle_outline_rounded
                : Icons.flag_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавь эпики в этот список',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          if (filter == EpicFilter.all || filter == EpicFilter.active) ...[
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEpicsToListScreen(list: list),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить эпики'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EpicTile extends StatelessWidget {
  final Epic epic;
  final DisplayList list;

  const _EpicTile({
    super.key,
    required this.epic,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: epic.emoji != null && epic.emoji!.isNotEmpty
    ? Text(epic.emoji!, style: const TextStyle(fontSize: 28))
    : Opacity(
        opacity: isDone ? 0.5 : 1,
        child: PixelFlag(color: epic.color, size: 28),
      ),
        title: Text(epic.title, style: titleStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (epic.description.isNotEmpty)
              Text(
                epic.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle,
              ),
            if (isDone && epic.completedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '✓ ${_formatDate(epic.completedAt!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade500,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) async {
            final provider = context.read<AppProvider>();
            switch (value) {
              case 'toggle':
                await provider.toggleCompleted(epic.id);
                break;
              case 'edit':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EpicFormScreen(epic: epic),
                  ),
                );
                break;
              case 'remove':
                await provider.removeEpicFromList(list.id, epic.id);
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Удалить эпик?'),
                    content: Text(
                      'Эпик «${epic.title}» будет удалён из всех списков безвозвратно.',
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
                if (confirmed == true) {
                  await provider.deleteEpic(epic.id);
                }
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(
                  isDone
                      ? Icons.undo_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isDone ? null : Colors.green,
                ),
                title: Text(isDone ? 'Снять отметку' : 'Выполнено'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_rounded),
                title: Text('Редактировать'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.remove_circle_outline_rounded),
                title: Text('Убрать из списка'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text(
                  'Удалить навсегда',
                  style: TextStyle(color: Colors.red),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y $h:$min';
  }
}