import '../../models/login/login_response.dart';
import '../local/secure_storage_service.dart';
import '../local/user_preferences_service.dart';
import 'api_service.dart';

class AuthService {
  AuthService(
    this._api, {
    SecureStorageService? storage,
    UserPreferencesService? preferences,
  })  : _storage = storage ?? SecureStorageService(),
        _preferences = preferences ?? UserPreferencesService();

  final ApiService _api;
  final SecureStorageService _storage;
  final UserPreferencesService _preferences;

  Future<bool> restoreSession() async {
    try {
      final String? token = await _storage.getToken();
      final int? empresaId = await _storage.getEmpresaId();
      if (token == null || token.isEmpty) return false;
      final DateTime? expiry = await _storage.getExpiry();
      if (expiry != null && expiry.isBefore(DateTime.now())) {
        await logout();
        return false;
      }
      _api.setToken(token);
      _api.setEmpresaId(empresaId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<ApiResponse<LoginResponse>> login(String usuario, String clave) async {
    final ApiResponse<LoginResponse> response =
        await _api.post<LoginResponse>(
      '/api/Sesion',
      body: <String, String>{'usuario': usuario, 'clave': clave},
      parser: (dynamic json) =>
          LoginResponse.fromJson(json as Map<String, dynamic>),
    );

    final LoginResponse? data = response.data;
    if (response.isSuccess && data != null && data.accessToken.isNotEmpty) {
      _api.setToken(data.accessToken);
      _api.setEmpresaId(data.empresaId);
      try {
        await _storage.saveToken(data.accessToken);
        await _storage.saveEmpresaId(data.empresaId);
        await _storage.saveExpiry(
          DateTime.now().add(Duration(seconds: data.expiresIn)),
        );
        await _preferences.saveSession(
          usuario: usuario,
          empresaId: data.empresaId,
          empresaNombre: data.empresaNombre,
        );
      } catch (_) {

      }
    }
    return response;
  }

  Future<void> logout() async {
    _api.setToken(null);
    _api.setEmpresaId(null);
    try {
      await _storage.clear();
      await _preferences.clear();
    } catch (_) {

    }
  }
}
