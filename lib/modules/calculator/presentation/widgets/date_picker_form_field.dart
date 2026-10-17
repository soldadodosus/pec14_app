import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatefulWidget {
  final String label;
  final String hintText;
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;
  final Object? resetToken;

  const DatePickerFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.initialDate,
    this.resetToken,
    required this.onDateSelected,
  });

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  late final TextEditingController _textController;
  bool _emitindoData = false;
  DateTime? _dataEmitida;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: _formatarData(widget.initialDate),
    );
  }

  @override
  void didUpdateWidget(covariant DatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.resetToken != oldWidget.resetToken) {
      _atualizarTexto(widget.initialDate);
      _emitindoData = false;
      return;
    }

    if (widget.initialDate != oldWidget.initialDate) {
      if (_emitindoData && _dataEmitida == widget.initialDate) {
        _emitindoData = false;
      } else {
        _atualizarTexto(widget.initialDate);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime? data) =>
      data == null ? '' : DateFormat('dd/MM/yyyy').format(data);

  void _atualizarTexto(DateTime? data) {
    final texto = _formatarData(data);
    _textController.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  DateTime? _interpretarData(String texto) {
    if (texto.length != 10) return null;

    try {
      final data = DateFormat('dd/MM/yyyy').parseStrict(texto);
      final hoje = DateTime.now();
      final dataLimite = DateTime(hoje.year, hoje.month, hoje.day);
      if (data.isBefore(DateTime(1930)) || data.isAfter(dataLimite)) {
        return null;
      }
      return data;
    } on FormatException {
      return null;
    }
  }

  void _onChanged(String texto) {
    _dataEmitida = _interpretarData(texto);
    _emitindoData = true;
    widget.onDateSelected(_dataEmitida);
  }

  Future<void> _selecionarData(BuildContext context) async {
    final hoje = DateTime.now();
    var dataSelecionada = widget.initialDate ?? hoje;

    final dataConfirmada = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Selecione a ${widget.label}'),
                content: SizedBox(
                  width: 320,
                  child: CalendarDatePicker(
                    initialDate: dataSelecionada,
                    firstDate: DateTime(1930),
                    lastDate: hoje,
                    currentDate: hoje,
                    onDateChanged: (data) {
                      setDialogState(() => dataSelecionada = data);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCELAR'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(dataSelecionada),
                    child: const Text('CONFIRMAR'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (dataConfirmada != null && dataConfirmada != widget.initialDate) {
      widget.onDateSelected(dataConfirmada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temData = widget.initialDate != null;

    return TextFormField(
      controller: _textController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: const [DataInputFormatter()],
      onChanged: _onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText.isEmpty ? 'dd/MM/yyyy' : widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.calendar_month,
            color: temData ? theme.colorScheme.primary : Colors.grey.shade600,
          ),
          tooltip: 'Selecionar ${widget.label.toLowerCase()}',
          onPressed: () => _selecionarData(context),
        ),
      ),
    );
  }
}

class DataInputFormatter extends TextInputFormatter {
  const DataInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    var digitCursor = newValue.selection.isValid
        ? newValue.text
              .substring(
                0,
                newValue.selection.extentOffset.clamp(0, newValue.text.length),
              )
              .replaceAll(RegExp(r'[^0-9]'), '')
              .length
        : digits.length;

    if (_backspaceOnSeparator(oldValue, newValue)) {
      final separatorDigitIndex = oldValue.text
          .substring(0, oldValue.selection.extentOffset - 1)
          .replaceAll(RegExp(r'[^0-9]'), '')
          .length;
      if (separatorDigitIndex > 0 && digits.length >= separatorDigitIndex) {
        digits = digits.replaceRange(
          separatorDigitIndex - 1,
          separatorDigitIndex,
          '',
        );
        digitCursor = separatorDigitIndex - 1;
      }
    }

    final texto = _formatarDigitos(digits);
    final cursor = _offsetParaDigitos(
      digitCursor.clamp(0, digits.length),
      digits.length,
    );
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  bool _backspaceOnSeparator(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = oldValue.selection.extentOffset;
    return oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        cursor > 0 &&
        cursor <= oldValue.text.length &&
        oldValue.text[cursor - 1] == '/' &&
        newValue.text.length == oldValue.text.length - 1;
  }

  String _formatarDigitos(String digits) {
    if (digits.length <= 2) return digits;
    if (digits.length <= 4) {
      return '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return '${digits.substring(0, 2)}/${digits.substring(2, 4)}/${digits.substring(4)}';
  }

  int _offsetParaDigitos(int digitCount, int totalDigits) {
    var offset = digitCount;
    if (digitCount >= 2 && totalDigits > 2) offset++;
    if (digitCount >= 4 && totalDigits > 4) offset++;
    return offset;
  }
}
