




abstract class AppRoutes {

  static const String splash = '/';
  static const String login = '/login';
  static const String loginError = '/login/error';


  static const String dashboard = '/dashboard';
  static const String menu = '/menu';


  static const String specialties = '/specialties';
  static const String specialtyNew = '/specialty-new';
  static const String specialtyEdit = '/specialty-edit';
  static const String specialtyInactive = '/specialty-inactive';


  static const String services = '/services';
  static const String servicesEmpty = '/services-empty';
  static const String serviceNew = '/service-new';
  static const String serviceEdit = '/service-edit';
  static const String serviceInactive = '/service-inactive';


  static const String professionals = '/professionals';
  static const String professionalNew = '/professional-new';
  static const String professionalEdit = '/professional-edit';
  static const String professionalInactive = '/professional-inactive';
  static const String professionalValidation = '/professional-validation';


  static const String schedule = '/schedule';
  static const String scheduleAdded = '/schedule-added';
  static const String addShift = '/add-shift';
  static const String absences = '/absences';
  static const String registerAbsence = '/register-absence';


  static const String clients = '/clients';
  static const String clientsSaved = '/clients-saved';
  static const String clientNew = '/client-new';
  static const String clientEdit = '/client-edit';


  static const String agenda = '/agenda';
  static const String agendaCalendar = '/agenda-calendar';
  static const String newReservation = '/new-reservation';
  static const String reservationConfirmation = '/reservation-confirmation';


  static const String reservationCreated = '/reservation-created';
  static const String reservationDetail = '/reservation-detail';
  static const String rescheduleReservation = '/reschedule-reservation';
  static const String reservationRescheduled = '/reservation-rescheduled';
  static const String cancelReservation = '/cancel-reservation';
  static const String reservationCancelled = '/reservation-cancelled';
  static const String reservationAttended = '/reservation-attended';


  static const String servicesDone = '/services-done';


  static const String closures = '/closures';
  static const String newClosure = '/new-closure';
  static const String closureDetail = '/closure-detail';
  static const String closureCreated = '/closure-created';
  static const String commissions = '/commissions';
  static const String commissionsFiltered = '/commissions-filtered';
  static const String commissionDetail = '/commission-detail';
}
