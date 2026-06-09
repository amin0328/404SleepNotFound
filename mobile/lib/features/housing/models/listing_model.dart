class ListingModel {
  final String id;
  final String title;
  final String source;
  final String propertyType;
  final String address;
  final String mrtInfo;
  final int pricePerMonth;
  final String roomType;
  final String leaseDuration;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final bool isSaved;
  final String? url;

  ListingModel({
    required this.id,
    required this.title,
    required this.source,
    required this.propertyType,
    required this.address,
    required this.mrtInfo,
    required this.pricePerMonth,
    required this.roomType,
    required this.leaseDuration,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    this.isSaved = false,
    this.url,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) => ListingModel(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    source: json['source'] ?? '',
    propertyType: json['type'] ?? '',
    address: json['location'] ?? '',
    mrtInfo: '',
    pricePerMonth: double.parse((json['price_sgd'] ?? 0).toString()).toInt(),
    roomType: json['room'] ?? '',
    leaseDuration: json['lease_months'] != null
        ? '${json['lease_months']} months'
        : '',
    rating: 0.0,
    reviewCount: 0,
    tags: List<String>.from(json['tags'] ?? []),
    isSaved: json['is_saved'] ?? false,
    url: json['url'],
  );
}