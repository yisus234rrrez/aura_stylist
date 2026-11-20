import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../config/app_navigator.dart';
import '../../models/login/login_response.dart';
import '../../routes/app_routes.dart';
import 'agenda_service.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'cliente_service.dart';
import 'comision_service.dart';
import 'especialidad_service.dart';
import 'eventualidad_service.dart';
import 'horario_service.dart';
import 'liquidacion_service.dart';
import 'profesional_service.dart';
import 'reserva_service.dart';
import 'servicio_service.dart';


class AuraApi {
  AuraApi._();

  static ApiService api = ApiService(
    baseUrl: AppConfig.apiBaseUrl,
    onUnauthorized: () {
      _handleUnauthorized();
    },
  );

  static bool _handlingUnauthorized = false;

  static Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    await auth.logout();
    appMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Tu sesión expiró. Inicia sesión de nuevo.'),
      ),
    );
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    _handlingUnauthorized = false;
  }

  static AuthService get auth => AuthService(api);
  static ClienteService get clientes => ClienteService(api);
  static EspecialidadService get especialidades => EspecialidadService(api);
  static ServicioService get servicios => ServicioService(api);
  static ProfesionalService get profesionales => ProfesionalService(api);
  static LiquidacionService get liquidaciones => LiquidacionService(api);
  static AgendaService get agenda => AgendaService(api);
  static ReservaService get reservas => ReservaService(api);
  static HorarioService get horarios => HorarioService(api);
  static EventualidadService get eventualidades => EventualidadService(api);
  static ComisionService get comisiones => ComisionService(api);

  static Future<bool> restoreSession() => auth.restoreSession();
  static Future<ApiResponse<LoginResponse>> login(String usuario, String clave) =>
      auth.login(usuario, clave);
  static Future<void> logout() => auth.logout();


  static Future<ApiResponse<dynamic>> createClient(Map<String, dynamic> body) =>
      clientes.createRaw(body);
  static Future<ApiResponse<dynamic>> updateClient(
    int id,
    Map<String, dynamic> body,
  ) =>
      clientes.updateRaw(id, body);
  static Future<ApiResponse<dynamic>> getSpecialties() =>
      especialidades.listRaw();
  static Future<ApiResponse<dynamic>> createSpecialty(String nombre) =>
      especialidades.createRaw(nombre);
  static Future<ApiResponse<dynamic>> createService(Map<String, dynamic> body) =>
      servicios.createRaw(body);
}
