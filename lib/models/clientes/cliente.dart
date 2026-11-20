class Cliente {
  const Cliente({
    required this.id,
    required this.documento,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.celular = '',
    this.correo = '',
  });

  final int id;
  final String documento;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String celular;
  final String correo;

  String get nombreCompleto => '$nombres $apellidos'.trim();
  String get iniciales {
    final String n = nombres.trim();
    final String a = apellidos.trim();
    return '${n.isEmpty ? '' : n[0]}${a.isEmpty ? '' : a[0]}'.toUpperCase();
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: _asInt(json['id']),
      documento: (json['documento'] ?? '').toString(),
      nombres: (json['nombres'] ?? '').toString(),
      apellidos: (json['apellidos'] ?? '').toString(),
      fechaNacimiento: _asDate(json['fechaNacimiento']),
      celular: (json['celular'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toCreateJson() => <String, dynamic>{
        'documento': documento,
        'nombres': nombres,
        'apellidos': apellidos,
        'fechaNacimiento': _dateOnly(fechaNacimiento),
        'celular': celular,
        'correo': correo,
      };

  Map<String, dynamic> toUpdateJson() => toCreateJson();

  static int _asInt(dynamic value) => int.tryParse('$value') ?? 0;

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _dateOnly(DateTime? value) {
    if (value == null) return null;
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
