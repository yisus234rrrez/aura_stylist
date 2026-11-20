class Reserva {  const Reserva({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.clienteId,
    required this.servicioId,
    required this.profesionalId,
    required this.estado,
    this.clienteNombre = '',
    this.servicioNombre = '',
    this.profesionalNombre = '',
    this.precio = 0,
  });

  final int id;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final int clienteId;
  final int servicioId;
  final int profesionalId;
  final int estado;
  final String clienteNombre;
  final String servicioNombre;
  final String profesionalNombre;
  final num precio;

  String get fechaCorta => fecha.split('T').first;
  String get hora => '$horaInicio – $horaFin';

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final dynamic cliente = json['cliente'];
    final dynamic servicio = json['servicio'];
    final dynamic profesional = json['profesional'];
    final String clientName = cliente is Map
        ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
        : '';
    final String serviceName =
        servicio is Map ? (servicio['nombre'] ?? '').toString() : '';
    final String professionalName = profesional is Map
        ? '${profesional['nombres'] ?? ''} ${profesional['apellidos'] ?? ''}'
            .trim()
        : '';
    return Reserva(
      id: int.tryParse('${json['id']}') ?? 0,
      fecha: (json['fecha'] ?? '').toString(),
      horaInicio: (json['horaInicio'] ?? '').toString(),
      horaFin: (json['horaFin'] ?? '').toString(),
      clienteId: int.tryParse('${json['clienteId']}') ?? 0,
      servicioId: int.tryParse('${json['servicioId']}') ?? 0,
      profesionalId: int.tryParse('${json['profesionalId']}') ?? 0,
      estado: int.tryParse('${json['estado']}') ?? 0,
      clienteNombre: clientName,
      servicioNombre: serviceName,
      profesionalNombre: professionalName,
      precio: num.tryParse('${servicio is Map ? servicio['precio'] : 0}') ?? 0,
    );
  }
}


String estadoReservaTexto(int estado) {
  switch (estado) {
    case 1:
      return 'Cancelada';
    case 2:
      return 'Completada';
    case 3:
      return 'Reagendada';
    default:
      return 'Agendada';
  }
}
