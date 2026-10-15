import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.initialDate,
    required this.onDateSelected,
  });

  Future<void> _selecionarData(BuildContext context) async {
    final hoje = DateTime.now();
    final dataFocoInicial = initialDate ?? hoje;

    final dataSelecionada = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: dataFocoInicial,
      firstDate: DateTime(1930),
      lastDate: hoje,
      helpText: 'Selecione a $label',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null && dataSelecionada != initialDate) {
      onDateSelected(dataSelecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final temData = initialDate != null;
    final textoExibicao = temData
        ? DateFormat('dd/MM/yyyy').format(initialDate!)
        : hintText;

    return Semantics(
      button: true,
      label: 'Abrir seletor de $label',
      child: InkWell(
        onTap: () => _selecionarData(context),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          isEmpty: !temData,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            suffixIcon: Icon(
              Icons.calendar_month,
              color: temData ? theme.colorScheme.primary : Colors.grey.shade600,
            ),
          ),
          child: Text(
            textoExibicao,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: temData
                  ? theme.colorScheme.onSurface
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
