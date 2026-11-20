


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_stylist/theme/app_theme.dart';
import 'package:aura_stylist/widgets/app_pickers.dart';

void main() {
  testWidgets('El selector de opciones hace scroll sin desbordarse', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showAppOptionPicker(
                  context,
                  title: 'Horario disponible',
                  options: List<String>.generate(
                    20,
                    (int i) => '2026-11-18 08:${i.toString().padLeft(2, '0')}',
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Horario disponible'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
