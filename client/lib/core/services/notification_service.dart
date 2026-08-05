import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';
import 'secure_storage_service.dart';

/// Handler untuk background message (harus di top-level atau static)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 [Notification] Background message: ${message.messageId}');
  debugPrint('🔔 [Notification] Title: ${message.notification?.title}');
  debugPrint('🔔 [Notification] Body: ${message.notification?.body}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SecureStorageService _storage;

  NotificationService(this._storage);

  /// Inisialisasi FCM dan local notifications
  Future<void> initialize() async {
    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('🔔 [Notification] Permission: ${settings.authorizationStatus}');

    // Setup local notifications
    await _setupLocalNotifications();

    // Setup FCM handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Check if app opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Get and save FCM token
    await _saveFcmToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('🔔 [Notification] Token refreshed');
      _saveTokenToBackend(token);
    });
  }

  /// Setup local notifications untuk menampilkan notifikasi di foreground
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 [Notification] Local notification tapped: ${details.payload}');
        // Handle notification tap
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          _handleNotificationTap(data);
        }
      },
    );

    // Buat notification channel untuk Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'nirpay_transactions',
        'Transaksi',
        description: 'Notifikasi untuk top up, withdraw, dan transaksi',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle pesan saat app di foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 [Notification] Foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'nirpay_transactions',
            'Transaksi',
            channelDescription: 'Notifikasi untuk top up, withdraw, dan transaksi',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle pesan saat app dibuka dari notifikasi (background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 [Notification] App opened from notification: ${message.messageId}');
    _handleNotificationTap(message.data);
  }

  /// Handle notification tap — navigasi ke halaman yang sesuai
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    debugPrint('🔔 [Notification] Type: $type');

    // TODO: Implement navigation based on type
    // topup_approved / topup_rejected → History page
    // withdraw_approved / withdraw_rejected → History page
  }

  /// Ambil dan simpan FCM token
  Future<void> _saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('🔔 [Notification] FCM Token: ${token.substring(0, 20)}...');
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('🔔 [Notification] Failed to get FCM token: $e');
    }
  }

  /// Kirim FCM token ke backend
  Future<void> _saveTokenToBackend(String token) async {
    try {
      final accessToken = await _storage.read('access_token');
      if (accessToken == null || accessToken == 'offline_token' || accessToken == 'seeded_token') {
        debugPrint('🔔 [Notification] Skipping FCM token save — offline mode');
        return;
      }

      final config = AppConfig.fromEnvironment(AppEnvironment.dev);
      final dio = Dio(BaseOptions(
        baseUrl: config.apiBaseUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ));

      await dio.post(
        '/notification/fcm-token',
        data: {'fcmToken': token},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      debugPrint('🔔 [Notification] FCM token saved to backend');
    } catch (e) {
      debugPrint('🔔 [Notification] Failed to save FCM token: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService harus di-override');
});
