import 'package:flutter/widgets.dart';

/// 当前支持的语言。新增语言只需要：
/// 1. 在这里加一项
/// 2. 在 [L10n] 里加对应的 strings map（缺的 key 会回退到中文）
/// 3. 在 [aiLanguageHint] 加一句给 LLM 看的说明
enum AppLocale {
  zhCN('zh-CN', '简体中文', '中文（简体）'),
  zhTW('zh-TW', '繁體中文', '繁體中文'),
  en('en', 'English', 'English'),
  ja('ja', '日本語', '日本語');

  /// 内部稳定 id（写到 secure_storage 用这个）
  final String code;
  /// UI 选择器里的 native 显示
  final String label;
  /// 给 AI 看的语言名（system prompt 里告诉 AI 用什么语言回复）
  final String aiLanguageHint;

  const AppLocale(this.code, this.label, this.aiLanguageHint);

  static AppLocale parse(String? code) {
    if (code == null || code.isEmpty) return AppLocale.zhCN;
    for (final l in values) {
      if (l.code == code) return l;
    }
    return AppLocale.zhCN;
  }

  Locale toFlutterLocale() {
    switch (this) {
      case AppLocale.zhCN:
        return const Locale('zh', 'CN');
      case AppLocale.zhTW:
        return const Locale('zh', 'TW');
      case AppLocale.en:
        return const Locale('en');
      case AppLocale.ja:
        return const Locale('ja');
    }
  }
}
