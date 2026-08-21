import 'dart:math';

import '../entities/resultado_aposentadoria.dart';
import '../enums/genero.dart';

class CalcularElegibilidadePec14UseCase {
  ResultadoAposentadoria call({
    required DateTime dataNascimento,
    required DateTime dataInicioAcsAce,
    required int anosOutroTempo,
    required int mesesOutroTempo,
    required Genero genero,
    DateTime? dataReferencia,
  }) {
    final hoje = _DateUtils.dateOnly(dataReferencia ?? DateTime.now());

    final opcao1 = _simularRegra1e2(dataNascimento, dataInicioAcsAce, genero);
    final opcao2 = _simularRegra3(
      dataNascimento,
      dataInicioAcsAce,
      anosOutroTempo,
      mesesOutroTempo,
      genero,
    );

    _CandidatoAposentadoria melhorOpcao = opcao1;
    if (opcao2 != null && opcao2.data.isBefore(opcao1.data)) {
      melhorOpcao = opcao2;
    }

    final dataElegibilidade = _DateUtils.dateOnly(melhorOpcao.data);
    final restante = dataElegibilidade.isAfter(hoje)
        ? _DateUtils.diffYmd(hoje, dataElegibilidade)
        : const _DateYmdDifference.zero();

    return ResultadoAposentadoria(
      dataElegibilidade: dataElegibilidade,
      regraAplicada: melhorOpcao.nomeRegra,
      anosFaltantes: restante.anos,
      mesesFaltantes: restante.meses,
      diasFaltantes: restante.dias,
      pontosCalculados: melhorOpcao.pontosCalculados,
      pontosExigidos: melhorOpcao.pontosExigidos,
      pontosIdade: melhorOpcao.pontosIdade,
      pontosAcs: melhorOpcao.pontosAcs,
      pontosOutros: melhorOpcao.pontosOutros,
    );
  }

  int _obterIdadeMinimaPorAno(int ano, Genero genero) {
    if (ano <= 2030) {
      return genero == Genero.feminino ? 50 : 52;
    } else if (ano <= 2035) {
      return genero == Genero.feminino ? 52 : 54;
    } else if (ano <= 2040) {
      return genero == Genero.feminino ? 54 : 56;
    } else {
      return genero == Genero.feminino ? 57 : 60;
    }
  }

  _CandidatoAposentadoria _simularRegra1e2(
    DateTime nascimento,
    DateTime inicioAcsAce,
    Genero genero,
  ) {
    final nascimentoBase = _DateUtils.dateOnly(nascimento);
    final inicioAcsAceBase = _DateUtils.dateOnly(inicioAcsAce);

    var dataServico = _DateUtils.addYears(inicioAcsAceBase, 25);
    var dataNascimento = nascimentoBase;

    while (true) {
      final dataTeste = dataServico.isBefore(dataNascimento)
          ? dataServico
          : dataNascimento;

      final anosTrabalhados = _DateUtils.diffYmd(
        inicioAcsAceBase,
        dataTeste,
      ).anos;
      final anosIdade = _DateUtils.diffYmd(nascimentoBase, dataTeste).anos;

      var bonus = anosTrabalhados - 25;
      if (bonus > 5) bonus = 5;
      if (bonus < 0) bonus = 0;

      final idadeMinimaAtual = _obterIdadeMinimaPorAno(dataTeste.year, genero);
      final idadeMinimaReduzida = idadeMinimaAtual - bonus;

      if (anosTrabalhados >= 25 && anosIdade >= idadeMinimaReduzida) {
        final descricao = bonus > 0
            ? 'Regras 1 e 2: Idade mínima de $idadeMinimaAtual reduzida para $idadeMinimaReduzida pelo bônus de tempo de serviço excedente.'
            : 'Regra 1: Aposentadoria alcançada pela Idade Mínima Progressiva.';

        return _CandidatoAposentadoria(data: dataTeste, nomeRegra: descricao);
      }

      if (dataServico.isAtSameMomentAs(dataNascimento)) {
        dataServico = _DateUtils.addYears(dataServico, 1);
        dataNascimento = _DateUtils.addYears(dataNascimento, 1);
      } else if (dataServico.isBefore(dataNascimento)) {
        dataServico = _DateUtils.addYears(dataServico, 1);
      } else {
        dataNascimento = _DateUtils.addYears(dataNascimento, 1);
      }

      if (dataTeste.year > 2100) {
        return _CandidatoAposentadoria(
          data: DateTime(2100),
          nomeRegra: 'Inatingível',
        );
      }
    }
  }

