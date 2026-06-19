class CostSplitItem {
  final String userId;
  final String name;
  final bool isHost;
  final bool paid;
  final double itemCostSgd;
  final double shippingSplitSgd;

  CostSplitItem({
    required this.userId,
    required this.name,
    required this.itemCostSgd,
    required this.shippingSplitSgd,
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
      name: (json['name'] ?? json['user_name'] ?? 'Unknown').toString(),
      isHost: json['is_host'] == true,
      paid: (json['paid'] ?? json['is_paid']) == true,
      itemCostSgd: parseNum(json['item_cost_sgd'] ?? json['items_cost_sgd']),
      shippingSplitSgd:
          parseNum(json['shipping_split_sgd'] ?? json['split_shipping_sgd']),
    );
  }
}