import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../agent/agent_tool.dart';
import '../voice_types.dart';

void _wlog(String msg) => debugPrint('[WeatherTool] $msg');

/// 查天气工具：自动定位（IP）+ 拉 Open-Meteo 数据 + 中文化。
///
/// 链路：
/// 1. 没 city 参数 → ipwho.is HTTPS 拿 lat/lon/city（免费，无 key）
/// 2. 有 city 参数 → Open-Meteo geocoding API 把城市名转 lat/lon
/// 3. Open-Meteo forecast API 拉当前 + 明天预报
/// 4. 拼一句给 TTS 念的话
///
/// 不需要 GPS 权限；精度到城市级，对孕期 app 的"今天能不能出门"够用。
class GetWeatherTool extends AgentTool {
  final Dio _dio;

  GetWeatherTool({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 8),
            ));

  @override
  String get name => 'get_weather';

  @override
  String get descriptionZh => '查当前天气 + 明天预报。没 city 参数会自动用 IP 定位';

  @override
  String get argsHint => 'city?:string(中文城市名，留空则 IP 自动定位)';

  @override
  List<ToolExample> get examples => const [
        ToolExample('今天天气怎么样', {}),
        ToolExample('明天会下雨吗', {}),
        ToolExample('上海天气', {'city': '上海'}),
        ToolExample('帮我看看深圳明天热不热', {'city': '深圳'}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final city = (args['city'] ?? '').toString().trim();

    final loc = city.isEmpty ? await _locateByIp() : await _locateByName(city);
    if (loc == null) {
      return ToolResult(
        speakText: city.isEmpty
            ? '没拿到定位，要不告诉我哪个城市？'
            : '没找到 $city 这个城市',
      );
    }

    final w = await _fetchWeather(loc.lat, loc.lon);
    if (w == null) {
      return const ToolResult(speakText: '天气服务暂时连不上，过会儿再问我');
    }

    final cityZh = loc.name.isEmpty ? '当地' : loc.name;
    final speak = '$cityZh，现在 ${w.currentTempC.round()} 度，${w.currentDescZh}。'
        '明天 ${w.tomorrowMinC.round()} 到 ${w.tomorrowMaxC.round()} 度，${w.tomorrowDescZh}';
    return ToolResult(speakText: speak);
  }

  // ── IP 定位 ──────────────────────────────────────────────────────
  Future<_GeoPoint?> _locateByIp() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('https://ipwho.is/');
      final d = r.data;
      if (d == null || d['success'] != true) return null;
      final lat = d['latitude'];
      final lon = d['longitude'];
      if (lat is! num || lon is! num) return null;
      final name = (d['city'] ?? d['region'] ?? '').toString();
      _wlog('ip located: $name ($lat, $lon)');
      return _GeoPoint(name: name, lat: lat.toDouble(), lon: lon.toDouble());
    } catch (e) {
      _wlog('ip locate failed: $e');
      return null;
    }
  }

  // ── 城市名 → lat/lon ────────────────────────────────────────────
  Future<_GeoPoint?> _locateByName(String city) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': city, 'count': 1, 'language': 'zh'},
      );
      final results = r.data?['results'];
      if (results is! List || results.isEmpty) return null;
      final f = results.first as Map;
      final lat = f['latitude'];
      final lon = f['longitude'];
      if (lat is! num || lon is! num) return null;
      final name = (f['name'] ?? city).toString();
      _wlog('geocoded: $name ($lat, $lon)');
      return _GeoPoint(name: name, lat: lat.toDouble(), lon: lon.toDouble());
    } catch (e) {
      _wlog('geocode failed: $e');
      return null;
    }
  }

  // ── 拉天气 ──────────────────────────────────────────────────────
  Future<_Weather?> _fetchWeather(double lat, double lon) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current_weather': 'true',
          'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
          'timezone': 'auto',
        },
      );
      final d = r.data;
      if (d == null) return null;
      final cw = d['current_weather'];
      final daily = d['daily'];
      if (cw is! Map || daily is! Map) return null;

      final curT = cw['temperature'];
      final curCode = cw['weathercode'];
      final maxList = daily['temperature_2m_max'];
      final minList = daily['temperature_2m_min'];
      final codeList = daily['weathercode'];

      if (curT is! num ||
          curCode is! num ||
          maxList is! List ||
          minList is! List ||
          codeList is! List ||
          maxList.length < 2) {
        return null;
      }

      return _Weather(
        currentTempC: curT.toDouble(),
        currentDescZh: _wmoZh(curCode.toInt()),
        tomorrowMaxC: (maxList[1] as num).toDouble(),
        tomorrowMinC: (minList[1] as num).toDouble(),
        tomorrowDescZh: _wmoZh((codeList[1] as num).toInt()),
      );
    } catch (e) {
      _wlog('weather fetch failed: $e');
      return null;
    }
  }

  // WMO weather codes → 中文
  String _wmoZh(int code) {
    if (code == 0) return '晴';
    if (code <= 2) return '多云';
    if (code <= 3) return '阴';
    if (code <= 48) return '有雾';
    if (code <= 55) return '毛毛雨';
    if (code <= 57) return '冻雨';
    if (code <= 65) return '中雨';
    if (code <= 67) return '冻雨';
    if (code <= 75) return '雪';
    if (code <= 77) return '冰粒';
    if (code <= 82) return '阵雨';
    if (code <= 86) return '阵雪';
    if (code <= 99) return '雷暴';
    return '天气信息暂时缺失';
  }
}

class _GeoPoint {
  final String name;
  final double lat;
  final double lon;
  const _GeoPoint({required this.name, required this.lat, required this.lon});
}

class _Weather {
  final double currentTempC;
  final String currentDescZh;
  final double tomorrowMaxC;
  final double tomorrowMinC;
  final String tomorrowDescZh;
  const _Weather({
    required this.currentTempC,
    required this.currentDescZh,
    required this.tomorrowMaxC,
    required this.tomorrowMinC,
    required this.tomorrowDescZh,
  });
}
