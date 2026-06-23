import 'package:flutter/material.dart';
import '../models/buddy_post.dart';
import '../services/community_service.dart';

class CreatePostSheet extends StatefulWidget {
  final VoidCallback? onCreated;

  const CreatePostSheet({super.key, this.onCreated});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _tagsController = TextEditingController();
  final _groupSizeController = TextEditingController();
  PostCategory? _selectedCategory;
  DateTime? _moveInDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    _tagsController.dispose();
    _groupSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickMoveInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF818CF8)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _moveInDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.trim().isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in a title and select a category.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await CommunityService.createPost(
        category: _selectedCategory!.apiValue,
        title: _titleController.text.trim(),
        body: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        tags: tags.isEmpty ? null : tags,
        groupSize: int.tryParse(_groupSizeController.text.trim()),
        moveInDate: _moveInDate?.toIso8601String().substring(0, 10),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onCreated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              'Create Buddy Post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 20),

            _FormField(
              label: 'Title',
              child: TextField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Looking for a roommate near UTown'),
              ),
            ),

            _FormField(
              label: 'Category',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PostCategory.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: selected,
                    selectedColor: cat.color,
                    backgroundColor: const Color(0xFFF8FAFC),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(color: selected ? cat.color : const Color(0xFFE2E8F0)),
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
            ),

            _FormField(
              label: 'Bio / description (optional)',
              child: TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: _inputDecoration('Tell potential buddies a bit about yourself'),
              ),
            ),

            _FormField(
              label: 'Tags (comma-separated, optional)',
              child: TextField(
                controller: _tagsController,
                decoration: _inputDecoration('e.g. Early Bird, Non-smoker, Korean'),
              ),
            ),

            _FormField(
              label: 'Group size (optional)',
              child: TextField(
                controller: _groupSizeController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 2'),
              ),
            ),

            _FormField(
              label: 'Move-in date (optional)',
              child: GestureDetector(
                onTap: _pickMoveInDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      Text(
                        _moveInDate == null
                            ? 'Pick a date'
                            : '${_moveInDate!.day} ${_monthName(_moveInDate!.month)} ${_moveInDate!.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _moveInDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E1B4B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFFA78BFA)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3D818CF8), blurRadius: 14, offset: Offset(0, 4)),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_outlined, size: 16, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Posting...' : 'Post',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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