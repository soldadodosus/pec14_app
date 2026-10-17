// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pec14_app/app/app.dart';
import 'package:pec14_app/modules/calculator/calculator.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const Pec14App());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(materialApp.locale, const Locale('pt', 'BR'));
  });

  testWidgets('Calculator form uses numeric keyboard for value fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(locale: Locale('pt', 'BR'), home: CalculadoraView()),
    );

    await tester.pumpAndSettle();

    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    expect(textFields.length, 4);
    expect(
      textFields.every((field) => field.keyboardType == TextInputType.number),
      isTrue,
    );
  });
}
