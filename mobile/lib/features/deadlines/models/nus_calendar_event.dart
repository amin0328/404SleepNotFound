class NusCalendarEvent {
  final String id;
  final String title;
  final String category;
  final DateTime eventDate;
  final String? semester;
  final String? notes;

  const NusCalendarEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.eventDate,
    this.semester,
    this.notes,
  });

  factory NusCalendarEvent.fromJson(Map<String, dynamic> json) => NusCalendarEvent(
        id: json['id'].toString(),
        title: json['title'],
        category: json['category'] ?? 'other',
        eventDate: DateTime.parse(json['event_date']),
        semester: json['semester'],
        notes: json['notes'],
      );
}