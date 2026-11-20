

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_stylist/routes/app_router.dart';
import 'package:aura_stylist/routes/app_routes.dart';
import 'package:aura_stylist/screens/ausencias/absence_form.dart';
import 'package:aura_stylist/screens/agenda/agenda.dart';
import 'package:aura_stylist/screens/personas/client_form.dart';
import 'package:aura_stylist/screens/personas/client_list.dart';
import 'package:aura_stylist/screens/nomina/closure_form.dart';
import 'package:aura_stylist/screens/nomina/closure_detail.dart';
import 'package:aura_stylist/screens/nomina/closure_list.dart';
import 'package:aura_stylist/screens/nomina/commission_list.dart';
import 'package:aura_stylist/screens/nomina/commission_detail.dart';
import 'package:aura_stylist/routes/app_route_args.dart';
import 'package:aura_stylist/screens/agenda/schedule.dart';
import 'package:aura_stylist/services/remote/aura_api.dart';
import 'package:aura_stylist/screens/inicio/dashboard.dart';
import 'package:aura_stylist/screens/auth/login.dart';
import 'package:aura_stylist/screens/personas/professional_form.dart';
import 'package:aura_stylist/screens/reservas/reservation_form.dart';
import 'package:aura_stylist/screens/reservas/reservation_detail.dart';
import 'package:aura_stylist/screens/reservas/reservation_cancel.dart';
import 'package:aura_stylist/screens/nomina/service_history.dart';
import 'package:aura_stylist/screens/catalogo/service_list.dart';
import 'package:aura_stylist/screens/catalogo/service_new.dart';
import 'package:aura_stylist/screens/catalogo/specialty_list.dart';
import 'package:aura_stylist/screens/agenda/shift_form.dart';
import 'package:aura_stylist/theme/app_theme.dart';
import 'package:aura_stylist/widgets/app_header.dart';
import 'package:aura_stylist/widgets/app_pickers.dart';
import 'package:aura_stylist/widgets/app_success_toast.dart';

import 'test_api.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: child,
    onGenerateRoute: AppRouter.onGenerateRoute,
  );
}

