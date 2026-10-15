class ResultadoAposentadoria {
  final DateTime dataElegibilidade;
  final int idadeElegibilidade;
  final String regraAplicada;
  final int anosFaltantes;
  final int mesesFaltantes;
  final int diasFaltantes;
  final double? pontosCalculados;
  final double? pontosExigidos;
  final double? pontosIdade;
  final double? pontosAcs;
  final double? pontosOutros;

  ResultadoAposentadoria({
    required this.dataElegibilidade,
    required this.idadeElegibilidade,
    required this.regraAplicada,
    required this.anosFaltantes,
    required this.mesesFaltantes,
    required this.diasFaltantes,
    this.pontosCalculados,
    this.pontosExigidos,
    this.pontosIdade,
    this.pontosAcs,
    this.pontosOutros,
  });
}