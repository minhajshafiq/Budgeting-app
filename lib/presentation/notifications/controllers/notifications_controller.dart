import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';

class NotificationsController extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationsController({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService() {
    _notificationService.addListener(_onServiceChanged);
  }

  List<NotificationData> get notifications => _notificationService.notifications;
  int get unreadCount => _notificationService.unreadCount;

  void markAsRead(String id) {
    _notificationService.markAsRead(id);
  }

  void markAllAsRead() {
    _notificationService.markAllAsRead();
  }

  void removeNotification(String id) {
    _notificationService.removeNotification(id);
  }

  void clearAll() {
    _notificationService.notifications.clear();
    _notificationService.notifyListeners();
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    notifyListeners();
  }
} 