import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _aOptions = AndroidOptions(encryptedSharedPreferences: true);
  static const _iOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final FlutterSecureStorage _storage;

  SecureStorage._(this._storage);

  factory SecureStorage() =>
      SecureStorage._(const FlutterSecureStorage(
        aOptions: _aOptions,
        iOptions: _iOptions,
      ));

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  Future<void> delete(String key) => _storage.delete(key: key);
}
