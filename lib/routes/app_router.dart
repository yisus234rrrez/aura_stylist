import 'package:flutter/material.dart';

import '../screens/inicio/dashboard.dart';
import '../screens/ausencias/absence_list.dart';
import '../screens/agenda/agenda.dart';
import '../screens/agenda/shift_form.dart';
import '../screens/personas/client_form.dart';
import '../screens/personas/client_list.dart';
import '../screens/reservas/reservation_cancel.dart';
import '../screens/nomina/closure_detail.dart';
import '../screens/nomina/closure_list.dart';
import '../screens/nomina/commission_detail.dart';
import '../screens/nomina/commission_list.dart';
import '../screens/catalogo/service_edit.dart';
import '../screens/catalogo/specialty_edit.dart';
import '../screens/auth/login.dart';
import '../screens/inicio/menu.dart';
import '../screens/catalogo/service_new.dart';
import '../screens/reservas/reservation_form.dart';
import '../screens/nomina/closure_form.dart';
import '../screens/catalogo/specialty_new.dart';
import '../screens/personas/professional_form.dart';
import '../screens/agenda/schedule.dart';
import '../screens/personas/professional_list.dart';
import '../screens/ausencias/absence_form.dart';
import '../screens/reservas/reservation_reschedule.dart';
import '../screens/reservas/reservation_confirm.dart';
import '../screens/reservas/reservation_detail.dart';
import '../screens/catalogo/service_list.dart';
import '../screens/nomina/service_history.dart';
import '../screens/catalogo/specialty_list.dart';
import '../screens/auth/splash.dart';
import 'app_route_args.dart';
import 'app_routes.dart';





