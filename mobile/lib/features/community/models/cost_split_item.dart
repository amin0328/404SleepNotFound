class CostSplitItem {
  final String userId;
  final String name;
  final bool isHost;
  final bool paid;
  final double itemCostSgd;
  final double shippingSplitSgd;
  final String currency;
  final double totalLocal;
  final double exchangeRate;

  CostSplitItem({
    required this.userId,
    required this.name,
    required this.itemCostSgd,
    required this.shippingSplitSgd,
    required this.currency,
    required this.totalLocal,
    required this.exchangeRate,
    this.isHost = false,
    this.paid = false,
  });

  double get totalSgd => itemCostSgd + shippingSplitSgd;

  factory CostSplitItem.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return CostSplitItem(
      userId: json['user_id']?.toString() ?? '',
      name: (json['name'] ?? 'Unknown').toString(),
      isHost: json['is_host'] == true,
      paid: (json['paid'] ?? json['is_paid']) == true,
      itemCostSgd: parseNum(json['items_sgd']),
      shippingSplitSgd: parseNum(json['shipping_share_sgd']),
      currency: (json['currency'] ?? 'SGD').toString().toUpperCase(),
      totalLocal: parseNum(json['total_local']),
      exchangeRate: parseNum(json['exchange_rate']) == 0 ? 1 : parseNum(json['exchange_rate']),
    );
  }
}