void _phoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(configureMockApi);

  testWidgets('Login inválido muestra el banner de error', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const LoginScreen()));

    await tester.enterText(find.byType(TextField).first, 'sin-arroba');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Acceso no autorizado'), findsOneWidget);
  });




  testWidgets('Cliente: guardar sin documento muestra validación', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClientFormScreen()));

    await tester.tap(find.text('Guardar cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa el documento de identidad.'), findsOneWidget);
  });

  testWidgets('Clientes: el buscador filtra la lista', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClientListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Valentina Restrepo Duque'), findsOneWidget);
    expect(find.text('Camila Morales Gómez'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Camila');
    await tester.pumpAndSettle();

    expect(find.text('Camila Morales Gómez'), findsOneWidget);
    expect(find.text('Valentina Restrepo Duque'), findsNothing);
  });

  testWidgets('Servicios: el buscador filtra y ⋮ duplicar responde', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ServiceListScreen()));

    await tester.enterText(find.byType(TextField).first, 'Manicure');
    await tester.pumpAndSettle();

    expect(find.text('Manicure Spa Ruso'), findsOneWidget);
    expect(find.text('Balayage Iluminado Botánico'), findsNothing);

    await tester.ensureVisible(find.byIcon(Icons.more_vert).first);
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Servicio duplicado.'), findsOneWidget);
  });

  testWidgets('Inasistencias: el selector de profesional abre opciones', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const AbsenceFormScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selecciona un profesional'));
    await tester.pumpAndSettle();

    expect(find.text('Laura Gómez Restrepo'), findsOneWidget);
    expect(find.text('Sofía Peña Valderrama'), findsOneWidget);
  });

  testWidgets('Agenda: el filtro de profesional abre opciones', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const AgendaScreen()));

    await tester.tap(find.text('Todos').first);
    await tester.pumpAndSettle();

    expect(find.text('Profesional'), findsWidgets);
    expect(find.text('Laura Gómez Restrepo'), findsWidgets);
  });

  testWidgets('Agenda: muestra el estado real de la reserva', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const AgendaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Completada'), findsOneWidget);
    expect(find.text('Valentina Restrepo Duque'), findsOneWidget);
  });

  testWidgets('Cancelar reserva confirma y muestra el estado Cancelada', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      _host(
        const ReservationCancelScreen(
          initial: ReservationRouteArgs(
            id: 5,
            clientName: 'Valentina Restrepo',
            serviceName: 'Corte de Cabello',
            professionalName: 'Camila Torres',
            dateLong: 'Viernes, 20 de Noviembre de 2026',
            time: '09:00 – 09:45',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar Reserva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar reserva').last);
    await tester.pumpAndSettle();

    expect(find.text('Cancelada'), findsWidgets);
  });

  testWidgets('Agenda: muestra las canceladas del día', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const AgendaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Canceladas y reagendadas'), findsOneWidget);
    expect(find.text('Cancelada'), findsOneWidget);
    expect(find.text('Camila Morales Gómez'), findsOneWidget);
  });

  testWidgets('Dashboard: muestra métricas reales de la API', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('RESERVAS DE HOY'), findsOneWidget);
    expect(find.text('cita pautada'), findsOneWidget);
    expect(find.text('No hay próximas reservas para hoy.'), findsOneWidget);
  });

  testWidgets('Cierre: arranca con el mes actual', (WidgetTester tester) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClosureFormScreen()));
    await tester.pumpAndSettle();

    final DateTime now = DateTime.now();
    expect(
      find.text(formatAppDate(DateTime(now.year, now.month, 1))),
      findsOneWidget,
    );
    expect(find.text(formatAppDate(now)), findsOneWidget);
  });

  testWidgets('Cierres: marca los cierres sin movimientos', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClosureListScreen()));
    await tester.pumpAndSettle();

    const List<String> months = <String>[
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final int previousMonth = DateTime.now().month == 1
        ? 12
        : DateTime.now().month - 1;
    await tester.tap(find.text(months[previousMonth - 1]));
    await tester.pumpAndSettle();

    expect(find.text('Sin movimientos'), findsOneWidget);
    expect(find.text('Cerrado'), findsOneWidget);
  });

  testWidgets('Detalle de cierre abre el cierre seleccionado', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClosureDetailScreen(id: 1)));
    await tester.pumpAndSettle();

    expect(find.text('LIE-1'), findsOneWidget);
    expect(find.text('2026-10-01 - 2026-10-15'), findsOneWidget);
  });

  testWidgets('Horarios: muestra el profesional real y permite editar', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ScheduleScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Laura Gómez Restrepo'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('9 horas programadas / semana'), findsOneWidget);

    await tester.tap(find.text('Lunes'));
    await tester.pumpAndSettle();
    expect(find.text('Editar Lunes'), findsOneWidget);
    expect(find.text('Guardar jornada'), findsOneWidget);
  });

  testWidgets('Especialidades: duplicar crea una copia', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const SpecialtyListScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Especialidad duplicada.'), findsOneWidget);
  });

  testWidgets('Detalle de reserva muestra los datos reales del cliente', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      _host(
        const ReservationDetailScreen(
          initial: ReservationRouteArgs(
            id: 5,
            clienteId: 2,
            clientName: 'Camila Morales Gómez',
            clientDocument: '1020481230',
            serviceName: 'Manicure Spa Ruso',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+57 315 890 2341'), findsOneWidget);
    expect(find.text('camila.morales@outlook.com'), findsOneWidget);
    expect(find.text('Cita #RES-5'), findsOneWidget);
  });

  testWidgets('Detalle de reserva muestra el estado recibido', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      _host(const ReservationDetailScreen(status: 'Completada')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Completada'), findsOneWidget);
  });

  test('Liquidaciones: ultimo=true devuelve un objeto y no revienta', () async {
    final response = await AuraApi.liquidaciones.list(ultimo: true);

    expect(response.isSuccess, isTrue);
    expect(response.data, isNotEmpty);
  });

  testWidgets('Detalle de comisión muestra el desglose real', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      _host(
        const CommissionDetailScreen(
          initial: CommissionRouteArgs(
            id: 7,
            liquidacionId: 18,
            professionalName: 'Camila Torres',
            total: 24500,
            percentage: 35,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camila Torres'), findsOneWidget);
    expect(find.text('Corte de Cabello'), findsOneWidget);
    expect(find.text('Liquidada · cierre #18'), findsOneWidget);
  });

  testWidgets('Cierre: confirmar abre el diálogo y permite cerrar periodo', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClosureFormScreen()));

    await tester.ensureVisible(find.text('Confirmar cierre'));
    await tester.tap(find.text('Confirmar cierre'));
    await tester.pumpAndSettle();

    expect(find.text('Cerrar periodo'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('Header: campana y avatar responden', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      _host(
        const Scaffold(body: AppHeader(section: 'Inicio')),
      ),
    );

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();
    expect(find.text('Notificaciones'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('Dashboard: "Lista" abre los accesos en formato lista', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const DashboardScreen()));

    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();

    expect(find.text('Accesos rápidos'), findsOneWidget);
    expect(find.text('Comisiones'), findsWidgets);
  });

  testWidgets('Header: flecha atrás solo cuando hay ruta anterior', (
    WidgetTester tester,
  ) async {

    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Column(
              children: [
                const AppHeader(section: 'Servicios'),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(
                          body: AppHeader(section: 'Servicios'),
                        ),
                      ),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsNothing);
  });

  testWidgets('Toast de éxito se cierra con la X', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: AppSuccessToast(title: 'Guardado', message: 'Todo bien'),
        ),
      ),
    );

    expect(find.text('Guardado'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Guardado'), findsNothing);
  });

  testWidgets('Nueva reserva: buscar y seleccionar cliente', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ReservationFormScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Camila',
    );
    await tester.pumpAndSettle();

    expect(find.text('Camila Morales Gómez'), findsWidgets);

    await tester.tap(find.text('Camila Morales Gómez').first);
    await tester.pumpAndSettle();


    expect(find.text('Camila Morales Gómez'), findsWidgets);
    expect(find.text('Sin resultados para la búsqueda.'), findsNothing);
  });

  testWidgets('Nueva reserva: confirmar crea la reserva en la API', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ReservationFormScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Camila');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camila Morales Gómez').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Selecciona un horario'));
    await tester.tap(find.text('Selecciona un horario'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('08:00 AM'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar a Confirmación'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmación de Reserva'), findsOneWidget);

    await tester.tap(find.text('Confirmar Reserva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Reserva creada correctamente'), findsOneWidget);
  });

  testWidgets('Nueva reserva: volver no regresa al formulario', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: Text('Inicio'))),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    navKey.currentState!.pushNamed(AppRoutes.newReservation);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Camila');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camila Morales Gómez').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Selecciona un horario'));
    await tester.tap(find.text('Selecciona un horario'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('08:00 AM'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar a Confirmación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar Reserva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva creada correctamente'), findsOneWidget);

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Nueva Reserva'), findsNothing);
  });

  testWidgets('Nuevo servicio: valida la especialidad', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ServiceNewScreen()));

    await tester.tap(find.text('Guardar servicio'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona una especialidad.'), findsOneWidget);
  });

  testWidgets('Profesional: valida el documento', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ProfessionalFormScreen()));

    await tester.tap(find.text('Guardar profesional'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa el documento de identidad.'), findsOneWidget);
  });

  testWidgets('Jornada: valida el profesional', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ShiftFormScreen()));

    await tester.tap(find.text('Agregar jornada').last);
    await tester.pumpAndSettle();

    expect(find.text('Selecciona un día de la semana.'), findsOneWidget);
  });

  testWidgets('Cierres: el chip de mes filtra el historial', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClosureListScreen()));
    await tester.pumpAndSettle();


    expect(
      find.text('No hay cierres que coincidan con el filtro.'),
      findsOneWidget,
    );

    const List<String> months = <String>[
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final int previousMonth = DateTime.now().month == 1
        ? 12
        : DateTime.now().month - 1;
    await tester.tap(find.text(months[previousMonth - 1]));
    await tester.pumpAndSettle();

    expect(
      find.text('No hay cierres que coincidan con el filtro.'),
      findsNothing,
    );
  });

  testWidgets('Comisiones: el filtro por profesional reduce la lista', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const CommissionListScreen()));

    await tester.tap(find.text('Todos los profesionales'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sofía P.').last);
    await tester.pumpAndSettle();

    expect(find.text('Sofía P.'), findsWidgets);
    expect(find.text('Laura G.'), findsNothing);
  });

  testWidgets('Servicios realizados: muestra el historial desde la API', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ServiceHistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Servicios Realizados'), findsOneWidget);
    expect(find.text('TOTAL FACTURADO'), findsOneWidget);
    expect(find.text('REALIZADOS'), findsOneWidget);
  });

  testWidgets('Servicios: editar abre el registro seleccionado', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ServiceListScreen()));

    await tester.enterText(find.byType(TextField).first, 'Manicure');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('Manicure Spa Ruso'), findsWidgets);
    expect(find.text('Balayage Iluminado Botánico'), findsNothing);
  });

  testWidgets('Clientes: Ver ficha abre el cliente seleccionado', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(_host(const ClientListScreen()));

    await tester.enterText(find.byType(TextField).first, 'Camila');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver ficha').first);
    await tester.pumpAndSettle();

    expect(find.text('Camila'), findsWidgets);
    expect(find.text('Valentina'), findsNothing);
  });
}