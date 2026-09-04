// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpicAdapter extends TypeAdapter<Epic> {
  @override
  final int typeId = 0;

  @override
  Epic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Epic(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      colorValue: fields[3] as int,
      createdAt: fields[4] as DateTime,
      isCompleted: fields[5] as bool? ?? false,
      completedAt: fields[6] as DateTime?,
      emoji: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Epic obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.emoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
