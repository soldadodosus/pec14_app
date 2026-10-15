import 'package:flutter_test/flutter_test.dart';
import 'package:pec14_app/modules/calculator/calculator.dart';

void main() {
  group('CalculadoraController - validações de entrada', () {
    test('normaliza meses acima de 11 somando anos', () {
      final controller = CalculadoraController();

      controller.setOutroTempo(2, 14);

      expect(controller.anosOutroTempo, 3);
      expect(controller.mesesOutroTempo, 2);
    });

    test('limparCalculo zera estado numérico e resultado', () {
      final useCaseSpy = _CalcularElegibilidadeUseCaseSpy();
      final controller = CalculadoraController(useCase: useCaseSpy);

      controller.setDataNascimento(DateTime(1985, 8, 14));
      controller.setDataInicioAcsAce(DateTime(2002, 9, 1));
      controller.setGenero(Genero.feminino);
      controller.setOutroTempo(3, 5);
      controller.calcular();

      expect(controller.resultado, isNotNull);
      expect(controller.erroMensagem, isNull);

      controller.limparCalculo();

      expect(controller.dataNascimento, isNull);
      expect(controller.dataInicioAcsAce, isNull);
      expect(controller.genero, isNull);
      expect(controller.anosOutroTempo, 0);
      expect(controller.mesesOutroTempo, 0);
      expect(controller.resultado, isNull);
      expect(controller.erroMensagem, isNull);
    });

    test(
      'retorna erro quando data de início ACS/ACE é anterior ao nascimento',
      () {
        final useCaseSpy = _CalcularElegibilidadeUseCaseSpy();
        final controller = CalculadoraController(useCase: useCaseSpy);

        controller.setDataNascimento(DateTime(1990, 1, 10));
        controller.setDataInicioAcsAce(DateTime(1989, 12, 31));
        controller.setGenero(Genero.feminino);

        controller.calcular();

        expect(
          controller.erroMensagem,
          'A data de início no ACS/ACE não pode ser anterior à data de nascimento.',
        );
        expect(controller.resultado, isNull);
        expect(useCaseSpy.callCount, 0);
      },
    );

    test(
      'retorna erro quando início no ACS/ACE ocorre abaixo da idade mínima',
      () {
        final useCaseSpy = _CalcularElegibilidadeUseCaseSpy();
        final controller = CalculadoraController(useCase: useCaseSpy);

        controller.setDataNascimento(DateTime(2010, 5, 20));
        controller.setDataInicioAcsAce(DateTime(2024, 5, 19));
        controller.setGenero(Genero.masculino);

        controller.calcular();

        expect(
          controller.erroMensagem,
          'A data de início no ACS/ACE exige idade mínima de 14 anos.',
        );
        expect(controller.resultado, isNull);
        expect(useCaseSpy.callCount, 0);
      },
    );

    test('permite início do ACS/ACE no aniversário de 14 anos para nascidos em 29/02', () {
      final useCaseSpy = _CalcularElegibilidadeUseCaseSpy();
      final controller = CalculadoraController(useCase: useCaseSpy);

      controller.setDataNascimento(DateTime(2008, 2, 29));
      controller.setDataInicioAcsAce(DateTime(2022, 2, 28));
      controller.setGenero(Genero.masculino);

      controller.calcular();

      expect(controller.erroMensagem, isNull);
      expect(controller.resultado, isNotNull);
      expect(useCaseSpy.callCount, 1);
    });

    test('retorna erro padronizado quando gênero não é informado', () {
      final useCaseSpy = _CalcularElegibilidadeUseCaseSpy();
      final controller = CalculadoraController(useCase: useCaseSpy);

      controller.setDataNascimento(DateTime(1985, 8, 14));
      controller.setDataInicioAcsAce(DateTime(2002, 9, 1));

      controller.calcular();

      expect(controller.erroMensagem, 'Selecione o gênero.');
      expect(controller.resultado, isNull);
      expect(useCaseSpy.callCount, 0);
    });
  });
}

class _CalcularElegibilidadeUseCaseSpy
    extends CalcularElegibilidadePec14UseCase {
  int callCount = 0;

  @override
  ResultadoAposentadoria call({
    required DateTime dataNascimento,
    required DateTime dataInicioAcsAce,
    required int anosOutroTempo,
    required int mesesOutroTempo,
    required Genero genero,
    DateTime? dataReferencia,
  }) {
    callCount += 1;
    return ResultadoAposentadoria(
      dataElegibilidade: DateTime(2030, 1, 1),
      idadeElegibilidade: 50,
      regraAplicada: 'Regra teste',
      anosFaltantes: 1,
      mesesFaltantes: 0,
      diasFaltantes: 0,
      pontosCalculados: null,
      pontosExigidos: null,
      pontosIdade: null,
      pontosAcs: null,
      pontosOutros: null,
    );
  }
}
