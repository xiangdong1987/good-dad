import 'app_locale.dart';

/// 极简 key→string 字典查询。缺失的 key 自动回退到 zh-CN，再缺就返回 key 本身。
///
/// 添加新 key 流程：
/// 1. 在 [_zhCN] 里加 'foo.bar' → '中文文案'
/// 2. 在其它语言 map 里加同 key 的翻译（不加也能跑，回退到中文）
/// 3. 调用方用 `L10n.of(locale).t('foo.bar')`
class L10n {
  final AppLocale locale;
  const L10n(this.locale);

  factory L10n.of(AppLocale locale) => L10n(locale);

  String t(String key, [Map<String, Object>? args]) {
    final dict = _dict(locale);
    var s = dict[key] ?? _zhCN[key] ?? key;
    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        s = s.replaceAll('{$k}', v.toString());
      });
    }
    return s;
  }

  static Map<String, String> _dict(AppLocale loc) => switch (loc) {
        AppLocale.zhCN => _zhCN,
        AppLocale.zhTW => _zhTW,
        AppLocale.en => _en,
        AppLocale.ja => _ja,
      };

  // ── 中文（简体） · 默认完整集 ──
  static const _zhCN = <String, String>{
    'app.title': 'good-dad',
    'common.save': '保存',
    'common.cancel': '取消',
    'common.confirm': '确定',
    'common.delete': '删除',
    'common.edit': '编辑',
    'common.loading': '加载中…',
    'common.error': '出错了',
    'common.try_again': '再试一次',

    // Settings page
    'settings.title': '设置',
    'settings.section_family': '家庭',
    'settings.section_data': '数据',
    'settings.section_backup': '备份与恢复',
    'settings.section_llm': 'LLM 服务',
    'settings.section_app': '应用',
    'settings.entry_profile': '家庭信息',
    'settings.entry_profile_subtitle': '改称呼 / 当前孕周',
    'settings.entry_calendar': '日历',
    'settings.entry_calendar_subtitle': '每天的安排 + 孕周',
    'settings.entry_test_notification': '测试通知',
    'settings.entry_test_notification_subtitle': '确认通知通道是通的',
    'settings.entry_memory': '记忆管理',
    'settings.entry_skills': '技能列表',
    'settings.entry_skills_subtitle': '查看内置 SKILL.md',
    'settings.entry_export': '导出备份',
    'settings.entry_import': '从备份恢复',
    'settings.entry_language': '语言',
    'settings.language_dialog_title': '选择语言',
    'settings.language_note':
        '切换会立即生效；UI 文案以中文为主，未翻译部分会自动回退到中文。AI 回答的语言会跟着变。',

    // Home
    'home.greeting': '嘿，{name}',
    'home.help_today': '今天能帮上什么？',
    'home.chat_card_title': '聊聊',
    'home.chat_card_sub': '什么都能问，不用客气',
  };

  // ── 繁體中文（暂时复用简体作为占位） ──
  static const _zhTW = <String, String>{
    'common.save': '儲存',
    'common.cancel': '取消',
    'common.confirm': '確定',
    'common.delete': '刪除',
    'common.edit': '編輯',
    'common.loading': '載入中…',
    'settings.title': '設定',
    'settings.entry_language': '語言',
    'settings.language_dialog_title': '選擇語言',
    'settings.entry_profile': '家庭資料',
    'settings.entry_calendar': '行事曆',
    'home.help_today': '今天能幫上什麼？',
  };

  // ── English ──
  static const _en = <String, String>{
    'app.title': 'good-dad',
    'common.save': 'Save',
    'common.cancel': 'Cancel',
    'common.confirm': 'OK',
    'common.delete': 'Delete',
    'common.edit': 'Edit',
    'common.loading': 'Loading…',
    'common.error': 'Something went wrong',
    'common.try_again': 'Try again',
    'settings.title': 'Settings',
    'settings.section_family': 'Family',
    'settings.section_data': 'Data',
    'settings.section_backup': 'Backup & restore',
    'settings.section_llm': 'LLM service',
    'settings.section_app': 'App',
    'settings.entry_profile': 'Family info',
    'settings.entry_profile_subtitle': 'Names · current pregnancy week',
    'settings.entry_calendar': 'Calendar',
    'settings.entry_calendar_subtitle': 'Daily schedule + pregnancy week',
    'settings.entry_test_notification': 'Test notification',
    'settings.entry_memory': 'Memory',
    'settings.entry_skills': 'Skills',
    'settings.entry_skills_subtitle': 'Built-in SKILL.md',
    'settings.entry_export': 'Export backup',
    'settings.entry_import': 'Restore from backup',
    'settings.entry_language': 'Language',
    'settings.language_dialog_title': 'Choose language',
    'settings.language_note':
        'Takes effect immediately. UI is mostly Chinese; missing keys fall back to Chinese. The AI answers in the chosen language.',
    'home.greeting': 'Hi, {name}',
    'home.help_today': 'How can I help today?',
    'home.chat_card_title': 'Chat',
    'home.chat_card_sub': 'Ask me anything',
  };

  // ── 日本語 ──
  static const _ja = <String, String>{
    'app.title': 'good-dad',
    'common.save': '保存',
    'common.cancel': 'キャンセル',
    'common.confirm': 'OK',
    'common.delete': '削除',
    'common.edit': '編集',
    'common.loading': '読み込み中…',
    'settings.title': '設定',
    'settings.entry_language': '言語',
    'settings.language_dialog_title': '言語を選ぶ',
    'settings.entry_profile': '家族情報',
    'settings.entry_calendar': 'カレンダー',
    'home.help_today': '今日のお手伝いは？',
  };
}
