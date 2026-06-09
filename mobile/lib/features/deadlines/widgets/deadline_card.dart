import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline_model.dart';
import 'reminder_modal.dart';

class DeadlineCard extends StatelessWidget {
  final DeadlineModel deadline;
  final VoidCallback onTap;

  const DeadlineCard({super.key, required this.deadline, required this.onTap});

  Color get _iconColor {
    switch (deadline.category) {
      case DeadlineCategory.visa:    return const Color(0xFF818CF8);
      case DeadlineCategory.course:  return const Color(0xFF34D399);
      case DeadlineCategory.lease:   return const Color(0xFFFB923C);
      case DeadlineCategory.other:   return const Color(0xFFF472B6);
    }
  }

  Color get _daysColor {
    final days = deadline.dueDate.difference(DateTime.now()).inDays;
    if (days <= 3)  return const Color(0xFFEF4444);
    if (days <= 10) return const Color(0xFFF97316);
    return const Color(0xFF10B981);
  }

  Color get _daysBgColor => _daysColor.withOpacity(0.15);

  @override
  Widget build(BuildContext context) {
    final days = deadline.dueDate.difference(DateTime.now()).inDays;
    final daysLabel = days == 0 ? 'Today' : days == 1 ? '1 day' : '$days days';
    final dateLabel = '${deadline.description ?? deadline.category.name} · ${DateFormat('d MMM').format(deadline.dueDate)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: _iconColor, borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deadline.title,
                      style: const TextStyle(
                        color: Color(0xFF1E1B4B),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Jost',
                      )),
                  Text(dateLabel,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'Jost',
                      )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _daysBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(daysLabel,
                      style: TextStyle(
                        color: _daysColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Jost',
                      )),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReminderModal(
                        deadlineTitle: deadline.title,
                        initialDays: 3,
                        onSave: (enabled, days) {},
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_none, size: 11, color: Color(0xFF818CF8)),
                        const SizedBox(width: 4),
                        const Text('3d before',
                            style: TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Jost',
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}