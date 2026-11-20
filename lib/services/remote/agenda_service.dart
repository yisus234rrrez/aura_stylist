import '../../models/agenda/agenda.dart';
import 'api_service.dart';

class AgendaService {
  AgendaService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<String>>> availableSlots({
    required String fecha,
    required int servicioId,
    int? profesionalId,
  }) {
    return _api.get<List<String>>(
      '/api/agenda',
      query: <String, dynamic>{
        'fecha': fecha,
        'servicioId': servicioId,
        'profesionalId': ?profesionalId,
      },
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((dynamic item) => (item['fecha'] ?? '').toString())
          .where((String value) => value.isNotEmpty)
          .toList(),
    );
  }

  Future<ApiResponse<List<AgendaDay>>> day(String fecha) {
    return _api.get<List<AgendaDay>>(
      '/api/agenda/$fecha',
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(AgendaDay.fromJson)
          .toList(),
    );
  }
}