abstract class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.loginError:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(showAuthError: true),
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );
      case AppRoutes.menu:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MenuScreen(),
        );
      case AppRoutes.specialties:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SpecialtyListScreen(),
        );
      case AppRoutes.specialtyNew:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SpecialtyNewScreen(),
        );
      case AppRoutes.specialtyEdit:
        final SpecialtyRouteArgs specialtyArgs = settings.arguments
                is SpecialtyRouteArgs
            ? settings.arguments! as SpecialtyRouteArgs
            : const SpecialtyRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SpecialtyEditScreen(initial: specialtyArgs),
        );
      case AppRoutes.specialtyInactive:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SpecialtyEditScreen(
            title: 'Especialidad · Inactiva',
            initialActive: false,
            showToast: true,
          ),
        );
      case AppRoutes.services:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ServiceListScreen(),
        );
      case AppRoutes.servicesEmpty:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ServiceListScreen(empty: true),
        );
      case AppRoutes.serviceNew:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ServiceNewScreen(),
        );
      case AppRoutes.serviceEdit:
        final ServiceRouteArgs serviceArgs = settings.arguments
                is ServiceRouteArgs
            ? settings.arguments! as ServiceRouteArgs
            : const ServiceRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ServiceEditScreen(initial: serviceArgs),
        );
      case AppRoutes.serviceInactive:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ServiceEditScreen(
            title: 'Servicio · Inactivo',
            initialActive: false,
            showToast: true,
          ),
        );
      case AppRoutes.professionals:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfessionalListScreen(),
        );
      case AppRoutes.professionalNew:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfessionalFormScreen(),
        );
      case AppRoutes.professionalEdit:
        final ProfessionalRouteArgs professionalArgs = settings.arguments
                is ProfessionalRouteArgs
            ? settings.arguments! as ProfessionalRouteArgs
            : const ProfessionalRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProfessionalFormScreen(
            title: 'Editar Profesional',
            badge: 'PROF-08',
            isEdit: true,
            initial: professionalArgs,
          ),
        );
      case AppRoutes.professionalInactive:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfessionalFormScreen(
            title: 'Profesional · Inactivo',
            badge: 'PROF-08',
            isEdit: true,
            showToast: true,
          ),
        );
      case AppRoutes.professionalValidation:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfessionalFormScreen(
            title: 'Validación de datos',
            badge: 'PROF-08',
            isEdit: true,
            commissionError: true,
          ),
        );
      case AppRoutes.schedule:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ScheduleScreen(),
        );
      case AppRoutes.scheduleAdded:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ScheduleScreen(showToast: true),
        );
      case AppRoutes.addShift:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ShiftFormScreen(),
        );
      case AppRoutes.absences:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AbsenceListScreen(),
        );
      case AppRoutes.registerAbsence:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AbsenceFormScreen(),
        );
      case AppRoutes.clients:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientListScreen(),
        );
      case AppRoutes.clientsSaved:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientListScreen(showToast: true),
        );
      case AppRoutes.clientNew:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClientFormScreen(),
        );
      case AppRoutes.clientEdit:
        final ClientRouteArgs clientArgs = settings.arguments
                is ClientRouteArgs
            ? settings.arguments! as ClientRouteArgs
            : const ClientRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClientFormScreen(
            isEdit: true,
            initial: clientArgs,
          ),
        );
      case AppRoutes.agenda:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AgendaScreen(),
        );
      case AppRoutes.agendaCalendar:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AgendaScreen(calendarView: true),
        );
      case AppRoutes.newReservation:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ReservationFormScreen(),
        );
      case AppRoutes.reservationConfirmation:
        final ReservationRouteArgs confirmationArgs = settings.arguments
                is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationConfirmScreen(initial: confirmationArgs),
        );
      case AppRoutes.reservationCreated:
        final ReservationRouteArgs createdArgs = settings.arguments
                is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationDetailScreen(
            showToast: true,
            toastTitle: 'Reserva creada correctamente',
            toastMessage:
                'La reserva quedó registrada en la agenda y se notificó a la '
                'clienta.',
            initial: createdArgs,
          ),
        );
      case AppRoutes.reservationDetail:
        final ReservationRouteArgs reservationArgs = settings.arguments
                is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationDetailScreen(initial: reservationArgs),
        );
      case AppRoutes.rescheduleReservation:
        final ReservationRouteArgs rescheduleArgs =
            settings.arguments is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationRescheduleScreen(initial: rescheduleArgs),
        );
      case AppRoutes.reservationRescheduled:
        final ReservationRouteArgs rescheduledArgs =
            settings.arguments is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationDetailScreen(
            showToast: true,
            toastTitle: 'Reserva actualizada correctamente',
            toastMessage:
                'Se actualizó el turno en la agenda y se notificó a la '
                'clienta.',
            initial: rescheduledArgs,
          ),
        );
      case AppRoutes.cancelReservation:
        final ReservationRouteArgs cancelArgs =
            settings.arguments is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationCancelScreen(initial: cancelArgs),
        );
      case AppRoutes.reservationCancelled:
        final ReservationRouteArgs cancelledArgs =
            settings.arguments is ReservationRouteArgs
            ? settings.arguments! as ReservationRouteArgs
            : const ReservationRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ReservationDetailScreen(
            status: 'Cancelada',
            initial: cancelledArgs,
          ),
        );
      case AppRoutes.reservationAttended:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ReservationDetailScreen(status: 'Atendida'),
        );
      case AppRoutes.servicesDone:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ServiceHistoryScreen(),
        );
      case AppRoutes.closures:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClosureListScreen(),
        );
      case AppRoutes.newClosure:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ClosureFormScreen(),
        );
      case AppRoutes.closureDetail:
        final int detailId = settings.arguments is int
            ? settings.arguments! as int
            : 0;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ClosureDetailScreen(id: detailId),
        );
      case AppRoutes.closureCreated:
        final int createdId = settings.arguments is int
            ? settings.arguments! as int
            : 0;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              ClosureDetailScreen(id: createdId, showToast: true),
        );
      case AppRoutes.commissions:
        final int liquidationId = settings.arguments is int
            ? settings.arguments! as int
            : 0;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => CommissionListScreen(liquidationId: liquidationId),
        );
      case AppRoutes.commissionsFiltered:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => CommissionListScreen(
            filtered: true,
            liquidationId: settings.arguments is int
                ? settings.arguments! as int
                : 0,
          ),
        );
      case AppRoutes.commissionDetail:
        final CommissionRouteArgs commissionArgs = settings.arguments
                is CommissionRouteArgs
            ? settings.arguments! as CommissionRouteArgs
            : const CommissionRouteArgs();
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => CommissionDetailScreen(initial: commissionArgs),
        );
      default:
        return null;
    }
  }
}
