// import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../Helpers/logger.dart';
import '../../Helpers/notification_helper.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _fcm;
  bool _hasFirebase = true;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _fcm = FirebaseMessaging.instance;
    } catch (e) {
      AppLogger.error('FCMService skipped: Firebase is not initialized properly. $e');
      _hasFirebase = false;
      return;
    }

    try {
      // Request permissions (especially for iOS)
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('User granted FCM permission');
      }

      // Get token
      String? token = await _fcm!.getToken();
      AppLogger.info('FCM Token: $token');
      // TODO: Send token to backend

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.info('FCM Foreground Message: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // Handle background clicks
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.info('FCM Message opened app: ${message.data}');
        // TODO: Navigate to specific page based on message data
      });

      // Handle terminated states
      RemoteMessage? initialMessage = await _fcm!.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info('FCM Initial Message: ${initialMessage.data}');
      }

      _initialized = true;
    } catch (e) {
      AppLogger.error('Failed to initialize FCM: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!_hasFirebase || _fcm == null) return;
    await _fcm!.subscribeToTopic(topic);
    AppLogger.info('Subscribed to FCM topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_hasFirebase || _fcm == null) return;
    await _fcm!.unsubscribeFromTopic(topic);
    AppLogger.info('Unsubscribed from FCM topic: $topic');
  }

  void _showLocalNotification(RemoteMessage message) {
    if (message.notification != null) {
      NotificationHelper().showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }
}

// Global background handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background isolate
  // await Firebase.initializeApp();
  AppLogger.info("Handling a background message: ${message.messageId}");
}
