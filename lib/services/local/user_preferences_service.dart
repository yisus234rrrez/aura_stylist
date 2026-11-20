import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _usuarioKey = 'aura_usuario';
  static const String _empresaIdKey = 'aura_empresa_id';
  static const String _empresaNombreKey = 'aura_empresa_nombre';

  Future<void> saveSession({
    required String usuario,
    required int empresaId,
    required String empresaNombre,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usuarioKey, usuario);
    await prefs.setInt(_empresaIdKey, empresaId);
    await prefs.setString(_empresaNombreKey, empresaNombre);
  }

  Future<String?> getUsuario() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usuarioKey);
  }

  Future<int?> getEmpresaId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_empresaIdKey);
  }

  Future<String?> getEmpresaNombre() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empresaNombreKey);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usuarioKey);
    await prefs.remove(_empresaIdKey);
    await prefs.remove(_empresaNombreKey);
  }
}
