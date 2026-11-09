import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/app_util.dart';
import '../core/values/constants.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initializeNotifications() async {
    tz.initializeTimeZones();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  static Future<void> scheduleNotification(int id, String title, String content, Duration duration) async {
    if (duration.inSeconds < 0) {
      return;
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        '0', // ID của kênh thông báo
        'Photo Magic', // Tên kênh thông báo
        channelDescription: '',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true);
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.now(tz.local).add(duration),
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: content,
        payload: "",
        matchDateTimeComponents: null
    );
  }


// Hàm tính toán Duration từ hiện tại đến mốc giờ mục tiêu
  static Duration _getDurationUntil(String timeStr, int dayOffset, DateTime now) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Tạo đối tượng DateTime cho mốc giờ mục tiêu của ngày tương ứng
      final targetDate = DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

      return targetDate.difference(now);
    } catch (e) {
      return const Duration(seconds: -1); // Trả về âm nếu parse lỗi
    }
  }
}