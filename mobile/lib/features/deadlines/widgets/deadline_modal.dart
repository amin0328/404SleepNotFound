import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline_model.dart';

class DeadlineModal extends StatefulWidget {
  final DeadlineModel? existing;
  final Function(DeadlineModel) onSave;
  final VoidCallback? onDelete; // 추가

  const DeadlineModal({
    super.key,
    this.existing,
    required this.onSave,
    this.onDelete, // 추가
  });

  @override
  State<DeadlineModal> createState() => _DeadlineModalState();
}

class _DeadlineModalState extends State<DeadlineModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late DeadlineCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descController  = TextEditingController(text: widget.existing?.description ?? '');
    _selectedDate    = widget.existing?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _selectedCategory = widget.existing?.category ?? DeadlineCategory.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    widget.onSave(DeadlineModel(
      id: widget.existing?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      dueDate: _selectedDate,
      category: _selectedCategory,
    ));
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deadline'),
        content: Text('Delete "${widget.existing!.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete?.call();
      if (mounted) Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xffE4E4E4),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffACACAC), width: 0.3)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffACACAC), width: 0.3)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffACACAC), width: 0.3)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.existing == null ? 'Add Deadline' : 'Edit Deadline',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              if (widget.existing != null)
                IconButton(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete',
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(controller: _titleController, decoration: _inputDecoration('Title')),
          const SizedBox(height: 12),
          TextField(controller: _descController, decoration: _inputDecoration('Description (optional)')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: DeadlineCategory.values.map((cat) {
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                selected: selected,
                selectedColor: const Color(0xFF003D7C),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xffE4E4E4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffACACAC), width: 0.3),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(DateFormat('d MMMM yyyy').format(_selectedDate)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003D7C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(widget.existing == null ? 'Add' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}