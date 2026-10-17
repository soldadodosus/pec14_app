import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/enums/genero.dart';
import 'calculadora_controller.dart';
import 'widgets/date_picker_form_field.dart';
import 'widgets/resultado_card.dart';
import 'widgets/teclado_numerico.dart';

class CalculadoraView extends StatefulWidget {
  const CalculadoraView({super.key});

  @override
  State<CalculadoraView> createState() => _CalculadoraViewState();
}

class _CalculadoraViewState extends State<CalculadoraView> {
  late final CalculadoraController _controller;
  String? _ultimaMensagemErroExibida;
  late final TextEditingController _anosOutroTempoController;
  late final TextEditingController _mesesOutroTempoController;
  int _dataResetToken = 0;
  TeclaNumericaHandler? _teclaNumericaAtiva;

  @override
  void initState() {
    super.initState();
    _controller = CalculadoraController();
    _controller.addListener(_onControllerChanged);
    _anosOutroTempoController = TextEditingController(
      text: _controller.anosOutroTempo > 0
          ? _controller.anosOutroTempo.toString()
          : '',
    );
    _mesesOutroTempoController = TextEditingController(
      text: _controller.mesesOutroTempo > 0
          ? _controller.mesesOutroTempo.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _anosOutroTempoController.dispose();
    _mesesOutroTempoController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _syncOutroTempoFields();
    final erroAtual = _controller.erroMensagem;

    if (erroAtual == null || erroAtual.isEmpty) {
      _ultimaMensagemErroExibida = null;
      return;
    }

    if (erroAtual == _ultimaMensagemErroExibida || !mounted) return;

    _ultimaMensagemErroExibida = erroAtual;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erroAtual),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _controller.clearErroMensagem();
  }

  void _syncOutroTempoFields() {
    final anosTexto = _controller.anosOutroTempo > 0
        ? _controller.anosOutroTempo.toString()
        : '';
    final mesesTexto = _controller.mesesOutroTempo > 0
        ? _controller.mesesOutroTempo.toString()
        : '';

    if (_anosOutroTempoController.text != anosTexto) {
      _anosOutroTempoController.text = anosTexto;
    }
    if (_mesesOutroTempoController.text != mesesTexto) {
      _mesesOutroTempoController.text = mesesTexto;
    }
  }

  void _limparCalculo() {
    setState(() {
      _dataResetToken++;
      _teclaNumericaAtiva = null;
    });
    _controller.limparCalculo();
  }

  void _ativarTecladoNumerico(
    TextEditingController campo,
    ValueChanged<String> onChanged,
  ) {
    setState(() {
      _teclaNumericaAtiva = (tecla) => aplicarTeclaNumerica(
        controller: campo,
        tecla: tecla,
        formatter: FilteringTextInputFormatter.digitsOnly,
        onChanged: onChanged,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora PEC 14'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar dados',
            onPressed: _limparCalculo,
          ),
        ],
      ),
      bottomNavigationBar: _teclaNumericaAtiva == null
          ? null
          : TecladoNumerico(
              onKeyPressed: _teclaNumericaAtiva!,
              onDone: () => setState(() => _teclaNumericaAtiva = null),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Parâmetros Obrigatórios de Cálculo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gênero',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<Genero>(
                    emptySelectionAllowed: true,
                    segments: Genero.values
                        .map(
                          (g) =>
                              ButtonSegment(value: g, label: Text(g.descricao)),
                        )
                        .toList(),
                    selected: _controller.genero != null
                        ? {_controller.genero!}
                        : <Genero>{},
                    onSelectionChanged: (newSelection) {
                      _controller.setGenero(
                        newSelection.isNotEmpty ? newSelection.first : null,
                      );
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DatePickerFormField(
                    label: 'Data de Nascimento',
                    hintText: '',
                    initialDate: _controller.dataNascimento,
                    resetToken: _dataResetToken,
                    onDateSelected: _controller.setDataNascimento,
                    onKeyboardRequested: (handler) =>
                        setState(() => _teclaNumericaAtiva = handler),
                  ),
                  const SizedBox(height: 16),
                  DatePickerFormField(
                    label: 'Início do Exercício ACS/ACE/AIS/AISAN',
                    hintText: '',
                    initialDate: _controller.dataInicioAcsAce,
                    resetToken: _dataResetToken,
                    onDateSelected: _controller.setDataInicioAcsAce,
                    onKeyboardRequested: (handler) =>
                        setState(() => _teclaNumericaAtiva = handler),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tempo de Contribuição em OUTRAS profissões',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _anosOutroTempoController,
                          decoration: const InputDecoration(
                            labelText: 'Anos',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.none,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          onTap: () => _ativarTecladoNumerico(
                            _anosOutroTempoController,
                            (value) => _controller.setOutroTempo(
                              int.tryParse(value) ?? 0,
                              null,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _mesesOutroTempoController,
                          decoration: const InputDecoration(
                            labelText: 'Meses',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.none,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          onTap: () => _ativarTecladoNumerico(
                            _mesesOutroTempoController,
                            (value) => _controller.setOutroTempo(
                              null,
                              int.tryParse(value) ?? 0,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _controller.calcular,
                    icon: const Icon(Icons.calculate),
                    label: const Text(
                      'CALCULAR ELEGIBILIDADE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_controller.hasResultado)
                    ResultadoCard(resultado: _controller.resultado!),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
