import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/core/navigation/navigator_key.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/community/screens/cost_split_screen.dart';
import 'package:mobile/features/community/services/order_service.dart';
import 'package:mobile/features/deadlines/screens/deadline_screen.dart';
import 'package:mobile/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushService {
  PushService._internal();
  static final PushService instance = PushService._internal();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'default_channel',
    'General',
    description: 'General app notifications',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _initLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _registerToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => _registerToken());

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await ApiClient.dio.post('/users/fcm-token', data: {'token': token});
    } catch (_) {}
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      _routeToScreen(data);
    } catch (_) {}
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    await _routeToScreen(message.data);
  }

  Future<void> _routeToScreen(Map<String, dynamic> data) async {
    final navState = navigatorKey.currentState;
    if (navState == null) return;

    final type = data['type'];

    navState.pushNamedAndRemoveUntil('/home', (route) => false);

    switch (type) {
      case 'deadline':
        navState.push(MaterialPageRoute(builder: (_) => const DeadlineScreen()));
        break;
      case 'chat':
        await _openChat(data);
        break;
      case 'group_order':
        await _openGroupOrder(data);
        break;
      default:
        break;
    }
  }

  Future<void> _openChat(Map<String, dynamic> data) async {
    final conversationId = data['conversation_id']?.toString();
    if (conversationId == null) return;

    try {
      final conversations = await ChatService.getConversations();
      final conversation = conversations.firstWhere(
        (Conversation c) => c.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );

      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
      );
    } catch (_) {}
  }

  Future<void> _openGroupOrder(Map<String, dynamic> data) async {
    final orderId = data['order_id']?.toString();
    if (orderId == null) return;

    try {
      final orders = await OrderService.getOrders();
      final order = orders.firstWhere(
        (Map<String, dynamic> o) => o['id'].toString() == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => CostSplitScreen(
            orderId: orderId,
            orderTitle: order['order_name'] as String? ?? 'Group Order',
          ),
        ),
      );
    } catch (_) {}
  }
}