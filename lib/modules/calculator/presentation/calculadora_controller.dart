import 'package:flutter/material.dart';

import '../domain/enums/genero.dart';
import '../domain/entities/resultado_aposentadoria.dart';
import '../domain/usecases/calcular_elegibilidade_pec14_usecase.dart';

class CalculadoraController extends ChangeNotifier {
  static const int _idadeMinimaInicioExercicio = 14;
  final CalcularElegibilidadePec14UseCase _calcularElegibilidadeUseCase;

  CalculadoraController({CalcularElegibilidadePec14UseCase? useCase})
    : _calcularElegibilidadeUseCase =
          useCase ?? CalcularElegibilidadePec14UseCase();

  DateTime? _dataNascimento;
  DateTime? _dataInicioAcsAce;
  Genero? _genero;
  int _anosOutroTempo = 0;
  int _mesesOutroTempo = 0;

  ResultadoAposentadoria? _resultado;
  String? _erroMensagem;

  DateTime? get dataNascimento => _dataNascimento;
  DateTime? get dataInicioAcsAce => _dataInicioAcsAce;
  Genero? get genero => _genero;
  int get anosOutroTempo => _anosOutroTempo;
  int get mesesOutroTempo => _mesesOutroTempo;

  ResultadoAposentadoria? get resultado => _resultado;
  String? get erroMensagem => _erroMensagem;
  bool get hasResultado => _resultado != null;

  void setDataNascimento(DateTime data) {
    _dataNascimento = data;
    _limparResultado();
    notifyListeners();
  }

  void setDataInicioAcsAce(DateTime data) {
    _dataInicioAcsAce = data;
    _limparResultado();
    notifyListeners();
  }

  void setGenero(Genero? genero) {
    _genero = genero;
    _limparResultado();
    notifyListeners();
  }

  void setOutroTempo(int? anos, int? meses) {
    var novoAnos = _anosOutroTempo;
    var novoMeses = _mesesOutroTempo;

    if (anos != null) novoAnos = anos < 0 ? 0 : anos;
    if (meses != null) novoMeses = meses < 0 ? 0 : meses;

    if (novoMeses >= 12) {
      final anosExtra = novoMeses ~/ 12;
      novoAnos += anosExtra;
      novoMeses = novoMeses % 12;
    }

    _anosOutroTempo = novoAnos;
    _mesesOutroTempo = novoMeses;
    _limparResultado();
    notifyListeners();
  }

  void calcular() {
    if (_dataNascimento == null) {
      _erroMensagem = 'Informe a data de nascimento.';
      _resultado = null;
      notifyListeners();
      return;
    }
    if (_dataInicioAcsAce == null) {
      _erroMensagem = 'Informe a data de início no ACS/ACE.';
      _resultado = null;
      notifyListeners();
      return;
    }
    if (_genero == null) {
      _erroMensagem = 'Selecione o gênero.';
      _resultado = null;
      notifyListeners();
      return;
    }

    final dataNascimento = _normalizarData(_dataNascimento!);
    final dataInicioAcsAce = _normalizarData(_dataInicioAcsAce!);

    if (dataInicioAcsAce.isBefore(dataNascimento)) {
      _erroMensagem =
          'A data de início no ACS/ACE não pode ser anterior à data de nascimento.';
      _resultado = null;
      notifyListeners();
      return;
    }

    final dataMinimaInicioExercicio = _adicionarAnos(
      dataNascimento,
      _idadeMinimaInicioExercicio,
    );
    if (dataInicioAcsAce.isBefore(dataMinimaInicioExercicio)) {
      _erroMensagem =
          'A data de início no ACS/ACE exige idade mínima de $_idadeMinimaInicioExercicio anos.';
      _resultado = null;
      notifyListeners();
      return;
    }

    _erroMensagem = null;

    try {
      _resultado = _calcularElegibilidadeUseCase(
        dataNascimento: dataNascimento,
        dataInicioAcsAce: dataInicioAcsAce,
        anosOutroTempo: _anosOutroTempo,
        mesesOutroTempo: _mesesOutroTempo,
        genero: _genero!,
      );
    } catch (_) {
      _erroMensagem = 'Ocorreu um erro matemático ao realizar o cálculo.';
      _resultado = null;
    }

    notifyListeners();
  }

  void limparCalculo() {
    _dataNascimento = null;
    _dataInicioAcsAce = null;
    _genero = null;
    _anosOutroTempo = 0;
    _mesesOutroTempo = 0;
    _limparResultado();
    notifyListeners();
  }

  void clearErroMensagem() {
    if (_erroMensagem == null) return;
    _erroMensagem = null;
    notifyListeners();
  }

  DateTime _normalizarData(DateTime data) {
    if (data.day <= 28) return DateTime(data.year, data.month, data.day);

    final ultimoDiaDoMes = DateTime(data.year, data.month + 1, 0).day;
    final diaNormalizado = data.day > ultimoDiaDoMes ? ultimoDiaDoMes : data.day;
    return DateTime(data.year, data.month, diaNormalizado);
  }

  DateTime _adicionarAnos(DateTime data, int anos) {
    final totalMeses = (data.year * 12) + (data.month - 1) + (anos * 12);
    final novoAno = totalMeses ~/ 12;
    final novoMes = (totalMeses % 12) + 1;
    final ultimoDiaDoMes = DateTime(novoAno, novoMes + 1, 0).day;
    final diaNormalizado = data.day > ultimoDiaDoMes ? ultimoDiaDoMes : data.day;

    return DateTime(novoAno, novoMes, diaNormalizado);
  }

  void _limparResultado() {
    _resultado = null;
    _erroMensagem = null;
  }
}