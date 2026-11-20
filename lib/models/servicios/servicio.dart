class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion = '',
    this.duracion = 0,
    this.activo = true,
    this.especialidadId = 0,
  });

  final int id;
  final String nombre;
  final num precio;
  final String descripcion;
  final int duracion;
  final bool activo;
  final int especialidadId;

  String get precioTexto {
    final String value = precio == precio.roundToDouble()
        ? precio.toInt().toString()
        : precio.toString();
    return '\$$value COP';
  }

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: int.tryParse('${json['id']}') ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      precio: num.tryParse('${json['precio']}') ?? 0,
      descripcion: (json['descripcion'] ?? '').toString(),
      duracion: int.tryParse('${json['duracion']}') ?? 0,
      activo: json['activo'] as bool? ?? true,
      especialidadId: int.tryParse('${json['especialidadId']}') ?? 0,
    );
  }

  Map<String, dynamic> toCreateJson() => <String, dynamic>{
        'nombre': nombre,
        'precio': precio,
        'descripcion': descripcion,
        'duracion': duracion,
        'especialidad': especialidadId,
      };

  Map<String, dynamic> toUpdateJson() => <String, dynamic>{
        'nombre': nombre,
        'precio': precio,
        'activo': activo,
        'duracion': duracion,
      };
}
