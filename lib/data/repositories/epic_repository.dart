import 'package:hive/hive.dart';
import '../models/epic.dart';

class EpicRepository {
  static const String boxName = 'epics';
  late Box<Epic> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Epic>(boxName);
  }

  List<Epic> getAll() {
    final list = _box.values.toList();
    // Newest first by default
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Epic? getById(String id) => _box.get(id);

  Future<void> add(Epic epic) async {
    await _box.put(epic.id, epic);
  }

  Future<void> update(Epic epic) async {
    await _box.put(epic.id, epic);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
