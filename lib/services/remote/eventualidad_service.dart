import '../../models/eventualidades/eventualidad.dart';
import 'api_service.dart';

class EventualidadService {
  EventualidadService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Eventualidad>>> list({int? profesionalId}) {
    return _api.get<List<Eventualidad>>(
      '/api/eventualidades',
      query: <String, dynamic>{'profesionalId': ?profesionalId},
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Eventualidad.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<dynamic>> createMassive({
    required int profesionalId,
    required int motivo,
    required String observacion,
    required List<Map<String, String>> periodos,
  }) {
    return _api.post<dynamic>(
      '/api/eventualidades/masivo',
      body: <String, dynamic>{
        'profesionalId': profesionalId,
        'motivo': motivo,
        'observacion': observacion,
        'periodos': periodos,
      },
    );
  }

  Future<ApiResponse<dynamic>> delete(int id) =>
      _api.delete<dynamic>('/api/eventualidades/$id');
}
