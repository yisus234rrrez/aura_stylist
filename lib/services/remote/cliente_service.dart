import '../../models/clientes/cliente.dart';
import 'api_service.dart';

class ClienteService {
  ClienteService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Cliente>>> list() {
    return _api.get<List<Cliente>>(
      '/api/Clientes',
      parser: (dynamic json) => (json as List<dynamic>)
          .map((dynamic item) => Cliente.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Cliente>> byDocumento(String documento) {
    return _api.get<Cliente>(
      '/api/Clientes/$documento',
      parser: (dynamic json) => Cliente.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<dynamic>> create(Cliente cliente) =>
      createRaw(cliente.toCreateJson());

  Future<ApiResponse<dynamic>> createRaw(Map<String, dynamic> body) =>
      _api.post<dynamic>('/api/Clientes', body: body);

  Future<ApiResponse<dynamic>> update(int id, Cliente cliente) =>
      updateRaw(id, cliente.toUpdateJson());

  Future<ApiResponse<dynamic>> updateRaw(int id, Map<String, dynamic> body) =>
      _api.put<dynamic>('/api/Clientes/$id', body: body);

  Future<ApiResponse<dynamic>> delete(int id) =>
      _api.delete<dynamic>('/api/Clientes/$id');
}
