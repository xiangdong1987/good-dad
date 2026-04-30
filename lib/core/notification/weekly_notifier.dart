import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 简单的周一/周四 9:00 本地通知调度。
///
/// - 默认时区 Asia/Shanghai（暂不引入 flutter_timezone，避免增加依赖）
/// - id=1 周一；id=2 周四
/// - 用户在 onboarding / profile-edit 保存后调 [scheduleAll]
/// - 取消调 [cancelAll]
class WeeklyNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const _channelId = 'pregnancy_weekly';
  static const _channelName = '孕期每周提醒';
  static const _payload = '/week';

  static bool _initialized = false;

  /// 启动期调用一次：初始化插件 + 时区数据。
  static Future<void> init({
    void Function(String? payload)? onTap,
  }) async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (e) {
      // 时区数据找不到时回退到 UTC，至少不崩
      debugPrint('timezone Asia/Shanghai not found: $e');
    }

    const android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (resp) =>
          onTap?.call(resp.payload),
    );
    _initialized = true;
  }

  /// 申请权限（Android 13+ / iOS）。返回 true 表示拿到了或不需要。
  static Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted =
        await android?.requestNotificationsPermission() ?? true;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return granted;
  }

  /// 取消所有 + 重新登记 2 条循环通知（周一 9:00 / 周四 9:00）。
  static Future<void> scheduleAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();

    await _scheduleOne(
      id: 1,
      weekday: DateTime.monday,
      hour: 9,
      title: '✨ 新的一周开始啦',
      body: '点开看看本周宝宝在干嘛、爸爸能做什么',
    );
    await _scheduleOne(
      id: 2,
      weekday: DateTime.thursday,
      hour: 9,
      title: '🌷 老婆这两天还好吗？',
      body: '中段问候 · 顺手记一下今天的小事',
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  /// 仅供调试：立刻发一条通知确认链路。
  static Future<void> debugFireOnce() async {
    if (!_initialized) await init();
    await _plugin.show(
      999,
      '🐻 这是测试通知',
      '看到这条说明通知通道是通的',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: _payload,
    );
  }

  // ── helpers ───────────────────────────────────────────────

  static Future<void> _scheduleOne({
    required int id,
    required int weekday,
    required int hour,
    required String title,
    required String body,
  }) async {
    final scheduled = _nextInstanceOfWeekdayHour(weekday, hour);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: '每周一/四 9:00 推送孕期提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: _payload,
    );
  }

  static tz.TZDateTime _nextInstanceOfWeekdayHour(int weekday, int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (s.weekday != weekday || !s.isAfter(now)) {
      s = s.add(const Duration(days: 1));
    }
    return s;
  }
}

/// 给 UI 测试通知 / 重新调度的入口（设置页可以加入口）。
final weeklyNotifierProvider = Provider<WeeklyNotifier>((_) => WeeklyNotifier());
