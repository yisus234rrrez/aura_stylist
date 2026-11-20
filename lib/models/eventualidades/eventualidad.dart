class Eventualidad {
  const Eventualidad({
    required this.id,
    required this.profesionalId,
    required this.motivo,
    this.observacion = '',
    this.fechaInicio = '',
    this.fechaFin = '',
    this.profesionalNombre = '',
  });

  final int id;
  final int profesionalId;
  final int motivo;
  final String observacion;
  final String fechaInicio;
  final String fechaFin;
  final String profesionalNombre;

  String get motivoTexto {
    const List<String> motivos = <String>[
      'Incapacidad',
      'Permiso',
      'Vacaciones',
      'Calamidad',
      'Otro',
    ];
    return motivo >= 0 && motivo < motivos.length
        ? motivos[motivo]
        : 'Motivo $motivo';
  }

  factory Eventualidad.fromJson(Map<String, dynamic> json) {
    final dynamic periodos = json['periodos'];
    String inicio = (json['fechaInicio'] ?? '').toString();
    String fin = (json['fechaFin'] ?? '').toString();
    if (inicio.isEmpty && periodos is List && periodos.isNotEmpty) {
      final dynamic first = periodos.first;
      if (first is Map) {
        inicio = (first['fechaInicio'] ?? '').toString();
        fin = (first['fechaFin'] ?? '').toString();
      }
    }
    return Eventualidad(
      id: int.tryParse('${json['id']}') ?? 0,
      profesionalId: int.tryParse('${json['profesionalId']}') ?? 0,
      motivo: int.tryParse('${json['motivo']}') ?? 0,
      observacion: (json['observacion'] ?? '').toString(),
      fechaInicio: inicio,
      fechaFin: fin,
      profesionalNombre: (json['profesionalNombre'] ?? '').toString(),
    );
  }
}
