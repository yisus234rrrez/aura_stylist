class AgendaDay {
  const AgendaDay({
    required this.profesionalId,
    required this.profesionalNombre,
    required this.totalSlots,
    required this.totalDisponibles,
    required this.totalOcupados,
    required this.slots,
  });

  final int profesionalId;
  final String profesionalNombre;
  final int totalSlots;
  final int totalDisponibles;
  final int totalOcupados;
  final List<AgendaTimeSlot> slots;

  factory AgendaDay.fromJson(Map<String, dynamic> json) {
    final dynamic rawSlots = json['slots'];
    return AgendaDay(
      profesionalId: int.tryParse('${json['profesionalId']}') ?? 0,
      profesionalNombre: (json['profesionalNombre'] ?? '').toString(),
      totalSlots: int.tryParse('${json['totalSlots']}') ?? 0,
      totalDisponibles: int.tryParse('${json['totalDisponibles']}') ?? 0,
      totalOcupados: int.tryParse('${json['totalOcupados']}') ?? 0,
      slots: rawSlots is List
          ? rawSlots
              .whereType<Map<String, dynamic>>()
              .map(AgendaTimeSlot.fromJson)
              .toList()
          : <AgendaTimeSlot>[],
    );
  }
}

class AgendaTimeSlot {
  const AgendaTimeSlot({
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
    this.reserva,
  });

  final String horaInicio;
  final String horaFin;
  final bool disponible;
  final Map<String, dynamic>? reserva;

  factory AgendaTimeSlot.fromJson(Map<String, dynamic> json) {
    final dynamic rawReserva = json['reserva'];
    return AgendaTimeSlot(
      horaInicio: (json['horaInicio'] ?? '').toString(),
      horaFin: (json['horaFin'] ?? '').toString(),
      disponible: json['disponible'] as bool? ?? false,
      reserva: rawReserva is Map<String, dynamic> ? rawReserva : null,
    );
  }
}
