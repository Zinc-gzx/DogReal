import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // Android 初始化设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // 请求通知权限（iOS）
  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  // 通知被点击时的回调
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: 处理通知点击，导航到相应页面
    print('Notification tapped: ${response.payload}');
  }

  // 显示即时通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'dogreal_channel',
      'DogReal 通知',
      channelDescription: '每日挑战和提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // 安排每日定时通知
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 如果时间已过，安排到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'dogreal_daily_channel',
      'DogReal 每日挑战',
      channelDescription: '每日挑战推送通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // 取消指定通知
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 获取待处理的通知列表
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // 安排今日挑战通知
  Future<void> scheduleTodayChallengeNotification({
    required String theme,
    required String icon,
    required String notificationTime,
  }) async {
    // 解析时间 "HH:mm"
    final parts = notificationTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    await scheduleDailyNotification(
      id: 1, // 固定ID，每日挑战使用ID 1
      title: '🐾 Time to DogReal!',
      body: '$icon $theme - 快来参加今日挑战吧！',
      hour: hour,
      minute: minute,
      payload: 'daily_challenge',
    );
  }

  // 清除每日挑战通知
  Future<void> clearDailyChallengeNotification() async {
    await cancelNotification(1);
  }
}
