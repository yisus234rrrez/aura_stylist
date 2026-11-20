import '../../models/servicios/servicio.dart';
import 'api_service.dart';

class ServicioService {
  ServicioService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Servicio>>> list() {
    return _api.get<List<Servicio>>(
      '/api/Servicios',
      parser: (dynamic json) => (json as List<dynamic>)
          .map((dynamic item) => Servicio.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<dynamic>> create(Servicio servicio) =>
      createRaw(servicio.toCreateJson());

  Future<ApiResponse<dynamic>> createRaw(Map<String, dynamic> body) =>
      _api.post<dynamic>('/api/Servicios', body: body);

  Future<ApiResponse<dynamic>> update(int id, Servicio servicio) =>
      _api.put<dynamic>('/api/Servicios/$id', body: servicio.toUpdateJson());

  Future<ApiResponse<dynamic>> updateRaw(int id, Map<String, dynamic> body) =>
      _api.put<dynamic>('/api/Servicios/$id', body: body);

  Future<ApiResponse<dynamic>> delete(int id) =>
      _api.delete<dynamic>('/api/Servicios/$id');
}
