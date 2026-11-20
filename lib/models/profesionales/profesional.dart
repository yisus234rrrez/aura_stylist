import '../especialidades/especialidad.dart';

class Profesional {
  const Profesional({
    required this.id,
    required this.documento,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.porcentaje = 0,
    this.estado = true,
    this.fotoPerfil = '',
    this.especialidadId = 0,
    this.especialidad,
  });

  final int id;
  final String documento;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final double porcentaje;
  final bool estado;
  final String fotoPerfil;
  final int especialidadId;
  final Especialidad? especialidad;

  String get nombreCompleto => '$nombres $apellidos'.trim();
  String get iniciales {
    final String n = nombres.trim();
    final String a = apellidos.trim();
    return '${n.isEmpty ? '' : n[0]}${a.isEmpty ? '' : a[0]}'.toUpperCase();
  }

  factory Profesional.fromJson(Map<String, dynamic> json) {
    final dynamic specialty = json['especialidad'];
    return Profesional(
      id: int.tryParse('${json['id']}') ?? 0,
      documento: (json['documento'] ?? '').toString(),
      nombres: (json['nombres'] ?? '').toString(),
      apellidos: (json['apellidos'] ?? '').toString(),
      fechaNacimiento: json['fechaNacimiento'] == null
          ? null
          : DateTime.tryParse(json['fechaNacimiento'].toString()),
      porcentaje: double.tryParse('${json['porcentaje']}') ?? 0,
      estado: json['estado'] as bool? ?? true,
      fotoPerfil: (json['fotoPerfil'] ?? '').toString(),
      especialidadId: int.tryParse('${json['especialidadId']}') ?? 0,
      especialidad: specialty is Map<String, dynamic>
          ? Especialidad.fromJson(specialty)
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() => <String, dynamic>{
        'documento': documento,
        'nombres': nombres,
        'apellidos': apellidos,
        'fechaNacimiento': _dateOnly(fechaNacimiento),
        'porcentaje': porcentaje,
        'estado': estado,
        'especialidad': especialidadId,
      };

  Map<String, dynamic> toUpdateJson() => <String, dynamic>{
        'documento': documento,
        'nombres': nombres,
        'apellidos': apellidos,
        'fechaNacimiento': _dateOnly(fechaNacimiento),
        'porcentaje': porcentaje,
        'estado': estado,
      };

  static String? _dateOnly(DateTime? value) {
    if (value == null) return null;
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