  _CandidatoAposentadoria? _simularRegra3(
    DateTime nascimento,
    DateTime inicioAcsAce,
    int anosOutros,
    int mesesOutros,
    Genero genero,
  ) {
    final nascimentoBase = _DateUtils.dateOnly(nascimento);
    final inicioAcsAceBase = _DateUtils.dateOnly(inicioAcsAce);

    final idadeExigida = genero == Genero.feminino ? 60 : 63;
    final pontosExigidos = genero == Genero.feminino ? 83.0 : 86.0;

    final dataBase = _DateUtils.addYears(inicioAcsAceBase, 10);

    final anchorDate = DateTime(2000, 1, 1);
    final dataOutros = _DateUtils.addMonths(
      _DateUtils.addYears(anchorDate, anosOutros),
      mesesOutros,
    );
    final diasOutros = dataOutros.difference(anchorDate).inDays;

    var dataTeste = dataBase;

    while (true) {
      final diasIdade = dataTeste.difference(nascimentoBase).inDays;
      final diasAcs = dataTeste.difference(inicioAcsAceBase).inDays;

      final pontosIdade = diasIdade / 365.25;
      final pontosAcs = diasAcs / 365.25;
      final pontosOutros = diasOutros / 365.25;
      final pontosAtuais = pontosIdade + pontosAcs + pontosOutros;
      final idadeMinimaOk =
          _DateUtils.diffYmd(nascimentoBase, dataTeste).anos >= idadeExigida;

      if (idadeMinimaOk && pontosAtuais >= pontosExigidos) {
        return _CandidatoAposentadoria(
          data: dataTeste,
          nomeRegra:
              'Regra 3: Sistema de Pontos (Soma da Idade e Tempo de Contribuição atingiu a exigência).',
          pontosCalculados: pontosAtuais,
          pontosExigidos: pontosExigidos,
          pontosIdade: pontosIdade,
          pontosAcs: pontosAcs,
          pontosOutros: pontosOutros,
        );
      }

      dataTeste = dataTeste.add(const Duration(days: 1));
      if (dataTeste.year > 2100) return null;
    }
  }
}

class _DateUtils {
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime addYears(DateTime date, int years) =>
      addMonths(date, years * 12);

  static DateTime addMonths(DateTime date, int monthsToAdd) {
    final normalized = dateOnly(date);
    final totalMonths =
        (normalized.year * 12) + (normalized.month - 1) + monthsToAdd;
    final year = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    final day = min(normalized.day, _daysInMonth(year, month));
    return DateTime(year, month, day);
  }

  static _DateYmdDifference diffYmd(DateTime from, DateTime to) {
    var inicio = dateOnly(from);
    var fim = dateOnly(to);

    if (fim.isBefore(inicio)) {
      return const _DateYmdDifference.zero();
    }

    var anos = fim.year - inicio.year;
    var cursor = addYears(inicio, anos);
    if (cursor.isAfter(fim)) {
      anos -= 1;
      cursor = addYears(inicio, anos);
    }

    var meses = 0;
    while (meses < 12) {
      final proximo = addMonths(cursor, meses + 1);
      if (proximo.isAfter(fim)) break;
      meses += 1;
    }

    cursor = addMonths(cursor, meses);
    final dias = fim.difference(cursor).inDays;

    return _DateYmdDifference(anos: anos, meses: meses, dias: dias);
  }

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;
}

class _DateYmdDifference {
  final int anos;
  final int meses;
  final int dias;

  const _DateYmdDifference({
    required this.anos,
    required this.meses,
    required this.dias,
  });

  const _DateYmdDifference.zero() : anos = 0, meses = 0, dias = 0;
}

class _CandidatoAposentadoria {
  final DateTime data;
  final String nomeRegra;
  final double? pontosCalculados;
  final double? pontosExigidos;
  final double? pontosIdade;
  final double? pontosAcs;
  final double? pontosOutros;

  _CandidatoAposentadoria({
    required this.data,
    required this.nomeRegra,
    this.pontosCalculados,
    this.pontosExigidos,
    this.pontosIdade,
    this.pontosAcs,
    this.pontosOutros,
  });
}
