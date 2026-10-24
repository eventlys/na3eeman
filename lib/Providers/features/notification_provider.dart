import 'package:flutter/material.dart';
import '../../Services/api/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;

  NotificationProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount =>
      _notifications.where((n) => n['is_read'] == false).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _apiService.getNotifications();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _apiService.markNotificationRead(id);
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiService.markAllNotificationsRead();
      for (var n in _notifications) {
        n['is_read'] = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
