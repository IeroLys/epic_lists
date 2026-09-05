import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
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
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      backgroundColor: context.pxBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: context.pxPanel,
                border: Border.all(color: context.pxLine, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark ? Colors.black : const Color(0x33000000),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('⚑', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Text('EPIC LISTS', style: AppTheme.pixelTitle(color: context.pxFg)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              border: Border.all(color: context.pxLine, width: 2),
              boxShadow: [
                BoxShadow(
                  color: context.isDark ? Colors.black : const Color(0x33000000),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Material(
              color: context.pxPanel,
              child: InkWell(
                onTap: () => themeProvider.cycleTheme(),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(themeProvider.icon, size: 16, color: context.pxMuted),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: context.pxLine, width: 2),
              boxShadow: [
                BoxShadow(
                  color: context.isDark ? Colors.black : const Color(0x33000000),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Material(
              color: context.pxPanel,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageListsScreen()),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(Icons.playlist_add_check_rounded, size: 14, color: context.pxMuted),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: lists.map((l) => Tab(text: l.name.toUpperCase())).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: lists
            .map((list) => _EpicListView(key: ValueKey(list.id), listId: list.id))
            .toList(),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: context.isDark ? Colors.black : const Color(0x33000000),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            final current = provider.currentList;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EpicFormScreen(defaultListId: current?.id),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded, size: 16),
          label: Text(
  'ЭПИК',
  style: AppTheme.pixelSmall(
    color: context.isDark ? const Color(0xFFF0C9A8) : AppTheme.accentDim,
  ),
),
        ),
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
    DisplayList? list = provider.lists.firstWhere((l) => l.id == listId, orElse: () => throw Exception());
    final epics = provider.epicsForList(list);
    final filter = provider.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'АКТИВНЫЕ', selected: filter == EpicFilter.active, onTap: () => provider.setFilter(EpicFilter.active)),
                const SizedBox(width: 8),
                _FilterChip(label: 'ВЫПОЛНЕННЫЕ', selected: filter == EpicFilter.completed, onTap: () => provider.setFilter(EpicFilter.completed)),
                const SizedBox(width: 8),
                _FilterChip(label: 'ВСЕ', selected: filter == EpicFilter.all, onTap: () => provider.setFilter(EpicFilter.all)),
              ],
            ),
          ),
        ),
        if (epics.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Text('${epics.length} ${_pluralEpics(epics.length)}', style: AppTheme.body(size: 12, color: context.pxSubtle)),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEpicsToListScreen(list: list))),
                  child: const Text('+ Добавить', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        Expanded(
          child: epics.isEmpty
              ? _EmptyState(list: list, filter: filter)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                  itemCount: epics.length,
                  onReorder: (oldIndex, newIndex) => provider.reorderVisibleEpics(list.id, epics, oldIndex, newIndex),
                  itemBuilder: (context, index) => _EpicTile(key: ValueKey(epics[index].id), epic: epics[index], list: list),
                ),
        ),
      ],
    );
  }

  String _pluralEpics(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'эпик';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'эпика';
    return 'эпиков';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? context.pxChipSelected : context.pxPanel,
        border: Border.all(color: selected ? AppTheme.accentDim : context.pxLine, width: 2),
        boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2), blurRadius: 0)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(label, style: AppTheme.pixelSmall(size: 7, color: selected ? context.pxFg : context.pxSubtle)),
          ),
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(filter == EpicFilter.completed ? Icons.check_circle_outline_rounded : Icons.flag_outlined, size: 48, color: context.pxSubtle),
            const SizedBox(height: 16),
            Text(message, style: AppTheme.pixelSmall(color: context.pxSubtle), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Добавь эпики в этот список', style: AppTheme.body(size: 13, color: context.pxSubtle), textAlign: TextAlign.center),
            if (filter == EpicFilter.all || filter == EpicFilter.active) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2), blurRadius: 0)]),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEpicsToListScreen(list: list))),
                  child: const Text('ДОБАВИТЬ'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EpicTile extends StatelessWidget {
  final Epic epic;
  final DisplayList list;
  const _EpicTile({super.key, required this.epic, required this.list});

  @override
  Widget build(BuildContext context) {
    final isDone = epic.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: context.pxPanel,
        border: Border.all(color: context.pxLine, width: 2),
        boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(3, 3), blurRadius: 0)],
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(epic.title, style: AppTheme.body(size: 13, weight: FontWeight.w600, color: isDone ? AppTheme.ok : context.pxFg,)), // Упрощено
                  if (epic.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(epic.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTheme.body(size: 11, color: isDone ? AppTheme.okDim : context.pxMuted)),
                  ],
                  if (isDone && epic.completedAt != null) ...[
                    const SizedBox(height: 2),
                    Text('готово ${_formatDate(epic.completedAt!)}', style: AppTheme.body(size: 10, color: AppTheme.ok)),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: context.pxSubtle, size: 20),
              onSelected: (value) async {
                final provider = context.read<AppProvider>();
                if (value == 'toggle') await provider.toggleCompleted(epic.id);
                if (value == 'edit') Navigator.of(context).push(MaterialPageRoute(builder: (_) => EpicFormScreen(epic: epic)));
                if (value == 'remove') await provider.removeEpicFromList(list.id, epic.id);
                if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Удалить эпик?', style: AppTheme.pixelTitle(color: context.pxFg, size: 10)),
                      content: Text('Эпик «${epic.title}» будет удалён из всех списков безвозвратно.', style: AppTheme.body(size: 13)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
                      ],
                    ),
                  );
                  if (confirmed == true) await provider.deleteEpic(epic.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'toggle', child: ListTile(dense: true, leading: Icon(isDone ? Icons.undo_rounded : Icons.check_circle_outline_rounded, color: isDone ? context.pxMuted : AppTheme.ok, size: 18), title: Text(isDone ? 'Снять отметку' : 'Выполнено', style: AppTheme.body(size: 12)), contentPadding: EdgeInsets.zero)),
                const PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit_rounded, size: 18), title: Text('Редактировать', style: TextStyle(fontSize: 12)), contentPadding: EdgeInsets.zero)),
                const PopupMenuItem(value: 'remove', child: ListTile(dense: true, leading: Icon(Icons.remove_circle_outline_rounded, size: 18), title: Text('Убрать из списка', style: TextStyle(fontSize: 12)), contentPadding: EdgeInsets.zero)),
                const PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 18), title: Text('Удалить навсегда', style: TextStyle(color: AppTheme.danger, fontSize: 12)), contentPadding: EdgeInsets.zero)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}