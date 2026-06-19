import 'package:flutter/material.dart';
import '../models/listing_model.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
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
              : _buildDetail(_listing!),
    );
  }

  Widget _buildDetail(ListingModel listing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
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