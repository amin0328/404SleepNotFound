import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/listing_model.dart';
import '../services/housing_service.dart';
import '../widgets/listing_card.dart';
import '../widgets/create_listing_sheet.dart';
import '../widgets/housing_resources_section.dart';
import 'listing_detail_screen.dart';
import 'saved_listings_screen.dart';
import 'package:mobile/core/providers/user_provider.dart';

enum _SortOrder { priceAsc, priceDesc }

class HousingScreen extends ConsumerStatefulWidget {
  const HousingScreen({super.key});

  @override
  ConsumerState<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends ConsumerState<HousingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All';
  String _searchQuery = '';
  List<ListingModel> _listings = [];
  bool _isLoading = true;
  _SortOrder _sortOrder = _SortOrder.priceAsc;
  int? _minPrice;
  int? _maxPrice;

  final List<String> _regions = ['All', 'Central', 'Northern', 'Southern', 'Eastern', 'Western'];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final listings = await HousingService.getListings(
        location: _selectedRegion == 'All' ? null : _selectedRegion.toLowerCase(),
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onRegionChanged(String region) {
    setState(() => _selectedRegion = region);
    _loadListings();
  }

  void _toggleSort() {
    setState(() {
      _sortOrder = _sortOrder == _SortOrder.priceAsc
          ? _SortOrder.priceDesc
          : _SortOrder.priceAsc;
    });
  }

  Future<void> _openResource(HousingResourceItem resource) async {
    final opened = await launchUrl(Uri.parse(resource.url), mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this resource.')),
      );
    }
  }

  List<HousingResourceItem> get _housingResources => const [
        HousingResourceItem(
          label: 'HDB rental guide',
          description: 'Eligibility and options for renting HDB or open-market flats.',
          url: 'https://www.hdb.gov.sg/renting-a-flat',
          icon: Icons.account_balance_outlined,
          isOfficial: true,
        ),
        HousingResourceItem(
          label: 'URA rental rules',
          description: 'Minimum stay duration and occupancy limits for private homes.',
          url: 'https://www.ura.gov.sg/guidelines/property-and-business-owners/property/renting-property/',
          icon: Icons.gavel_outlined,
          isOfficial: true,
        ),
        HousingResourceItem(
          label: 'PropertyGuru rentals',
          description: 'Search current rooms, HDBs, condos, and landed rentals.',
          url: 'https://www.propertyguru.com.sg/property-for-rent',
          icon: Icons.home_work_outlined,
        ),
        HousingResourceItem(
          label: '99.co rentals',
          description: 'Browse current Singapore rental listings by area and property type.',
          url: 'https://www.99.co/',
          icon: Icons.search_outlined,
        ),
        HousingResourceItem(
          label: 'SRX rentals',
          description: 'Compare current room and whole-unit rental listings.',
          url: 'https://www.srx.com.sg/singapore-property-listings/property-for-rent',
          icon: Icons.map_outlined,
        ),
      ];

