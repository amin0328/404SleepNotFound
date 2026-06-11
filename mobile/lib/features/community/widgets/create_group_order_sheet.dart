import 'package:flutter/material.dart';

class CreateGroupOrderSheet extends StatefulWidget {
  const CreateGroupOrderSheet({super.key});

  @override
  State<CreateGroupOrderSheet> createState() => _CreateGroupOrderSheetState();
}

class _CreateGroupOrderSheetState extends State<CreateGroupOrderSheet> {
  final _titleController = TextEditingController();
  final _storeController = TextEditingController();
  final _pickupController = TextEditingController();
  String? _selectedCategory;
  int _minParticipants = 2;
  DateTime? _deadline;

  static const _categories = [
    'Beauty', 'Clothing', 'Health', 'Household',
    'Food & Snacks', 'Electronics', 'Books', 'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Create Group Order',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 20),

            _FormField(
              label: 'Order title',
              child: TextField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Olive Young Haul – July'),
              ),
            ),

            _FormField(
              label: 'Origin country / store',
              child: TextField(
                controller: _storeController,
                decoration: _inputDecoration('e.g. Olive Young · Beauty'),
              ),
            ),

            _FormField(
              label: 'Product category',
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select category',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                decoration: _inputDecoration(''),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ),

            _FormField(
              label: 'Min. participants',
              child: Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_minParticipants > 2) {
                        setState(() => _minParticipants--);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      '$_minParticipants people',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add,
                    onTap: () => setState(() => _minParticipants++),
                  ),
                ],
              ),
            ),

            _FormField(
              label: 'Order deadline',
              child: GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      Text(
                        _deadline == null
                            ? 'Pick a date'
                            : '${_deadline!.day} ${_monthName(_deadline!.month)} ${_deadline!.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _deadline == null
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1E1B4B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _FormField(
              label: 'Pickup spot',
              child: TextField(
                controller: _pickupController,
                decoration: _inputDecoration('e.g. UTown Residential College 4'),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D818CF8),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.send_outlined,
                      size: 16, color: Colors.white),
                  label: const Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
        ),
      );

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF818CF8)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _handleSubmit() {
    // TODO: call API
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group order posted!')),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F0FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF818CF8)),
      ),
    );
  }
}
