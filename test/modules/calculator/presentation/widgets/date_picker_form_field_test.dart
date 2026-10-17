import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pec14_app/modules/calculator/presentation/widgets/date_picker_form_field.dart';

void main() {
  Widget buildTestApp({
    required DateTime? initialDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: Scaffold(
        body: DatePickerFormField(
          label: 'Data de nascimento',
          hintText: '',
          initialDate: initialDate,
          onDateSelected: onDateSelected,
        ),
      ),
    );
  }

  testWidgets('formata os números digitados sem abrir o calendário', (
    WidgetTester tester,
  ) async {
    DateTime? dataSelecionada;
    await tester.pumpWidget(
      buildTestApp(
        initialDate: null,
        onDateSelected: (data) => dataSelecionada = data,
      ),
    );

    await tester.enterText(find.byType(TextFormField), '14a08b1985');
    await tester.pump();

    final campo = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(campo.controller!.text, '14/08/1985');
    expect(dataSelecionada, DateTime(1985, 8, 14));
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('data impossível não é enviada como selecionada', (
    WidgetTester tester,
  ) async {
    DateTime? dataSelecionada = DateTime(1985, 8, 14);
    await tester.pumpWidget(
      buildTestApp(
        initialDate: DateTime(1985, 8, 14),
        onDateSelected: (data) => dataSelecionada = data,
      ),
    );

    await tester.enterText(find.byType(TextFormField), '31021985');
    await tester.pump();

    expect(dataSelecionada, isNull);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      '31/02/1985',
    );
  });

  testWidgets('calendário abre somente ao tocar no ícone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(initialDate: DateTime(2000, 1, 1), onDateSelected: (_) {}),
    );

    await tester.tap(find.byTooltip('Selecionar data de nascimento'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
