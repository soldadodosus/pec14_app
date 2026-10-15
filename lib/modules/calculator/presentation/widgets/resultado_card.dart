import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/resultado_aposentadoria.dart';

class ResultadoCard extends StatelessWidget {
  final ResultadoAposentadoria resultado;

  const ResultadoCard({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isElegivel =
        resultado.anosFaltantes == 0 &&
        resultado.mesesFaltantes == 0 &&
        resultado.diasFaltantes == 0;
    final pontos = resultado.pontosCalculados;

    final dataFormatada = DateFormat(
      'dd/MM/yyyy',
    ).format(resultado.dataElegibilidade);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isElegivel ? Colors.green.shade50 : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isElegivel ? Icons.check_circle : Icons.calendar_month,
                  color: isElegivel
                      ? Colors.green.shade700
                      : theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isElegivel
                        ? 'Elegibilidade Alcançada!'
                        : 'Previsão de Elegibilidade',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isElegivel
                          ? Colors.green.shade800
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            _buildInfoRow(
              context,
              icone: Icons.event_available,
              titulo: 'Data da Aposentadoria',
              valor: dataFormatada,
              destaque: true,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icone: Icons.cake,
              titulo: 'Idade na elegibilidade',
              valor: '${resultado.idadeElegibilidade} anos',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icone: Icons.gavel,
              titulo: 'Regra Aplicada',
              valor: resultado.regraAplicada,
            ),
            if (pontos != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icone: Icons.calculate,
                titulo: 'Total de Pontos',
                valor: pontos.floor().toString(),
              ),
            ],
            if (!isElegivel) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icone: Icons.timer,
                titulo: 'Tempo Restante',
                valor:
                    '${resultado.anosFaltantes} anos, ${resultado.mesesFaltantes} meses e ${resultado.diasFaltantes} dias.',
              ),
            ],
            if (isElegivel) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você já preenche os requisitos da PEC 14/21. Procure o seu sindicato para orientação sobre a entrada no requerimento.',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String valor,
    bool destaque = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
                  fontSize: destaque ? 18 : 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}