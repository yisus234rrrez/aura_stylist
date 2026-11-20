import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'aura_auth_token';
  static const String _empresaKey = 'aura_empresa_id';
  static const String _expiryKey = 'aura_token_expiry';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveEmpresaId(int empresaId) =>
      _storage.write(key: _empresaKey, value: empresaId.toString());

  Future<int?> getEmpresaId() async {
    final String? value = await _storage.read(key: _empresaKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> saveExpiry(DateTime expiry) =>
      _storage.write(key: _expiryKey, value: expiry.toIso8601String());

  Future<DateTime?> getExpiry() async {
    final String? value = await _storage.read(key: _expiryKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _empresaKey);
    await _storage.delete(key: _expiryKey);
  }
}
