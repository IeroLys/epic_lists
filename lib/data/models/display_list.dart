import 'package:hive/hive.dart';

part 'display_list.g.dart';

@HiveType(typeId: 1)
class DisplayList extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Ordered list of Epic IDs that belong to this display list
  @HiveField(2)
  List<String> epicIds;

  @HiveField(3)
  DateTime createdAt;

  DisplayList({
    required this.id,
    required this.name,
    required this.epicIds,
    required this.createdAt,
  });

  DisplayList copyWith({
    String? id,
    String? name,
    List<String>? epicIds,
    DateTime? createdAt,
  }) {
    return DisplayList(
      id: id ?? this.id,
      name: name ?? this.name,
      epicIds: epicIds ?? List<String>.from(this.epicIds),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
