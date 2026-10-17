import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TeclaNumericaHandler = void Function(String tecla);

void aplicarTeclaNumerica({
  required TextEditingController controller,
  required String tecla,
  required ValueChanged<String> onChanged,
  TextInputFormatter? formatter,
}) {
  final valorAntigo = controller.value;
  final textoAntigo = valorAntigo.text;
  final selecao = valorAntigo.selection.isValid
      ? valorAntigo.selection
      : TextSelection.collapsed(offset: textoAntigo.length);
  final inicio = selecao.start.clamp(0, textoAntigo.length);
  final fim = selecao.end.clamp(0, textoAntigo.length);

  late final String novoTexto;
  late final int novoCursor;

  if (tecla == 'backspace') {
    if (inicio == fim && inicio == 0) return;
    final inicioRemocao = inicio == fim ? inicio - 1 : inicio;
    novoTexto = textoAntigo.replaceRange(inicioRemocao, fim, '');
    novoCursor = inicioRemocao;
  } else if (RegExp(r'^\d$').hasMatch(tecla)) {
    novoTexto = textoAntigo.replaceRange(inicio, fim, tecla);
    novoCursor = inicio + tecla.length;
  } else {
    return;
  }

  var novoValor = TextEditingValue(
    text: novoTexto,
    selection: TextSelection.collapsed(offset: novoCursor),
  );
  if (formatter != null) {
    novoValor = formatter.formatEditUpdate(valorAntigo, novoValor);
  }

  controller.value = novoValor;
  onChanged(novoValor.text);
}

class TecladoNumerico extends StatelessWidget {
  final TeclaNumericaHandler onKeyPressed;
  final VoidCallback onDone;

  const TecladoNumerico({
    super.key,
    required this.onKeyPressed,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Teclado numérico',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar teclado',
                    onPressed: onDone,
                    icon: const Icon(Icons.keyboard_hide),
                  ),
                ],
              ),
              _linha(context, ['1', '2', '3']),
              _linha(context, ['4', '5', '6']),
              _linha(context, ['7', '8', '9']),
              _linha(context, ['backspace', '0', 'done']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linha(BuildContext context, List<String> teclas) {
    return Row(
      children: [
        for (var index = 0; index < teclas.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(child: _tecla(context, teclas[index])),
        ],
      ],
    );
  }

  Widget _tecla(BuildContext context, String tecla) {
    final label = switch (tecla) {
      'backspace' => const Icon(Icons.backspace_outlined),
      'done' => const Icon(Icons.check),
      _ => Text(tecla, style: Theme.of(context).textTheme.titleMedium),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 44,
        child: OutlinedButton(
          key: ValueKey('teclado-$tecla'),
          onPressed: switch (tecla) {
            'backspace' => () => onKeyPressed(tecla),
            'done' => onDone,
            _ => () => onKeyPressed(tecla),
          },
          child: label,
        ),
      ),
    );
  }
}
