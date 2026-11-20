import '../../models/reservas/reserva.dart';
import 'api_service.dart';

class ReservaService {
  ReservaService(this._api);

  final ApiService _api;

  Future<ApiResponse<List<Reserva>>> list({
    String? fechaInicio,
    String? fechaFin,
    int? clienteId,
    int? servicioId,
    int? profesionalId,
  }) {
    return _api.get<List<Reserva>>(
      '/api/Reservas',
      query: <String, dynamic>{
        'FechaInicio': ?fechaInicio,
        'FechaFin': ?fechaFin,
        'ClienteId': ?clienteId,
        'ServicioId': ?servicioId,
        'ProfesionalId': ?profesionalId,
      },
      parser: (dynamic json) => (json as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Reserva.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<Reserva>> get(int id) {
    return _api.get<Reserva>(
      '/api/Reservas/$id',
      parser: (dynamic json) => Reserva.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<dynamic>> create({
    required String fecha,
    required int servicioId,
    required int clienteId,
  }) {
    return _api.post<dynamic>(
      '/api/Reservas',
      body: <String, dynamic>{
        'fecha': fecha,
        'servicioId': servicioId,
        'clienteId': clienteId,
      },
    );
  }

  Future<ApiResponse<dynamic>> update(
    int id, {
    required String fecha,
    required int servicioId,
    required int profesionalId,
    required int clienteId,
  }) {
    return _api.put<dynamic>(
      '/api/Reservas/$id',
      body: <String, dynamic>{
        'fecha': fecha,
        'servicioId': servicioId,
        'profesionalId': profesionalId,
        'clienteId': clienteId,
      },
    );
  }


  Future<ApiResponse<dynamic>> cancel(int id) =>
      _api.delete<dynamic>('/api/Reservas/$id');
}
