


import 'package:flutter_test/flutter_test.dart';

import 'package:aura_stylist/models/reservas/reserva.dart';

void main() {
  test('0 se muestra como Agendada', () {
    expect(estadoReservaTexto(0), 'Agendada');
  });

  test('1 se muestra como Cancelada', () {
    expect(estadoReservaTexto(1), 'Cancelada');
  });

  test('2 se muestra como Completada', () {
    expect(estadoReservaTexto(2), 'Completada');
  });

  test('3 se muestra como Reagendada', () {
    expect(estadoReservaTexto(3), 'Reagendada');
  });
}
