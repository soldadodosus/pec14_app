import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../utils/responsive.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = (context.screenWidth * 0.35).clamp(90.0, 160.0);
    return Scaffold(
      appBar: AppBar(title: const Text('PEC 14'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.rspSpacing(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(context.rspSpacing(24)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.green.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: iconSize,
                      color: Colors.green[700],
                    ),
                    SizedBox(height: context.rspSpacing(12)),
                    Text(
                      'Direitos Previdenciários dos ACS/ACE/AIS/AISAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.rsp(22),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: context.rspSpacing(10)),
                    Text(
                      'Entenda as regras e simule sua elegibilidade de aposentadoria.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.rsp(15),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rspSpacing(28)),
              _ActionTile(
                title: 'Calculadora de Aposentadoria',
                subtitle: 'Simule datas e regras aplicáveis.',
                icon: Icons.calculate,
                color: Colors.blue.shade700,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.calculadora),
              ),
              SizedBox(height: context.rspSpacing(12)),
              _ActionTile(
                title: 'Quiz PEC 14',
                subtitle: 'Teste seu conhecimento sobre a PEC 14.',
                icon: Icons.menu_book,
                color: Colors.green.shade700,
                onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
              ),
              SizedBox(height: context.rspSpacing(28)),
              Text(
                'Simulação informativa\nNão substitui orientação do sindicato.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rsp(12),
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: context.rspSpacing(6)),
              Text(
                '© 2026 soldadodosus. Todos os direitos reservados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rsp(12),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: EdgeInsets.all(context.rspSpacing(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.blueGrey.shade50),
        ),
        child: Row(
          children: [
            Container(
              width: context.rsp(44),
              height: context.rsp(44),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: context.rspSpacing(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.rsp(16),
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  SizedBox(height: context.rspSpacing(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.rsp(13),
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.blueGrey.shade300),
          ],
        ),
      ),
    );
  }
}
