import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/housing_service.dart';
import '../widgets/listing_card.dart';

class HousingScreen extends StatefulWidget {
  const HousingScreen({super.key});

  @override
  State<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends State<HousingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All';
  String _searchQuery = '';
  List<ListingModel> _listings = [];
  bool _isLoading = true;

  final List<String> _regions = ['All', 'Central', 'Northern', 'Southern', 'Eastern', 'Western'];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      print('Loading listings...');
      final listings = await HousingService.getListings();
      print('Listings count: ${listings.length}');
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      print('Housing error: $e');
      setState(() => _isLoading = false);
    }
  }

  List<ListingModel> get _filteredListings {
    return _listings.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  int get _savedCount => _listings.where((l) => l.isSaved).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, fontFamily: 'Jost')),
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
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontFamily: 'Jost'),
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
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.tune, size: 15, color: Colors.white),
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
                        onTap: () => setState(() => _selectedRegion = _regions[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(colors: [Color(0xFF5B2CF5), Color(0xFFC084FC)])
                                : null,
                            color: selected ? null : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: selected ? Colors.transparent : Colors.white.withOpacity(0.25)),
                            boxShadow: selected
                                ? [BoxShadow(color: const Color(0xFF5B2CF5).withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 4))]
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
                                const Text('Price ↑',
                                    style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Jost')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                                  )
                                : _filteredListings.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No listings found',
                                          style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Jost'),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                        itemCount: _filteredListings.length,
                                        itemBuilder: (_, i) => ListingCard(
                                          listing: _filteredListings[i],
                                          onView: () {},
                                        ),
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