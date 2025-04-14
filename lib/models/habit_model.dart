import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 2)  // Make sure this typeId is unique and not used by other Hive models
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final IconData icon;
  
  @HiveField(3)
  final int duration;
  
  @HiveField(4)
  final bool completed;
  
   HabitModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.duration,
    required this.completed,
  });
  
  HabitModel copyWith({
    String? id,
    String? title,
    IconData? icon,
    int? duration,
    bool? completed,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }

  // Optional: Add these methods if you want to compare habits or convert to string
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HabitModel{id: $id, title: $title, duration: $duration, completed: $completed}';
  }
}

// Custom IconData adapter for Hive
class IconDataAdapter extends TypeAdapter<IconData> {
  @override
  final int typeId = 3; // Make sure this typeId is unique

  @override
  IconData read(BinaryReader reader) {
    final codePoint = reader.readInt();
    return IconData(
      codePoint,
      fontFamily: 'MaterialIcons',
    );
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    writer.writeInt(obj.codePoint);
  }
}