import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';
import '../services/housing_service.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'package:mobile/core/providers/user_provider.dart';

enum _SortOrder { priceAsc, priceDesc }

class SavedListingsScreen extends ConsumerStatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  ConsumerState<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends ConsumerState<SavedListingsScreen> {
  List<ListingModel> _listings = [];
  bool _isLoading = true;
  String? _error;
  _SortOrder _sortOrder = _SortOrder.priceAsc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final listings = await HousingService.getSavedListings();
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<ListingModel> get _sortedListings {
    final sorted = [..._listings];
    sorted.sort((a, b) => _sortOrder == _SortOrder.priceAsc
        ? a.pricePerMonth.compareTo(b.pricePerMonth)
        : b.pricePerMonth.compareTo(a.pricePerMonth));
    return sorted;
  }

  double get _averagePrice {
    if (_listings.isEmpty) return 0;
    final total = _listings.fold<int>(0, (sum, l) => sum + l.pricePerMonth);
    return total / _listings.length;
  }

  void _toggleSort() {
    setState(() {
      _sortOrder = _sortOrder == _SortOrder.priceAsc
          ? _SortOrder.priceDesc
          : _SortOrder.priceAsc;
    });
  }

  Future<void> _handleUnsave(ListingModel listing) async {
    try {
      await HousingService.unsaveListing(listing.id);
      setState(() {
        _listings.removeWhere((l) => l.id == listing.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _handleViewListing(ListingModel listing) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listing.id),
      ),
    );
    if (deleted == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final homeCurrency = userAsync.maybeWhen(
      data: (user) => user['home_currency'] as String?,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A00C8), Color(0xFF3A10E0), Color(0xFF5B2CF5)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Saved Listings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Jost',
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      child: _buildBody(homeCurrency),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String? homeCurrency) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Jost')),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _SavingsSummaryCard(
            count: _listings.length,
            averagePrice: _averagePrice,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_listings.length} saved',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Jost')),
              GestureDetector(
                onTap: _toggleSort,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _sortOrder == _SortOrder.priceAsc ? 'Price ↑' : 'Price ↓',
                      style: const TextStyle(
                          color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Jost'),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.swap_vert, size: 14, color: Color(0xFF7C3AED)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _listings.isEmpty
              ? const Center(
                  child: Text('No saved listings yet',
                      style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Jost')),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF7C3AED),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    itemCount: _sortedListings.length,
                    itemBuilder: (_, i) {
                      final listing = _sortedListings[i];
                      return ListingCard(
                        listing: listing,
                        onView: () => _handleViewListing(listing),
                        onSaveToggle: (save) {
                          if (!save) _handleUnsave(listing);
                        },
                        homeCurrency: homeCurrency,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _SavingsSummaryCard extends StatelessWidget {
  final int count;
  final double averagePrice;

  const _SavingsSummaryCard({required this.count, required this.averagePrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite, color: Color(0xFFEC4899), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count listing${count == 1 ? '' : 's'} saved',
                    style: const TextStyle(
                      color: Color(0xFF1E1B4B),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Jost',
                    )),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'Save listings to track them here'
                      : 'Avg. S\$${averagePrice.toStringAsFixed(0)}/mo',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontFamily: 'Jost',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}