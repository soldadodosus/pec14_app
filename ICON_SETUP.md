# Configuração do ícone PEC 14

## Fonte do ícone

Use `assets/icons/app_icon.png` como fonte única. A imagem deve ser PNG quadrado; 1024 x 1024 pixels ou maior é recomendado. Preserve a arte inteira, sem recortá-la.

## Gerar os ícones

Execute na raiz do projeto:

```bash
flutter pub get
dart run flutter_launcher_icons
```

O `flutter_launcher_icons` gera os ícones de Android (incluindo o adaptativo), iOS, Web, Windows e macOS.

## Linux

O gerador não cria os recursos Linux. O CMake do runner inclui a fonte no bundle, define o ícone da janela GTK e instala a imagem e a entrada `.desktop` nas pastas de recursos do bundle. Um instalador/distribuidor deve registrar esses recursos nos caminhos do sistema para que o aplicativo apareça no menu de aplicativos.

Depois de alterar a imagem, gere novamente os ícones suportados e compile o alvo Linux para atualizar o bundle.
