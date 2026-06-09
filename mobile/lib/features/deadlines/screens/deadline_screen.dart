import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/deadline_model.dart';
import '../widgets/deadline_card.dart';
import '../widgets/deadline_modal.dart';

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<DeadlineModel> _deadlines = [
    DeadlineModel(id: '1', title: 'Visa Renewal', description: 'Immigration', dueDate: DateTime.now().add(const Duration(days: 4)), category: DeadlineCategory.visa),
    DeadlineModel(id: '2', title: 'Course Registration', description: 'Academics', dueDate: DateTime.now().add(const Duration(days: 7)), category: DeadlineCategory.course),
    DeadlineModel(id: '3', title: 'Lease Ends', description: 'Accommodation', dueDate: DateTime.now().add(const Duration(days: 17)), category: DeadlineCategory.lease),
  ];

  List<DeadlineModel> _getDeadlinesForDay(DateTime day) =>
      _deadlines.where((d) => isSameDay(d.dueDate, day)).toList();

  List<DeadlineModel> get _visibleDeadlines {
    if (_selectedDay == null) return [..._deadlines]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return _getDeadlinesForDay(_selectedDay!);
  }

  void _openModal({DeadlineModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DeadlineModal(
        existing: existing,
        onSave: (deadline) {
          setState(() {
            if (existing == null) {
              _deadlines.add(deadline);
            } else {
              final i = _deadlines.indexWhere((d) => d.id == existing.id);
              if (i != -1) _deadlines[i] = deadline;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A00C8), Color(0xFF3A10E0), Color(0xFF5B2CF5)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deadline Tracker',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Jost',
                              )),
                          Text('Stay ahead of what matters',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 12,
                                fontFamily: 'Jost',
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020),
                                lastDay: DateTime.utc(2030),
                                focusedDay: _focusedDay,
                                calendarFormat: CalendarFormat.month,
                                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                eventLoader: _getDeadlinesForDay,
                                onDaySelected: (selected, focused) {
                                  setState(() {
                                    _selectedDay = isSameDay(_selectedDay, selected) ? null : selected;
                                    _focusedDay = focused;
                                  });
                                },
                                onPageChanged: (focused) => setState(() => _focusedDay = focused),
                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Jost',
                                    color: Color(0xFF1E1B4B),
                                  ),
                                  leftChevronIcon: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F0FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chevron_left, size: 16, color: Color(0xFF7C3AED)),
                                  ),
                                  rightChevronIcon: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F0FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF7C3AED)),
                                  ),
                                ),
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Jost',
                                  ),
                                  weekendStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  defaultTextStyle: const TextStyle(
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                    fontFamily: 'Jost',
                                  ),
                                  todayDecoration: const BoxDecoration(
                                    color: Color(0xFFF1F0FF),
                                    borderRadius: BorderRadius.all(Radius.circular(14)),
                                  ),
                                  todayTextStyle: const TextStyle(
                                    color: Color(0xFF7C3AED),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Jost',
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFF7C3AED),
                                    borderRadius: BorderRadius.all(Radius.circular(14)),
                                  ),
                                  selectedTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Jost',
                                  ),
                                  markerDecoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    borderRadius: BorderRadius.all(Radius.circular(2)),
                                  ),
                                  markerSize: 4,
                                  markersMaxCount: 1,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Divider(color: Color(0xFFF1F5F9), height: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Text('UPCOMING',
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Jost',
                                    letterSpacing: 1.0,
                                  )),
                            ),
                            const SizedBox(height: 12),
                            if (_visibleDeadlines.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    _selectedDay == null ? 'No deadlines yet' : 'No deadlines on this day',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Jost'),
                                  ),
                                ),
                              )
                            else
                              ...(_visibleDeadlines.map((d) => DeadlineCard(
                                    deadline: d,
                                    onTap: () => _openModal(existing: d),
                                  ))),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F7FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEDE9FE)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _legendItem(const Color(0xFFEF4444), 'Urgent', '≤ 3 days'),
                                    _legendItem(const Color(0xFFF97316), 'Soon', '≤ 10 days'),
                                    _legendItem(const Color(0xFF10B981), 'On Track', '> 10 days'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _openModal(),
              backgroundColor: const Color(0xFF7C3AED),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String sub) {
    return Column(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF374151), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Jost')),
        Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'Jost')),
      ],
    );
  }
}