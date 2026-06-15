import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice_types.dart';

/// 当前页面给 voice agent 的上下文。
///
/// 例如意大利驾照页出题成功后写入：
/// ```dart
/// ref.read(pageContextProvider.notifier).state = PageContext(
///   kind: 'italian_license',
///   payload: {'questionIt': ..., 'options': [...], 'answer': 'B', 'explanationZh': '...'},
/// );
/// ```
/// 离开页面（dispose）时清空。
final pageContextProvider = StateProvider<PageContext?>((ref) => null);
