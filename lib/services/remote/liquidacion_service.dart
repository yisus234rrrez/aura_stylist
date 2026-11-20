import '../../models/liquidaciones/liquidacion.dart';
import 'api_service.dart';

class LiquidacionService {
  LiquidacionService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Liquidacion>>> list({
    bool? ultimo,
    String? fechaInicio,
    String? fechaFin,
  }) {
    return _api.get<List<Liquidacion>>(
      '/api/liquidaciones-comisiones',
      query: <String, dynamic>{
        'ultimo': ?ultimo,
        'fechaInicio': ?fechaInicio,
        'fechaFin': ?fechaFin,
      },

      parser: (dynamic json) {
        final List<dynamic> rows = json is List ? json : <dynamic>[json];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(Liquidacion.fromJson)
            .toList();
      },
    );
  }

  Future<ApiResponse<dynamic>> create(
    String fechaInicio,
    String fechaFin,
  ) =>
      _api.post<dynamic>(
        '/api/liquidaciones-comisiones',
        body: <String, String>{
          'fechaInicio': fechaInicio,
          'fechaFin': fechaFin,
        },
      );
}
