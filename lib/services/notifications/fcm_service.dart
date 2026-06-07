import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import 'package:dio/dio.dart';

class FcmService {
  final DioClient _dioClient;
  FirebaseMessaging? _messaging;
  bool _initialized = false;

  FcmService({required DioClient dioClient}) : _dioClient = dioClient;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      await _requestPermission();
      final token = await _messaging!.getToken();
      if (token != null) {
        debugPrint('FCM token: $token');
      }

      _setupForegroundHandler();
      _setupTokenRefresh();

      _initialized = true;
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  Future<void> registerDeviceToken() async {
    if (_messaging == null) return;

    try {
      final token = await _messaging!.getToken();
      if (token == null) return;

      await _dioClient.post(
        ApiConstants.notificationsDevice,
        data: {
          'fcmToken': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        },
      );
    } on DioException {
      debugPrint('Failed to register device token');
    }
  }

  Future<void> _requestPermission() async {
    if (_messaging == null) return;

    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      criticalAlert: true,
    );

    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _setupTokenRefresh() {
    if (_messaging == null) return;

    _messaging!.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: $newToken');
      registerDeviceToken();
    });
  }

  Future<void> handleInitialMessage() async {
    if (_messaging == null) return;

    final message = await _messaging!.getInitialMessage();
    if (message != null) {
      _handleNotificationTap(message);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    debugPrint('FCM tapped: $data');
  }
}
