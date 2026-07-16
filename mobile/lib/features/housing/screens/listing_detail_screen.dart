import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/listing_review.dart';
import '../services/housing_service.dart';
import 'package:mobile/core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  ListingModel? _listing;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;

  List<ListingReview> _reviews = [];
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadReviews();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final listing = await HousingService.getListingById(widget.listingId);
      setState(() {
        _listing = listing;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await HousingService.deleteListing(widget.listingId);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final result = await HousingService.getListingReviews(widget.listingId);
      setState(() {
        _reviews = result['reviews'];
        _averageRating = result['averageRating'];
        _reviewCount = result['reviewCount'];
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _handleWriteReview(String? currentUserId) async {
    ListingReview? existing;
    if (currentUserId != null) {
      for (final r in _reviews) {
        if (r.userId == currentUserId) {
          existing = r;
          break;
        }
      }
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewFormSheet(initialReview: existing),
    );

    if (result == null) return;

    try {
      await HousingService.submitReview(
        widget.listingId,
        rating: result['rating'],
        comment: result['comment'],
      );
      await Future.wait([_load(), _loadReviews()]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _handleDeleteReview(ListingReview review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('This will permanently remove your review.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await HousingService.deleteReview(widget.listingId, review.id);
      await Future.wait([_load(), _loadReviews()]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final currentUserId = userAsync.maybeWhen(
      data: (user) => user['id']?.toString(),
      orElse: () => null,
    );

    final isOwner = _listing != null &&
        currentUserId != null &&
        _listing!.postedBy == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Listing Details', style: TextStyle(color: Color(0xFF1E1B4B))),
        iconTheme: const IconThemeData(color: Color(0xFF1E1B4B)),
        actions: [
          if (isOwner)
            IconButton(
              onPressed: _isDeleting ? null : _handleDelete,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Color(0xFF94A3B8))),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _buildDetail(_listing!, currentUserId),
    );
  }

  Widget _buildDetail(ListingModel listing, String? currentUserId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (listing.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                listing.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: Color(0xFF94A3B8), size: 32),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _badge(listing.source, const Color(0xFF7C3AED), const Color(0xFFF1F0FF)),
              const SizedBox(width: 8),
              _badge(listing.propertyType, const Color(0xFF15803D), const Color(0xFFF0FDF4)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1B4B),
              fontFamily: 'Jost',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                listing.address,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Jost'),
              ),
            ],
          ),
          if (_reviewCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ..._buildStars(_averageRating, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_averageRating.toStringAsFixed(1)} · $_reviewCount review${_reviewCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B), fontFamily: 'Jost'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'S\$${listing.pricePerMonth}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1B4B),
                          fontFamily: 'Jost',
                        ),
                      ),
                      const TextSpan(
                        text: ' / month',
                        style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontFamily: 'Jost'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow(Icons.bed_outlined, 'Room type', listing.roomType.isEmpty ? '—' : listing.roomType),
                _detailRow(Icons.calendar_today_outlined, 'Lease', listing.leaseDuration.isEmpty ? '—' : listing.leaseDuration),
                if (listing.notes != null && listing.notes!.isNotEmpty)
                  _detailRow(Icons.notes_outlined, 'Notes', listing.notes!),
              ],
            ),
          ),
          if (listing.url != null && listing.url!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(listing.url!)),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 16, color: Color(0xFF7C3AED)),
                label: const Text('View original listing', style: TextStyle(color: Color(0xFF7C3AED))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEDE9FE)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B), fontFamily: 'Jost'),
              ),
              TextButton.icon(
                onPressed: () => _handleWriteReview(currentUserId),
                icon: const Icon(Icons.star_outline, size: 16, color: Color(0xFF7C3AED)),
                label: const Text('Write a review', style: TextStyle(color: Color(0xFF7C3AED), fontFamily: 'Jost')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoadingReviews)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
            )
          else if (_reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No reviews yet. Be the first!', style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Jost')),
            )
          else
            ..._reviews.map((review) => _ReviewCard(
                  review: review,
                  isMine: currentUserId != null && review.userId == currentUserId,
                  onDelete: () => _handleDeleteReview(review),
                  starsBuilder: _buildStars,
                )),
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating, {double size = 14}) {
    return List.generate(5, (i) {
      final filled = i < rating.round();
      return Icon(
        filled ? Icons.star : Icons.star_border,
        size: size,
        color: const Color(0xFFF59E0B),
      );
    });
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontFamily: 'Jost'),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B), fontFamily: 'Jost'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color textColor, Color bgColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Jost')),
  );
}

class _ReviewCard extends StatelessWidget {
  final ListingReview review;
  final bool isMine;
  final VoidCallback onDelete;
  final List<Widget> Function(double rating, {double size}) starsBuilder;

  const _ReviewCard({
    required this.review,
    required this.isMine,
    required this.onDelete,
    required this.starsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFF1F0FF),
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED)),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B), fontFamily: 'Jost'),
                    ),
                    Row(
                      children: [
                        ...starsBuilder(review.rating.toDouble(), size: 12),
                        const SizedBox(width: 6),
                        Text(
                          review.createdAt,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'Jost'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isMine)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontFamily: 'Jost', height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewFormSheet extends StatefulWidget {
  final ListingReview? initialReview;

  const _ReviewFormSheet({this.initialReview});

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  late int _rating;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialReview?.rating ?? 0;
    _commentController = TextEditingController(text: widget.initialReview?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialReview != null ? 'Edit your review' : 'Write a review',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Jost', color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starValue = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      size: 32,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating == 0
                    ? null
                    : () => Navigator.of(context).pop({
                          'rating': _rating,
                          'comment': _commentController.text,
                        }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  widget.initialReview != null ? 'Update review' : 'Submit review',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}