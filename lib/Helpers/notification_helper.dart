import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'logger.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();

  factory NotificationHelper() => _instance;

  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification channels
  static const AndroidNotificationChannel _generalChannel = AndroidNotificationChannel(
    'general_channel',
    'General Notifications',
    description: 'General notifications for the app',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel _appointmentChannel = AndroidNotificationChannel(
    'appointment_channel',
    'Appointment Notifications',
    description: 'Notifications for appointments and bookings',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _promotionChannel = AndroidNotificationChannel(
    'promotion_channel',
    'Promotion Notifications',
    description: 'Notifications for promotions and offers',
    importance: Importance.defaultImportance,
  );

  // Initialize notifications
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone database for scheduled notifications
      tz.initializeTimeZones();

      // Setup initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      // Create notification channels (Android 8.0+)
      await _createNotificationChannels();

      _isInitialized = true;
      AppLogger.info('Notification helper initialized successfully');
      return true;
    } catch (e) {
      AppLogger.error('Failed to initialize notification helper', error: e);
      return false;
    }
  }

  // Create notification channels
  Future<void> _createNotificationChannels() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_generalChannel);

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_appointmentChannel);

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_promotionChannel);

      AppLogger.debug('Notification channels created');
    } catch (e) {
      AppLogger.error('Failed to create notification channels', error: e);
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final details = _getNotificationDetails(type);

      await _notifications.show(id, title, body, details, payload: payload);

      AppLogger.debug('Notification shown: $title', extra: {
        'id': id,
        'type': type.toString(),
        'payload': payload,
      });
    } catch (e) {
      AppLogger.error('Failed to show notification: $title', error: e);
    }
  }

  // Schedule notification for specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final details = _getNotificationDetails(type);
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      AppLogger.debug('Notification scheduled: $title at $scheduledTime', extra: {
        'id': id,
        'type': type.toString(),
        'scheduled_time': scheduledTime.toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Failed to schedule notification: $title', error: e);
    }
  }

  // Schedule appointment reminder
  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String customerName,
    required DateTime appointmentTime,
    required String shopName,
    Duration reminderBefore = const Duration(hours: 1),
  }) async {
    try {
      final reminderTime = appointmentTime.subtract(reminderBefore);
      final title = 'Appointment Reminder';
      final body = 'Your appointment at $shopName is in ${reminderBefore.inHours} hour(s)';

      await scheduleNotification(
        id: appointmentId.hashCode,
        title: title,
        body: body,
        scheduledTime: reminderTime,
        payload: json.encode({
          'type': 'appointment_reminder',
          'appointment_id': appointmentId,
          'appointment_time': appointmentTime.toIso8601String(),
        }),
        type: NotificationType.appointment,
      );

      AppLogger.debug('Appointment reminder scheduled', extra: {
        'appointment_id': appointmentId,
        'reminder_time': reminderTime.toIso8601String(),
        'appointment_time': appointmentTime.toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Failed to schedule appointment reminder', error: e);
    }
  }

  // Schedule loyalty points notification
  Future<void> showLoyaltyPointsNotification({
    required int points,
    required String source,
    required int customerId,
  }) async {
    try {
      final title = 'Loyalty Points Earned! 🎉';
      final body = 'You earned $points points for $source';

      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        payload: json.encode({
          'type': 'loyalty_points',
          'points': points,
          'source': source,
          'customer_id': customerId,
        }),
        type: NotificationType.promotion,
      );

      AppLogger.debug('Loyalty points notification shown', extra: {
        'points': points,
        'source': source,
        'customer_id': customerId,
      });
    } catch (e) {
      AppLogger.error('Failed to show loyalty points notification', error: e);
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      AppLogger.debug('Notification cancelled: $id');
    } catch (e) {
      AppLogger.error('Failed to cancel notification: $id', error: e);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      AppLogger.debug('All notifications cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel all notifications', error: e);
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      AppLogger.error('Failed to get pending notifications', error: e);
      return [];
    }
  }

  // Check notification permissions
  Future<bool> checkPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        return result ?? false;
      }

      // Android permissions are typically granted by default
      return true;
    } catch (e) {
      AppLogger.error('Failed to check notification permissions', error: e);
      return false;
    }
  }

  // Get notification details based on type
  NotificationDetails _getNotificationDetails(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_channel',
            'Appointment Notifications',
            channelDescription: 'Notifications for appointments and bookings',
            importance: Importance.high,
            priority: Priority.high,
            colorized: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

      case NotificationType.promotion:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'promotion_channel',
            'Promotion Notifications',
            channelDescription: 'Notifications for promotions and offers',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            enableVibration: false,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

      case NotificationType.general:
      default:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'general_channel',
            'General Notifications',
            channelDescription: 'General notifications for the app',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );
    }
  }

  // Handle notification response
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final data = json.decode(payload) as Map<String, dynamic>;
        _handleNotificationPayload(data);
      }

      AppLogger.debug('Notification response received', extra: {
        'id': response.id,
        'action': response.actionId,
        'payload': payload,
      });
    } catch (e) {
      AppLogger.error('Error handling notification response', error: e);
    }
  }

  // Handle local notification (iOS)
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    AppLogger.debug('Local notification received', extra: {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }

  // Handle notification payload
  static void _handleNotificationPayload(Map<String, dynamic> payload) {
    final type = payload['type'] as String?;

    switch (type) {
      case 'appointment_reminder':
        final appointmentId = payload['appointment_id'] as String?;
        final appointmentTime = payload['appointment_time'] as String?;
        AppLogger.debug('Appointment reminder tapped', extra: {
          'appointment_id': appointmentId,
          'appointment_time': appointmentTime,
        });
        // Navigate to appointment details
        break;

      case 'loyalty_points':
        final points = payload['points'] as int?;
        final source = payload['source'] as String?;
        AppLogger.debug('Loyalty points notification tapped', extra: {
          'points': points,
          'source': source,
        });
        // Navigate to loyalty screen
        break;

      default:
        AppLogger.debug('Unknown notification type: $type');
    }
  }

  // Clear all scheduled notifications for a specific type
  Future<void> clearScheduledNotificationsByType(NotificationType type) async {
    try {
      final pending = await getPendingNotifications();
      final toRemove = pending.where((notification) {
        // This would need to be enhanced based on how you track notification types
        return true; // Placeholder logic
      }).toList();

      for (final notification in toRemove) {
        await cancelNotification(notification.id);
      }

      AppLogger.debug('Cleared ${toRemove.length} scheduled notifications of type: $type');
    } catch (e) {
      AppLogger.error('Failed to clear scheduled notifications by type', error: e);
    }
  }
}

enum NotificationType {
  general,
  appointment,
  promotion,
}

extension NotificationTypeExtension on NotificationType {
  String get name {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.promotion:
        return 'Promotion';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.general:
        return 'General app notifications';
      case NotificationType.appointment:
        return 'Appointment reminders and updates';
      case NotificationType.promotion:
        return 'Special offers and promotions';
    }
  }
}
