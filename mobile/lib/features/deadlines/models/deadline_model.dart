import 'package:flutter/material.dart';

import 'nus_calendar_event.dart';

enum DeadlineCategory { visa, lease, course, other }

enum UrgencyLevel { urgent, warning, normal }

class DeadlineModel {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final DeadlineCategory category;
  final String source;

  DeadlineModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.category,
    this.source = 'personal',
  });

  bool get isNusDeadline => source == 'nus';

  factory DeadlineModel.fromNusEvent(NusCalendarEvent event) => DeadlineModel(
        id: 'nus-${event.id}',
        title: event.title,
        description: event.notes,
        dueDate: event.eventDate,
        category: DeadlineCategory.other,
        source: 'nus',
      );

  UrgencyLevel get urgency {
    final days = dueDate.difference(DateTime.now()).inDays;
    if (days <= 3) return UrgencyLevel.urgent;
    if (days <= 7) return UrgencyLevel.warning;
    return UrgencyLevel.normal;
  }

  Color get urgencyColor {
    switch (urgency) {
      case UrgencyLevel.urgent:  return const Color(0xFFE53935);
      case UrgencyLevel.warning: return const Color(0xFFFB8C00);
      case UrgencyLevel.normal:  return const Color(0xFF43A047);
    }
  }

  factory DeadlineModel.fromJson(Map<String, dynamic> json) => DeadlineModel(
    id: json['id'].toString(),
    title: json['title'],
    description: json['notes'],
    dueDate: DateTime.parse(json['due_date']),
    category: DeadlineCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => DeadlineCategory.other,
    ),
    source: json['source'] ?? 'personal',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'notes': description,
    'due_date': dueDate.toIso8601String(),
    'category': category.name,
  };
}