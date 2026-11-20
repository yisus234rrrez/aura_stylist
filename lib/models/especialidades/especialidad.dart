class Especialidad {
  const Especialidad({
    required this.id,
    required this.nombre,
    this.activa = true,
  });

  final int id;
  final String nombre;
  final bool activa;

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      id: int.tryParse('${json['id']}') ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      activa: json['activa'] as bool? ?? true,
    );
  }
}
