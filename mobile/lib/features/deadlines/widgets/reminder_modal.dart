import 'package:flutter/material.dart';

class ReminderModal extends StatefulWidget {
  final String deadlineTitle;
  final int initialDays;
  final Function(bool enabled, int days) onSave;

  const ReminderModal({
    super.key,
    required this.deadlineTitle,
    required this.initialDays,
    required this.onSave,
  });

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  bool _enabled = true;
  late int _selectedDays;

  final List<int> _options = [1, 2, 3, 5, 7, 14];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'Jost',
                      )),
                  Text(widget.deadlineTitle,
                      style: const TextStyle(
                        color: Color(0xFF1E1B4B),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Jost',
                      )),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_none, color: Color(0xFF818CF8), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enable Reminders',
                          style: TextStyle(
                            color: Color(0xFF1E1B4B),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Jost',
                          )),
                      Text("You'll be notified",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontFamily: 'Jost',
                          )),
                    ],
                  ),
                ),
                Switch(
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                  activeColor: const Color(0xFF7C3AED),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('ALERT ME BEFORE',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'Jost',
                letterSpacing: 1.0,
              )),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: _options.map((days) {
              final selected = _selectedDays == days;
              return GestureDetector(
                onTap: () => setState(() => _selectedDays = days),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF7C3AED) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '$days ${days == 1 ? 'day' : 'days'}',
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF374151),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Jost',
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_enabled, _selectedDays);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B8FFF), Color(0xFF7C3AED)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Jost',
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}