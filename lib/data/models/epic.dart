import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'epic.g.dart';

@HiveType(typeId: 0)
class Epic extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  /// ARGB color value for the pixel flag
  @HiveField(3)
  int colorValue;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime? completedAt;

  /// Optional emoji icon (shown next to or instead of pixel flag)
  @HiveField(7)
  String? emoji;

  Epic({
    required this.id,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.emoji,
  });

  Color get color => Color(colorValue);

  set color(Color value) => colorValue = value.value;

  Epic copyWith({
    String? id,
    String? title,
    String? description,
    int? colorValue,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    String? emoji,
    bool clearCompletedAt = false,
    bool clearEmoji = false,
  }) {
    return Epic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      emoji: clearEmoji ? null : (emoji ?? this.emoji),
    );
  }
}
