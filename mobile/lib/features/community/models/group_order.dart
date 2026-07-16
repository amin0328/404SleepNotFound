import 'package:flutter/material.dart';

enum OrderStatus { open, confirmed, shipped, arrived }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.open:
        return 'Open';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.arrived:
        return 'Arrived';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.open:
        return const Color(0xFFF59E0B);
      case OrderStatus.confirmed:
        return const Color(0xFF818CF8);
      case OrderStatus.shipped:
        return const Color(0xFF3B82F6);
      case OrderStatus.arrived:
        return const Color(0xFF10B981);
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.open:
        return const Color(0xFFF59E0B).withValues(alpha: 0.12);
      case OrderStatus.confirmed:
        return const Color(0xFF818CF8).withValues(alpha: 0.12);
      case OrderStatus.shipped:
        return const Color(0xFF3B82F6).withValues(alpha: 0.12);
      case OrderStatus.arrived:
        return const Color(0xFF10B981).withValues(alpha: 0.12);
    }
  }

  int get stepIndex => OrderStatus.values.indexOf(this);

  String get apiValue => name;

  static OrderStatus fromApi(String? value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.open,
    );
  }
}

class GroupOrder {
  final String id;
  final String organiserId;
  final String flagEmoji;
  final String title;
  final String storeName;
  final String country;
  final OrderStatus status;
  final String deadline;
  final String sgdCost;
  final String krwApprox;
  final String itemsCost;
  final String shippingSplit;
  final String pickup;
  final String hostEmoji;
  final String hostName;
  final bool isJoined;
  final String deliveryFee;
  final int participantCount;

  const GroupOrder({
    required this.id,
    this.organiserId = '',
    required this.flagEmoji,
    required this.title,
    required this.storeName,
    required this.country,
    required this.status,
    required this.deadline,
    required this.sgdCost,
    required this.krwApprox,
    required this.itemsCost,
    required this.shippingSplit,
    required this.pickup,
    required this.hostEmoji,
    required this.hostName,
    this.isJoined = false,
    this.deliveryFee = 'S\$0.00',
    this.participantCount = 0,
  });

  factory GroupOrder.fromJson(Map<String, dynamic> json) {
    final itemCost = double.tryParse((json['my_item_cost_sgd'] ?? 0).toString()) ?? 0;
    final shippingShare = double.tryParse((json['my_split_shipping_sgd'] ?? 0).toString()) ?? 0;
    final totalSgd = itemCost + shippingShare;
    final totalShippingCost = double.tryParse((json['shipping_cost_sgd'] ?? 0).toString()) ?? 0;
    final participantCount = int.tryParse((json['participant_count'] ?? 0).toString()) ?? 0;

    String formattedDeadline = '';
    if (json['deadline'] != null) {
      final raw = json['deadline'].toString();
      formattedDeadline = raw.length >= 10 ? raw.substring(0, 10) : raw;
    }

    return GroupOrder(
      id: json['id'].toString(),
      organiserId: (json['organiser_id'] ?? '').toString(),
      flagEmoji: '🌍',
      title: json['order_name'] ?? '',
      storeName: json['store'] ?? '',
      country: json['country'] ?? '',
      status: OrderStatusExtension.fromApi(json['status']),
      deadline: formattedDeadline,
      sgdCost: 'S\$${totalSgd.toStringAsFixed(2)}',
      krwApprox: '',
      itemsCost: 'Items: S\$${itemCost.toStringAsFixed(2)}',
      shippingSplit: 'Ship split: S\$${shippingShare.toStringAsFixed(2)}',
      pickup: json['pickup_spot'] ?? '',
      hostEmoji: '👤',
      hostName: json['host_name'] ?? '',
      isJoined: json['is_joined'] ?? false,
      deliveryFee: 'S\$${totalShippingCost.toStringAsFixed(2)}',
      participantCount: participantCount,
    );
  }

  GroupOrder copyWith({bool? isJoined, OrderStatus? status}) => GroupOrder(
        id: id,
        organiserId: organiserId,
        flagEmoji: flagEmoji,
        title: title,
        storeName: storeName,
        country: country,
        status: status ?? this.status,
        deadline: deadline,
        sgdCost: sgdCost,
        krwApprox: krwApprox,
        itemsCost: itemsCost,
        shippingSplit: shippingSplit,
        pickup: pickup,
        hostEmoji: hostEmoji,
        hostName: hostName,
        isJoined: isJoined ?? this.isJoined,
        deliveryFee: deliveryFee,
        participantCount: participantCount,
      );
}

final List<GroupOrder> sampleGroupOrders = [
  GroupOrder(
    id: '1',
    flagEmoji: '🇰🇷',
    title: 'Olive Young Haul – July',
    storeName: 'Olive Young · Beauty',
    country: 'South Korea',
    status: OrderStatus.open,
    deadline: 'Jul 15',
    sgdCost: 'S\$0',
    krwApprox: '≈ ₩129 KRW',
    itemsCost: 'Items: ₩120',
    shippingSplit: 'Ship split: ₩9',
    pickup: 'UTown Residential College 4',
    hostEmoji: '🧑‍💻',
    hostName: 'Min-Ji K.',
    isJoined: true,
  ),
];