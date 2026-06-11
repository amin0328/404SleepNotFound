import 'package:flutter/material.dart';
import '../models/buddy_post.dart';

class BuddyCard extends StatefulWidget {
  final BuddyPost post;
  final VoidCallback? onMessage;

  const BuddyCard({super.key, required this.post, this.onMessage});

  @override
  State<BuddyCard> createState() => _BuddyCardState();
}

class _BuddyCardState extends State<BuddyCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.post.category;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.avatarBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.post.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          if (widget.post.matchPercent != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '${widget.post.matchPercent}% match',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF818CF8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.post.subInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _liked = !_liked),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _liked
                          ? const Color(0xFF818CF8)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              widget.post.bio,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cat.bgColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cat.color,
                    ),
                  ),
                ),
                ...widget.post.tags.map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (widget.post.lifestyleDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4.5,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: widget.post.lifestyleDetails
                    .map((d) => _LifestyleChip(detail: d))
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: cat.buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: cat.color.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: widget.onMessage,
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Send Message',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
}

class _LifestyleChip extends StatelessWidget {
  final LifestyleDetail detail;

  const _LifestyleChip({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(detail.icon, size: 11, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              detail.label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
