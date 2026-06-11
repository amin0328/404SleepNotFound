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
}

class GroupOrder {
  final String id;
  final String flagEmoji;
  final String title;
  final String storeName;
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

  const GroupOrder({
    required this.id,
    required this.flagEmoji,
    required this.title,
    required this.storeName,
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
  });

  GroupOrder copyWith({bool? isJoined}) => GroupOrder(
        id: id,
        flagEmoji: flagEmoji,
        title: title,
        storeName: storeName,
        status: status,
        deadline: deadline,
        sgdCost: sgdCost,
        krwApprox: krwApprox,
        itemsCost: itemsCost,
        shippingSplit: shippingSplit,
        pickup: pickup,
        hostEmoji: hostEmoji,
        hostName: hostName,
        isJoined: isJoined ?? this.isJoined,
      );
}

// mock data
final List<GroupOrder> sampleGroupOrders = [
  GroupOrder(
    id: '1',
    flagEmoji: '🇰🇷',
    title: 'Olive Young Haul – July',
    storeName: 'Olive Young · Beauty',
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
  GroupOrder(
    id: '2',
    flagEmoji: '🇯🇵',
    title: 'Uniqlo Japan Special Items',
    storeName: 'Uniqlo JP · Clothing',
    status: OrderStatus.confirmed,
    deadline: 'Jul 10',
    sgdCost: 'S\$1',
    krwApprox: '≈ ₩871 KRW',
    itemsCost: 'Items: ¥85',
    shippingSplit: 'Ship split: ¥13',
    pickup: 'Yusof Ishak House Lobby',
    hostEmoji: '👩‍🎨',
    hostName: 'Aiko M.',
    isJoined: true,
  ),
  GroupOrder(
    id: '3',
    flagEmoji: '🇺🇸',
    title: 'iHerb Supplements Bundle',
    storeName: 'iHerb · Health',
    status: OrderStatus.open,
    deadline: 'Jul 20',
    sgdCost: 'S\$90',
    krwApprox: '≈ ₩88,676 KRW',
    itemsCost: 'Items: \$60',
    shippingSplit: 'Ship split: \$8',
    pickup: 'Kent Ridge MRT',
    hostEmoji: '👨‍⚕️',
    hostName: 'Rahul P.',
    isJoined: false,
  ),
  GroupOrder(
    id: '4',
    flagEmoji: '🇯🇵',
    title: 'Daiso Japan Bulk Buy',
    storeName: 'Daiso JP Online · Household',
    status: OrderStatus.shipped,
    deadline: 'Jun 30',
    sgdCost: 'S\$0',
    krwApprox: '≈ ₩354 KRW',
    itemsCost: 'Items: ¥35',
    shippingSplit: 'Ship split: ¥5',
    pickup: 'CLB Atrium Level 1',
    hostEmoji: '👩‍💻',
    hostName: 'Sophie W.',
    isJoined: true,
  ),
  GroupOrder(
    id: '5',
    flagEmoji: '🇭🇰',
    title: 'Stylevana K-beauty Bundle',
    storeName: 'Stylevana · Beauty',
    status: OrderStatus.arrived,
    deadline: 'Jun 25',
    sgdCost: 'S\$17',
    krwApprox: '≈ ₩16,750 KRW',
    itemsCost: 'Items: HK\$95',
    shippingSplit: 'Ship split: HK\$6',
    pickup: 'UTown Starbucks',
    hostEmoji: '👩‍🎓',
    hostName: 'Priya S.',
    isJoined: false,
  ),
];
