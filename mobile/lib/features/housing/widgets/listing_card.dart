import 'package:flutter/material.dart';
import '../models/listing_model.dart';

class ListingCard extends StatefulWidget {
  final ListingModel listing;
  final VoidCallback? onView;

  const ListingCard({super.key, required this.listing, this.onView});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.listing.isSaved;
  }

  Color _sourceColor(String source) {
    switch (source.toLowerCase()) {
      case '99.co':      return const Color(0xFFE65100);
      case 'propertyguru': return const Color(0xFF2E7D32);
      case 'carousell':  return const Color(0xFFC62828);
      case 'srx':        return const Color(0xFF1565C0);
      default:           return const Color(0xFF7C3AED);
    }
  }

  Color _sourceBg(String source) {
    switch (source.toLowerCase()) {
      case '99.co':      return const Color(0xFFFFF3E0);
      case 'propertyguru': return const Color(0xFFE8F5E9);
      case 'carousell':  return const Color(0xFFFCE4EC);
      case 'srx':        return const Color(0xFFE3F2FD);
      default:           return const Color(0xFFF1F0FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _badge(widget.listing.source, _sourceColor(widget.listing.source), _sourceBg(widget.listing.source)),
                          const SizedBox(width: 8),
                          _badge(widget.listing.propertyType, const Color(0xFF7C3AED), const Color(0xFFF1F0FF)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.listing.title,
                          style: const TextStyle(
                            color: Color(0xFF1E1B4B),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Jost',
                          )),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 11, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(widget.listing.address,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Jost')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_subway_outlined, size: 11, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(widget.listing.mrtInfo,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Jost')),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _saved = !_saved),
                  child: Icon(
                    _saved ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: _saved ? const Color(0xFFEC4899) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF8FAFC), indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'S\$${widget.listing.pricePerMonth.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: const TextStyle(
                              color: Color(0xFF1E1B4B),
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Jost',
                            ),
                          ),
                          const TextSpan(
                            text: '/mo',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontFamily: 'Jost',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _badge(widget.listing.roomType, const Color(0xFF15803D), const Color(0xFFF0FDF4)),
                        const SizedBox(width: 8),
                        Text(widget.listing.leaseDuration,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'Jost')),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 11, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        Text(widget.listing.rating.toString(),
                            style: const TextStyle(color: Color(0xFF374151), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Jost')),
                        const SizedBox(width: 2),
                        Text('(${widget.listing.reviewCount})',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'Jost')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: widget.onView,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF818CF8).withOpacity(0.35), blurRadius: 5, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('View',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Jost')),
                            SizedBox(width: 4),
                            Icon(Icons.open_in_new, size: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.listing.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6,
                children: widget.listing.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(tag,
                      style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 10, fontFamily: 'Jost')),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color textColor, Color bgColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Jost')),
  );
}