import '../../models/especialidades/especialidad.dart';
import 'api_service.dart';

class EspecialidadService {
  EspecialidadService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Especialidad>>> list() {
    return _api.get<List<Especialidad>>(
      '/api/Especialidades',
      parser: (dynamic json) => (json as List<dynamic>)
          .map(
            (dynamic item) =>
                Especialidad.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<ApiResponse<dynamic>> listRaw() =>
      _api.get<dynamic>('/api/Especialidades');

  Future<ApiResponse<dynamic>> create(String nombre) =>
      createRaw(nombre);

  Future<ApiResponse<dynamic>> createRaw(String nombre) =>
      _api.post<dynamic>(
        '/api/Especialidades',
        body: <String, String>{'nombre': nombre},
      );

  Future<ApiResponse<dynamic>> update(int id, String nombre) =>
      _api.put<dynamic>(
        '/api/Especialidades/$id',
        body: <String, String>{'nombre': nombre},
      );

  Future<ApiResponse<dynamic>> delete(int id) =>
      _api.delete<dynamic>('/api/Especialidades/$id');
}
