import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // 通知功能暂不可用，需要后续集成 flutter_local_notifications
    debugPrint('NotificationService: init (placeholder)');
  }

  Future<void> scheduleShiftReminder(String date, String startTime, String shiftName, int minutesBefore) async {
    debugPrint('NotificationService: schedule reminder placeholder');
  }

  Future<void> cancelAll() async {
    debugPrint('NotificationService: cancelAll placeholder');
  }
}
