import 'package:hive/hive.dart';
import '../models/display_list.dart';

class DisplayListRepository {
  static const String boxName = 'display_lists';
  late Box<DisplayList> _box;

  Future<void> init() async {
    _box = await Hive.openBox<DisplayList>(boxName);
  }

  List<DisplayList> getAll() {
    final list = _box.values.toList();
    // Keep stable order by createdAt (oldest first → left-to-right tabs)
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  DisplayList? getById(String id) => _box.get(id);

  Future<void> add(DisplayList list) async {
    await _box.put(list.id, list);
  }

  Future<void> update(DisplayList list) async {
    await _box.put(list.id, list);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
