import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/epic.dart';
import '../../data/models/display_list.dart';
import '../../data/repositories/epic_repository.dart';
import '../../data/repositories/display_list_repository.dart';

enum EpicFilter { all, active, completed }

class AppProvider extends ChangeNotifier {
  final EpicRepository _epicRepo = EpicRepository();
  final DisplayListRepository _listRepo = DisplayListRepository();
  final _uuid = const Uuid();

  List<Epic> _epics = [];
  List<DisplayList> _lists = [];
  int _currentListIndex = 0;
  EpicFilter _filter = EpicFilter.active;

  List<Epic> get epics => _epics;
  List<DisplayList> get lists => _lists;
  int get currentListIndex => _currentListIndex;
  EpicFilter get filter => _filter;

  DisplayList? get currentList {
    if (_lists.isEmpty) return null;
    if (_currentListIndex < 0 || _currentListIndex >= _lists.length) {
      return _lists.first;
    }
    return _lists[_currentListIndex];
  }

  Future<void> init() async {
    await _epicRepo.init();
    await _listRepo.init();
    _epics = _epicRepo.getAll();
    _lists = _listRepo.getAll();

    if (_lists.isEmpty) {
      await createList('Now');
      await createList('Later');
    }

    notifyListeners();
  }

  void setFilter(EpicFilter value) {
    _filter = value;
    notifyListeners();
  }

  // ─── Epics ───────────────────────────────────────────────

  Future<void> createEpic({
    required String title,
    required String description,
    required Color color,
    String? emoji,
    String? addToListId,
  }) async {
    final epic = Epic(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      colorValue: color.value,
      createdAt: DateTime.now(),
      isCompleted: false,
      emoji: emoji?.trim().isEmpty == true ? null : emoji?.trim(),
    );
    await _epicRepo.add(epic);
    _epics = _epicRepo.getAll();

    if (addToListId != null) {
      await addEpicToList(addToListId, epic.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> updateEpic(Epic epic) async {
    await _epicRepo.update(epic);
    _epics = _epicRepo.getAll();
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final epic = _epicRepo.getById(id);
    if (epic == null) return;

    final nowCompleted = !epic.isCompleted;
    final updated = epic.copyWith(
      isCompleted: nowCompleted,
      completedAt: nowCompleted ? DateTime.now() : null,
      clearCompletedAt: !nowCompleted,
    );
    await _epicRepo.update(updated);
    _epics = _epicRepo.getAll();
    notifyListeners();
  }

  Future<void> deleteEpic(String id) async {
    await _epicRepo.delete(id);
    for (final list in _lists) {
      if (list.epicIds.contains(id)) {
        final updated = list.copyWith(
          epicIds: list.epicIds.where((e) => e != id).toList(),
        );
        await _listRepo.update(updated);
      }
    }
    _epics = _epicRepo.getAll();
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  Epic? getEpicById(String id) => _epicRepo.getById(id);

  // ─── Display Lists ───────────────────────────────────────

  Future<void> createList(String name) async {
    final list = DisplayList(
      id: _uuid.v4(),
      name: name.trim(),
      epicIds: [],
      createdAt: DateTime.now(),
    );
    await _listRepo.add(list);
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  Future<void> renameList(String id, String newName) async {
    final list = _listRepo.getById(id);
    if (list == null) return;
    final updated = list.copyWith(name: newName.trim());
    await _listRepo.update(updated);
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  Future<void> deleteList(String id) async {
    if (_lists.length <= 1) return;
    await _listRepo.delete(id);
    _lists = _listRepo.getAll();
    if (_currentListIndex >= _lists.length) {
      _currentListIndex = _lists.length - 1;
    }
    notifyListeners();
  }

  Future<void> addEpicToList(String listId, String epicId) async {
    final list = _listRepo.getById(listId);
    if (list == null) return;
    if (list.epicIds.contains(epicId)) return;
    final updatedIds = [epicId, ...list.epicIds];
    final updated = list.copyWith(epicIds: updatedIds);
    await _listRepo.update(updated);
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  Future<void> removeEpicFromList(String listId, String epicId) async {
    final list = _listRepo.getById(listId);
    if (list == null) return;
    final updatedIds = list.epicIds.where((e) => e != epicId).toList();
    final updated = list.copyWith(epicIds: updatedIds);
    await _listRepo.update(updated);
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  Future<void> reorderEpicsInList(String listId, int oldIndex, int newIndex) async {
    final list = _listRepo.getById(listId);
    if (list == null) return;

    // Work on the currently visible (filtered) list indices is handled in UI.
    // Here we reorder the full epicIds list by the visible filtered items.
    // The UI will pass indices relative to the filtered list, so we need
    // the caller to pass the actual epic ids or we adjust here.
    // Simpler approach: UI passes old/new index of the *filtered* list,
    // and we map them back.

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ids = List<String>.from(list.epicIds);
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);

    final updated = list.copyWith(epicIds: ids);
    await _listRepo.update(updated);
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  /// Reorder using the visible filtered epics (safer with filters)
  Future<void> reorderVisibleEpics(
    String listId,
    List<Epic> visibleEpics,
    int oldIndex,
    int newIndex,
  ) async {
    final list = _listRepo.getById(listId);
    if (list == null) return;

    if (oldIndex < newIndex) newIndex -= 1;

    final visibleIds = visibleEpics.map((e) => e.id).toList();
    final movedId = visibleIds.removeAt(oldIndex);
    visibleIds.insert(newIndex, movedId);

    // Rebuild full epicIds: keep non-visible in original relative positions,
    // replace the sequence of visible ones with the new order.
    final fullIds = List<String>.from(list.epicIds);
    final visibleSet = visibleIds.toSet();
    int vi = 0;
    for (int i = 0; i < fullIds.length; i++) {
      if (visibleSet.contains(fullIds[i])) {
        fullIds[i] = visibleIds[vi++];
      }
    }

    final updated = list.copyWith(epicIds: fullIds);
    await _listRepo.update(updated);
    _lists = _listRepo.getAll();
    notifyListeners();
  }

  void setCurrentListIndex(int index) {
    if (index >= 0 && index < _lists.length) {
      _currentListIndex = index;
      notifyListeners();
    }
  }

  /// Epics for list, filtered and in stored order
  List<Epic> epicsForList(DisplayList list) {
    final result = <Epic>[];
    for (final id in list.epicIds) {
      final epic = getEpicById(id);
      if (epic == null) continue;
      switch (_filter) {
        case EpicFilter.all:
          result.add(epic);
        case EpicFilter.active:
          if (!epic.isCompleted) result.add(epic);
        case EpicFilter.completed:
          if (epic.isCompleted) result.add(epic);
      }
    }
    return result;
  }
}
