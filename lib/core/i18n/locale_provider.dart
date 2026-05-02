import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/secure_storage.dart';
import 'app_locale.dart';
import 'l10n.dart';

class LocaleController extends AsyncNotifier<AppLocale> {
  static const _storageKey = 'app.locale';
  late final SecureStorage _storage;

  @override
  Future<AppLocale> build() async {
    _storage = SecureStorage();
    final raw = await _storage.read(_storageKey);
    return AppLocale.parse(raw);
  }

  Future<void> set(AppLocale loc) async {
    state = AsyncData(loc);
    await _storage.write(_storageKey, loc.code);
  }
}

final localeProvider =
    AsyncNotifierProvider<LocaleController, AppLocale>(LocaleController.new);

/// 当前 L10n 字典（同步访问；状态加载中默认 zh-CN）。
final l10nProvider = Provider<L10n>((ref) {
  final loc = ref.watch(localeProvider).valueOrNull ?? AppLocale.zhCN;
  return L10n(loc);
});
