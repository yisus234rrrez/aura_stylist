import '../../models/comisiones/comision.dart';
import 'api_service.dart';

class ComisionService {
  ComisionService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Comision>>> list({
    int? profesionalId,
    int? liquidacionComisionId,
    String? fechaInicio,
    String? fechaFin,
  }) {
    return _api.get<List<Comision>>(
      '/api/Comisiones',
      query: <String, dynamic>{
        'profesionalId': ?profesionalId,
        'cierreId': ?liquidacionComisionId,
        'fechaInicio': ?fechaInicio,
        'fechaFin': ?fechaFin,
      },
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Comision.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<List<ComisionServicio>>> servicios(int comisionId) {
    return _api.get<List<ComisionServicio>>(
      '/api/Comisiones/$comisionId/servicios',
      parser: (dynamic json) {
        final dynamic rows = json is Map<String, dynamic>
            ? json['comisionServicios']
            : json;
        return (rows as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(ComisionServicio.fromJson)
            .toList();
      },
    );
  }
}
