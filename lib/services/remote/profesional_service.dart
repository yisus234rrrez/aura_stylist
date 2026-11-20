import '../../models/profesionales/profesional.dart';
import 'api_service.dart';

class ProfesionalService {
  ProfesionalService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Profesional>>> list({bool? soloActivos}) {
    return _api.get<List<Profesional>>(
      '/api/Profesionales',
      query: <String, dynamic>{'soloActivos': ?soloActivos},
      parser: (dynamic json) => (json as List<dynamic>)
          .map(
            (dynamic item) =>
                Profesional.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<ApiResponse<dynamic>> create(Profesional profesional) =>
      _api.post<dynamic>(
        '/api/Profesionales',
        body: profesional.toCreateJson(),
      );

  Future<ApiResponse<dynamic>> update(int id, Profesional profesional) =>
      _api.put<dynamic>(
        '/api/Profesionales/$id',
        body: profesional.toUpdateJson(),
      );

  Future<ApiResponse<dynamic>> delete(int id) =>
      _api.delete<dynamic>('/api/Profesionales/$id');
}
