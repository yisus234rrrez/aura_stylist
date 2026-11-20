class Comision {
  const Comision({
    required this.id,
    required this.profesionalId,
    required this.profesionalNombre,
    required this.total,
    this.liquidacionComisionId = 0,
    this.fecha = '',
    this.porcentaje = 0,
    this.servicios = 0,
    this.estado = '',
  });

  final int id;
  final int profesionalId;
  final String profesionalNombre;
  final num total;
  final int liquidacionComisionId;
  final String fecha;
  final num porcentaje;
  final int servicios;
  final String estado;

  factory Comision.fromJson(Map<String, dynamic> json) {
    final dynamic profesional = json['profesional'];
    final String nombre = profesional is Map
        ? '${profesional['nombres'] ?? ''} ${profesional['apellidos'] ?? ''}'
            .trim()
        : (json['profesionalNombre'] ?? json['nombreProfesional'] ?? '')
            .toString();
    return Comision(
      id: int.tryParse('${json['id']}') ?? 0,
      profesionalId:
          int.tryParse('${json['profesionalId'] ?? json['profesional_id']}') ??
              0,
      profesionalNombre: nombre,
      total: num.tryParse(
            '${json['total'] ?? json['monto'] ?? json['totalComision'] ?? 0}',
          ) ??
          0,
      liquidacionComisionId: int.tryParse(
            '${json['liquidacionComisionId'] ?? json['cierreId'] ?? 0}',
          ) ??
          0,
      fecha: (json['fecha'] ?? json['fechaCierre'] ?? '').toString(),
      porcentaje:
          num.tryParse('${json['porcentaje'] ?? json['porcentajeComision'] ?? 0}') ??
              0,
      servicios: int.tryParse(
            '${json['servicios'] ?? json['cantidadServicios'] ?? 0}',
          ) ??
          0,
      estado: (json['estado'] ?? '').toString(),
    );
  }
}

class ComisionServicio {
  const ComisionServicio({
    required this.nombre,
    required this.cantidad,
    required this.monto,
    this.precio = 0,
    this.fecha = '',
  });

  final String nombre;
  final String cantidad;
  final num monto;
  final num precio;
  final String fecha;

  factory ComisionServicio.fromJson(Map<String, dynamic> json) {
    final dynamic servicio = json['servicio'];
    final String nombre = servicio is Map
        ? (servicio['nombre'] ?? '').toString()
        : (json['nombre'] ?? json['servicioNombre'] ?? '').toString();
    return ComisionServicio(
      nombre: nombre,
      cantidad: (json['cantidad'] ?? json['servicios'] ?? '1').toString(),
      monto: num.tryParse(
            '${json['valorComision'] ?? json['monto'] ?? json['total'] ?? json['comision'] ?? 0}',
          ) ??
          0,
      precio: num.tryParse('${json['precio'] ?? 0}') ?? 0,
      fecha: (json['fechaServicio'] ?? '').toString(),
    );
  }
}
