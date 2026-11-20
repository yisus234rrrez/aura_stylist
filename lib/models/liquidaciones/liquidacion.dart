class Liquidacion {
  const Liquidacion({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalFacturado,
    required this.subtotalComisionNegocio,
    required this.subtotalComisionProfesionales,
  });

  final int id;
  final String fechaInicio;
  final String fechaFin;
  final double totalFacturado;
  final double subtotalComisionNegocio;
  final double subtotalComisionProfesionales;

  factory Liquidacion.fromJson(Map<String, dynamic> json) {
    return Liquidacion(
      id: int.tryParse('${json['id']}') ?? 0,
      fechaInicio: (json['fechaInicio'] ?? '').toString(),
      fechaFin: (json['fechaFin'] ?? '').toString(),
      totalFacturado: double.tryParse('${json['totalFacturado']}') ?? 0,
      subtotalComisionNegocio:
          double.tryParse('${json['subtotalComisionNegocio']}') ?? 0,
      subtotalComisionProfesionales:
          double.tryParse('${json['subtotalComisionProfesionales']}') ?? 0,
    );
  }
}
