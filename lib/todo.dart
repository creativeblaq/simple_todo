// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Todo {
  @Id()
  int id;

  final String title;
  final bool isDone;
  final String priority;

  Todo({
    this.id = 0,
    required this.title,
    this.isDone = false,
    this.priority = 'low',
  });

  Todo copyWith({
    int? id,
    String? title,
    bool? isDone,
    String? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isDone': isDone,
      'priority': priority,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      isDone: map['isDone'] as bool,
      priority: map['priority'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) =>
      Todo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isDone: $isDone, priority: $priority)';
  }

  /* @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      isDone.hashCode ^
      priority.hashCode;
  } */
}

enum Priority {
  low,
  medium,
  high;

  factory Priority.fromName(String name) {
    switch (name) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.low;
    }
  }

  static Color colorOf(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.green;
    }
  }
}

extension ColorEx on Color {
  Color getTextColor({bool reversed = false, double amount = 0.8}) {
    return (reversed ? (computeLuminance() > 0.5) : (computeLuminance() < 0.5))
        ? lighten(amount)
        : darken(amount);
  }

  Color changeColorLightness(double lightness) =>
      HSLColor.fromColor(this).withLightness(lightness).toColor();

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
