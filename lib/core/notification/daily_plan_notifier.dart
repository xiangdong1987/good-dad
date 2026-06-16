import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 每晚固定时间发一条静态提醒，深链到 /fitness。
/// 真正的明日计划在用户点开页面时现场用 LLM 生成（见 fitness_page）。
class DailyPlanNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const _channelId = 'fitness_daily_plan';
  static const _channelName = '每晚训练计划提醒';
  static const _payload = '/fitness';
  static const _id = 10;

  static bool _tzReady = false;

  static void _ensureTz() {
    if (_tzReady) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (e) {
      debugPrint('timezone Asia/Shanghai not found: $e');
    }
    _tzReady = true;
  }

  /// 取消旧的，登记每天 [hour]:[minute] 的循环提醒。
  /// 假设 WeeklyNotifier.init() 已在启动期初始化过 plugin（共用同一插件实例）。
  static Future<void> schedule({int hour = 21, int minute = 0}) async {
    _ensureTz();
    await _plugin.cancel(_id);
    await _plugin.zonedSchedule(
      _id,
      '💪 明日计划准备好啦',
      '点开看看明天怎么练、怎么吃',
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: '每晚推送明日训练 + 饮食计划提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payload,
    );
  }

  static Future<void> cancel() => _plugin.cancel(_id);

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!s.isAfter(now)) s = s.add(const Duration(days: 1));
    return s;
  }
}

final dailyPlanNotifierProvider =
    Provider<DailyPlanNotifier>((_) => DailyPlanNotifier());