  Future<void> _handleSaveToggle(ListingModel listing, bool save) async {
    try {
      if (save) {
        await HousingService.saveListing(listing.id);
      } else {
        await HousingService.unsaveListing(listing.id);
      }
      final idx = _listings.indexWhere((l) => l.id == listing.id);
      if (idx != -1) {
        setState(() {
          _listings[idx] = _listings[idx].copyWith(isSaved: save);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${save ? 'save' : 'unsave'} listing.')),
        );
      }
    }
  }

  Future<void> _handleViewListing(ListingModel listing) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listing.id),
      ),
    );
    // Refresh in case the listing was deleted, or a review was added/removed
    // while on the detail screen.
    _loadListings();
  }

  void _handleCreateListing() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateListingSheet(onCreated: _loadListings),
    );
  }

  Future<void> _handleOpenSavedListings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedListingsScreen()),
    );
    // Refresh in case items were unsaved while on that screen.
    _loadListings();
  }

  Future<void> _handleDeleteListing(ListingModel listing) async {
    try {
      await HousingService.deleteListing(listing.id);
      setState(() {
        _listings.removeWhere((l) => l.id == listing.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${listing.title}" deleted.')),
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

  Future<void> _handleOpenPriceFilter() async {
    final minController = TextEditingController(text: _minPrice?.toString() ?? '');
    final maxController = TextEditingController(text: _maxPrice?.toString() ?? '');

    final result = await showModalBottomSheet<Map<String, int?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
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
              const Text('Price range (SGD / month)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Jost', color: Color(0xFF1E1B4B))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Min',
                        prefixText: 'S\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('–', style: TextStyle(color: Color(0xFF94A3B8))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Max',
                        prefixText: 'S\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop({'min': null, 'max': null}),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop({
                        'min': int.tryParse(minController.text),
                        'max': int.tryParse(maxController.text),
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Apply', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _minPrice = result['min'];
        _maxPrice = result['max'];
      });
      _loadListings();
    }
  }

  List<ListingModel> get _filteredListings {
    final filtered = _listings.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    filtered.sort((a, b) => _sortOrder == _SortOrder.priceAsc
        ? a.pricePerMonth.compareTo(b.pricePerMonth)
        : b.pricePerMonth.compareTo(a.pricePerMonth));

    return filtered;
  }

  int get _savedCount => _listings.where((l) => l.isSaved).length;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final homeCurrency = userAsync.maybeWhen(
      data: (user) => user['home_currency'] as String?,
      orElse: () => null,
    );
    final currentUserId = userAsync.maybeWhen(
      data: (user) => user['id']?.toString(),
      orElse: () => null,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateListing,
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            height: 210,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A00C8), Color(0xFF3A10E0), Color(0xFF5B2CF5), Color(0xFFC084FC)],
                stops: [0.0, 0.29, 0.46, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Housing Search',
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Jost')),
                              Text('$_savedCount saved · ${_filteredListings.length} listings found',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12, fontFamily: 'Jost')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 13),
                                  const Icon(Icons.search, size: 15, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (v) => setState(() => _searchQuery = v),
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Jost'),
                                      decoration: InputDecoration(
                                        hintText: 'Search area, title…',
                                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontFamily: 'Jost'),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _handleOpenPriceFilter,
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: (_minPrice != null || _maxPrice != null)
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.tune, size: 15, color: Colors.white),
                                  if (_minPrice != null || _maxPrice != null)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFC084FC),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _handleOpenSavedListings,
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.favorite, size: 15, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _regions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = _selectedRegion == _regions[i];
                      return GestureDetector(
                        onTap: () => _onRegionChanged(_regions[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(colors: [Color(0xFF5B2CF5), Color(0xFFC084FC)])
                                : null,
                            color: selected ? null : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.25)),
                            boxShadow: selected
                                ? [BoxShadow(color: const Color(0xFF5B2CF5).withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 4))]
                                : null,
                          ),
                          child: Center(
                            child: Text(_regions[i],
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Jost', fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_filteredListings.length} results',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Jost')),
                                GestureDetector(
                                  onTap: _toggleSort,
                                  child: Text(
                                    _sortOrder == _SortOrder.priceAsc ? 'Price ↑' : 'Price ↓',
                                    style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Jost'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                                  )
                                : ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                                        itemCount: _filteredListings.isEmpty ? 2 : _filteredListings.length + 1,
                                        itemBuilder: (_, i) {
                                          if (i == 0) {
                                            return HousingResourcesSection(
                                              region: _selectedRegion,
                                              resources: _housingResources,
                                              onOpen: _openResource,
                                            );
                                          }
                                          if (_filteredListings.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.only(top: 28),
                                              child: Center(
                                                child: Text(
                                                  'No student listings found for these filters.',
                                                  style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Jost'),
                                                ),
                                              ),
                                            );
                                          }
                                          final listing = _filteredListings[i - 1];
                                          return ListingCard(
                                            listing: listing,
                                            onView: () => _handleViewListing(listing),
                                            onSaveToggle: (save) => _handleSaveToggle(listing, save),
                                            homeCurrency: homeCurrency,
                                            isOwner: currentUserId != null && listing.postedBy == currentUserId,
                                            onDelete: () => _handleDeleteListing(listing),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
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
}
