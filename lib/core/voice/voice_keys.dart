import 'package:flutter/material.dart';

/// 全局 ScaffoldMessenger key——voice agent 弹「已加日程 · 撤销」时用。
///
/// 在 [MaterialApp.router] 上挂 `scaffoldMessengerKey: voiceMessengerKey`，
/// 各路由的 ScaffoldMessenger 也都会受这个 key 管。
final GlobalKey<ScaffoldMessengerState> voiceMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
