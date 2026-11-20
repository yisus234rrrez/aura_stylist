import '../../models/horarios/horario_laboral.dart';
import 'api_service.dart';

class HorarioService {
  HorarioService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<HorarioLaboral>>> list() {
    return _api.get<List<HorarioLaboral>>(
      '/api/horarios-laboral',
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(HorarioLaboral.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<List<HorarioLaboral>>> byProfesional(int id) {
    return _api.get<List<HorarioLaboral>>(
      '/api/horarios-laboral/profesional/$id',
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(HorarioLaboral.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<dynamic>> create(HorarioLaboral horario) =>
      _api.post<dynamic>(
        '/api/horarios-laboral',
        body: horario.toCreateJson(),
      );

  Future<ApiResponse<dynamic>> update(int id, HorarioLaboral horario) =>
      _api.put<dynamic>(
        '/api/horarios-laboral/$id',
        body: horario.toUpdateJson(),
      );

  Future<ApiResponse<dynamic>> delete(int id) =>
      _api.delete<dynamic>('/api/horarios-laboral/$id');
}
