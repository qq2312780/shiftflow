import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleShiftReminder(String date, String startTime, String shiftName, int minutesBefore) async {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final dateParts = date.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    var scheduled = DateTime(year, month, day, hour, minute);
    scheduled = scheduled.subtract(Duration(minutes: minutesBefore));

    if (scheduled.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'shift_reminders',
      'Shift Reminders',
      channelDescription: 'Reminders before your shifts start',
      importance: Importance.high,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      '${date}_${shiftName}_$startTime'.hashCode,
      '即将开始：$shiftName',
      '$shiftName 将在 $minutesBefore 分钟后开始（$startTime）',
      tz.TZDateTime.from(scheduled, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
