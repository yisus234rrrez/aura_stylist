



class ClientRouteArgs {
  const ClientRouteArgs({
    this.id = 0,
    this.documentType = 'C.C.',
    this.document = '',
    this.names = '',
    this.lastNames = '',
    this.birthDate = '',
    this.phone = '',
    this.email = '',
  });

  final int id;
  final String documentType;
  final String document;
  final String names;
  final String lastNames;
  final String birthDate;
  final String phone;
  final String email;
}

class ProfessionalRouteArgs {
  const ProfessionalRouteArgs({
    this.id = 0,
    this.document = '',
    this.names = '',
    this.lastNames = '',
    this.birthDate = '',
    this.commission = '',
    this.specialty = '',
    this.specialtyId = 0,
    this.active = true,
  });

  final int id;
  final String document;
  final String names;
  final String lastNames;
  final String birthDate;
  final String commission;
  final String specialty;
  final int specialtyId;
  final bool active;
}

class ServiceRouteArgs {
  const ServiceRouteArgs({
    this.id = 0,
    this.code = '',
    this.name = '',
    this.category = '',
    this.duration = '',
    this.price = '',
    this.description = '',
    this.specialtyId = 0,
    this.active = true,
  });

  final int id;
  final String code;
  final String name;
  final String category;
  final String duration;
  final String price;
  final String description;
  final int specialtyId;
  final bool active;
}

class SpecialtyRouteArgs {
  const SpecialtyRouteArgs({
    this.id = 0,
    this.name = '',
    this.description = '',
  });

  final int id;
  final String name;
  final String description;
}

class CommissionRouteArgs {
  const CommissionRouteArgs({
    this.id = 0,
    this.liquidacionId = 0,
    this.professionalName = '',
    this.total = 0,
    this.percentage = 0,
  });

  final int id;
  final int liquidacionId;
  final String professionalName;
  final num total;
  final num percentage;
}

class ReservationRouteArgs {
  const ReservationRouteArgs({
    this.id = 0,
    this.clienteId = 0,
    this.servicioId = 0,
    this.profesionalId = 0,
    this.fechaHora = '',
    this.estado = '',
    this.clientName = '',
    this.clientDocument = '',
    this.clientInitials = '',
    this.serviceName = '',
    this.professionalName = '',
    this.price = '',
    this.duration = '',
    this.dayLabel = '',
    this.dayNumber = '',
    this.dateLong = '',
    this.time = '',
  });

  final int id;
  final int clienteId;
  final int servicioId;
  final int profesionalId;
  final String fechaHora;
  final String estado;
  final String clientName;
  final String clientDocument;
  final String clientInitials;
  final String serviceName;
  final String professionalName;
  final String price;
  final String duration;
  final String dayLabel;
  final String dayNumber;
  final String dateLong;
  final String time;
}
