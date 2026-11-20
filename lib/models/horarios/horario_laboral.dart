class HorarioLaboral {
  const HorarioLaboral({
    required this.id,
    required this.profesionalId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    this.tieneAlmuerzo = false,
    this.horaInicioAlmuerzo = '',
    this.horaFinAlmuerzo = '',
    this.profesionalNombre = '',
  });

  final int id;
  final int profesionalId;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool tieneAlmuerzo;
  final String horaInicioAlmuerzo;
  final String horaFinAlmuerzo;
  final String profesionalNombre;

  String get diaNombre {
    const List<String> dias = <String>[
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return diaSemana >= 0 && diaSemana < dias.length
        ? dias[diaSemana]
        : 'Día $diaSemana';
  }

  factory HorarioLaboral.fromJson(Map<String, dynamic> json) {
    final dynamic profesional = json['profesional'];
    final String nombre = profesional is Map
        ? '${profesional['nombres'] ?? ''} ${profesional['apellidos'] ?? ''}'
            .trim()
        : (json['profesionalNombre'] ?? '').toString();
    return HorarioLaboral(
      id: int.tryParse('${json['id']}') ?? 0,
      profesionalId: int.tryParse('${json['profesionalId']}') ?? 0,
      diaSemana: int.tryParse('${json['diaSemana']}') ?? 0,
      horaInicio: (json['horaInicio'] ?? '').toString(),
      horaFin: (json['horaFin'] ?? '').toString(),
      tieneAlmuerzo: json['tieneAlmuerzo'] as bool? ?? false,
      horaInicioAlmuerzo: (json['horaInicioAlmuerzo'] ?? '').toString(),
      horaFinAlmuerzo: (json['horaFinAlmuerzo'] ?? '').toString(),
      profesionalNombre: nombre,
    );
  }

  Map<String, dynamic> toCreateJson() => <String, dynamic>{
        'profesionalId': profesionalId,
        'diaSemana': diaSemana,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'tieneAlmuerzo': tieneAlmuerzo,
        'horaInicioAlmuerzo': horaInicioAlmuerzo,
        'horaFinAlmuerzo': horaFinAlmuerzo,
      };

  Map<String, dynamic> toUpdateJson() => <String, dynamic>{
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'tieneAlmuerzo': tieneAlmuerzo,
        'horaInicioAlmuerzo': horaInicioAlmuerzo,
        'horaFinAlmuerzo': horaFinAlmuerzo,
      };
}
