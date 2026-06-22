import 'package:flutter/material.dart';
import '../models/buddy_post.dart';

class CategoryFilterBar extends StatelessWidget {
  final PostCategory? selected;
  final ValueChanged<PostCategory?> onChanged;
  final bool savingsSelected;
  final VoidCallback onSavingsToggle;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.savingsSelected,
    required this.onSavingsToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...PostCategory.values];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == categories.length) {
            return _buildSavingsChip();
          }

          final cat = categories[i];
          final isSelected = !savingsSelected && cat == selected;
          final label = cat?.label ?? 'All';

          if (isSelected) {
            return GestureDetector(
              onTap: () => onChanged(cat),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
                  ),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D818CF8),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () => onChanged(cat),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavingsChip() {
    if (savingsSelected) {
      return GestureDetector(
        onTap: onSavingsToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DEC4899),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 12, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Savings',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onSavingsToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 12, color: Color(0xFF64748B)),
            SizedBox(width: 6),
            Text(
              'Savings',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}