

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_stylist/main.dart';
import 'package:aura_stylist/screens/auth/login.dart';

import 'test_api.dart';

void _phoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _goToLogin(WidgetTester tester) async {
  await tester.pumpWidget(const AuraStylistApp());
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  setUp(configureMockApi);

  testWidgets('El Splash muestra la marca y navega al Login', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await _goToLogin(tester);

    expect(find.text('Bienvenido a Aura Stylist'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('Login -> Dashboard', (WidgetTester tester) async {
    _phoneSurface(tester);
    await _goToLogin(tester);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Administrador'), findsOneWidget);
    expect(find.text('Accesos Rápidos'), findsOneWidget);
  });

  testWidgets('Dashboard -> Menú', (WidgetTester tester) async {
    _phoneSurface(tester);
    await _goToLogin(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    expect(find.text('Gestiona Aura Stylist'), findsOneWidget);
    expect(find.text('Especialidades'), findsOneWidget);
  });

  testWidgets('Menú -> Especialidades', (WidgetTester tester) async {
    _phoneSurface(tester);
    await _goToLogin(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Especialidades'));
    await tester.pumpAndSettle();
    expect(
      find.text('Catálogo de líneas maestras y servicios'),
      findsOneWidget,
    );
    expect(find.text('Nueva'), findsOneWidget);
  });

  testWidgets('Especialidades -> Nueva Especialidad', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await _goToLogin(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Especialidades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva'));
    await tester.pumpAndSettle();
    expect(find.text('Nueva Especialidad'), findsOneWidget);
    expect(find.text('Guardar especialidad'), findsOneWidget);
  });

  testWidgets('Dashboard Accesos Rápidos -> Agenda, y navbar -> Clientes', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await _goToLogin(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agenda').first);
    await tester.pumpAndSettle();
    expect(find.text('Vista Lista'), findsOneWidget);

    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Clientes registrados'), findsOneWidget);
  });

  testWidgets('Especialidades: el menú ⋮ abre las opciones', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await _goToLogin(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Especialidades'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    expect(find.text('Editar especialidad'), findsOneWidget);
  });

  testWidgets('Agenda: el toggle Vista Calendario navega', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await _goToLogin(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agenda').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vista Calendario'));
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
    const List<String> weekdays = <String>[
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final DateTime now = DateTime.now();
    final String todayLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]} '
        'de ${now.year}';
    expect(find.text(todayLabel), findsOneWidget);
  });

  testWidgets('Pantalla 03 muestra el banner de error', (
    WidgetTester tester,
  ) async {
    _phoneSurface(tester);
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen(showAuthError: true)),
    );
    await tester.pump();

    expect(find.text('Acceso no autorizado'), findsOneWidget);
    expect(
      find.text('Usuario o contraseña incorrectos. Verifica tus datos.'),
      findsOneWidget,
    );
  });
}
