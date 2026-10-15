import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/enums/genero.dart';
import 'calculadora_controller.dart';
import 'widgets/date_picker_form_field.dart';
import 'widgets/resultado_card.dart';

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
            onPressed: _controller.limparCalculo,
          ),
        ],
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
                    onDateSelected: _controller.setDataNascimento,
                  ),
                  const SizedBox(height: 16),
                  DatePickerFormField(
                    label: 'Início do Exercício ACS/ACE/AIS/AISAN',
                    hintText: '',
                    initialDate: _controller.dataInicioAcsAce,
                    onDateSelected: _controller.setDataInicioAcsAce,
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) => _controller.setOutroTempo(
                            int.tryParse(v) ?? 0,
                            null,
                          ),
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) => _controller.setOutroTempo(
                            null,
                            int.tryParse(v) ?? 0,
                          ),
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