# App PEC 14

Aplicativo Flutter voltado para informar e apoiar a simulação de elegibilidade previdenciária de ACS, ACE, AIS e AISAN no contexto da PEC 14, além de oferecer um quiz educativo sobre o tema.

Versão atual: `2.2.0+15`

## Última release

**v2.2.0** (publicada em 2026-04-06)

- Release: [v2.2.0](https://github.com/j4iltondev/pec14_app/releases/tag/v2.2.0)
- Download:
  - Android (APK): [AppPEC14_v2.2.0_build15.apk](https://github.com/j4iltondev/pec14_app/releases/download/v2.2.0/AppPEC14_v2.2.0_build15.apk)
  - Windows (ZIP): [AppPEC14_v2.2.0_build15_windows.zip](https://github.com/j4iltondev/pec14_app/releases/download/v2.2.0/AppPEC14_v2.2.0_build15_windows.zip)
  - Web (ZIP): [AppPEC14_v2.2.0_build15_web.zip](https://github.com/j4iltondev/pec14_app/releases/download/v2.2.0/AppPEC14_v2.2.0_build15_web.zip)

## Objetivo do Projeto

O App PEC 14 foi criado para reunir, em uma interface simples e acessível, recursos informativos sobre direitos previdenciários relacionados à PEC 14. O projeto busca ajudar profissionais e entidades a:

- compreender regras previdenciárias aplicáveis ao público ACS, ACE, AIS e AISAN;
- realizar uma simulação informativa de elegibilidade de aposentadoria;
- reforçar o aprendizado por meio de um quiz com perguntas e explicações;
- distribuir builds para múltiplas plataformas a partir de uma mesma base Flutter.

O aplicativo tem caráter informativo e não substitui orientação jurídica, sindical ou previdenciária especializada.

## Funcionalidades

### Tela inicial

- apresenta o propósito do aplicativo;
- direciona o usuário para a calculadora de aposentadoria e para o quiz;
- informa que a simulação é apenas orientativa.

### Calculadora de aposentadoria

- recebe gênero do usuário;
- recebe data de nascimento;
- recebe a data de início do exercício como ACS, ACE, AIS ou AISAN;
- permite informar tempo adicional de contribuição em outras profissões;
- calcula a elegibilidade com base nas regras implementadas no domínio da aplicação;
- exibe o resultado da simulação em interface dedicada.

### Quiz PEC 14

- carrega questões a partir de arquivo local em `assets/quizzes/quiz_questions.json`;
- apresenta perguntas e alternativas em sequência;
- mostra feedback visual após a resposta;
- exibe explicação e fonte de cada questão;
- calcula a pontuação final e permite reiniciar o quiz.

### Distribuição e releases

- gera builds para Android, Windows e Web no fluxo de release para Windows;
- gera builds para Android e, conforme o sistema operacional, Linux, macOS ou iOS no script Unix;
- renomeia e organiza artefatos automaticamente na pasta `releases_finais/` com base na versão definida em `pubspec.yaml`.

## Tecnologias Utilizadas

### Base da aplicação

- Flutter
- Dart
- Material Design
- `flutter_localizations` para suporte à localidade `pt_BR`
- `intl` para formatação e tratamento regional

### Qualidade e desenvolvimento

- `flutter_test` para testes automatizados
- `flutter_lints` para análise estática
- `flutter_launcher_icons` para geração de ícones multiplataforma

### Organização do projeto

O projeto usa uma estrutura híbrida em Flutter:

- `lib/app/`: shell principal da aplicação, rotas e configuração do `MaterialApp`;
- `lib/modules/home/`: tela inicial;
- `lib/modules/calculator/`: regra de negócio e interface da calculadora;
- `lib/modules/quiz/`: módulo do quiz com separação entre `data`, `domain` e `presentation`;
- `lib/design_system/`: tema e tokens visuais compartilhados;
- `assets/quizzes/`: base local das perguntas do quiz.

## Plataformas Suportadas

O repositório contém configuração para:

- Android
- Web
- Windows
- Linux
- macOS
- iOS

Na prática, a disponibilidade de build depende do sistema operacional e das toolchains instaladas na máquina de desenvolvimento.

## Como Preparar o Ambiente de Desenvolvimento

### Pré-requisitos

Antes de executar o projeto, instale e configure:

- Flutter SDK;
- Dart SDK compatível com o Flutter instalado;
- Git;
- Android Studio ou SDK/Command Line Tools do Android, caso vá gerar builds Android;
- Visual Studio com suporte a desenvolvimento Desktop em C++, caso vá compilar para Windows;
- Xcode, caso vá compilar para iOS ou macOS;
- um editor como Visual Studio Code ou Android Studio.

Também é recomendável validar o ambiente com:

```bash
flutter doctor
```

### 1. Clonar o repositório

```bash
git clone https://github.com/j4ilton/pec14_app.git
cd pec14_app
```

### 2. Baixar as dependências

```bash
flutter pub get
```

### 3. Verificar a configuração do projeto

```bash
flutter analyze
```

### 4. Executar os testes

```bash
flutter test
```

Se a alteração estiver relacionada à lógica da calculadora, também é recomendado executar os testes focados:

```bash
flutter test test/viewmodels/calculadora_controller_test.dart
flutter test test/domain/usecases/calcular_elegibilidade_pec14_usecase_test.dart
```

### 5. Rodar o aplicativo em modo de desenvolvimento

```bash
flutter run
```

Se houver mais de um dispositivo disponível, liste-os com:

```bash
flutter devices
```

E então selecione o alvo desejado:

```bash
flutter run -d <device-id>
```

## Como Baixar e Instalar

Esta seção cobre dois cenários: baixar o código-fonte para desenvolvimento e instalar o aplicativo gerado a partir dos artefatos de release.

### Baixar o código-fonte

Para desenvolvimento local, siga o processo de clonagem descrito acima:

```bash
git clone https://github.com/j4ilton/pec14_app.git
cd pec14_app
flutter pub get
```

### Gerar os instaláveis e arquivos de distribuição

#### No Windows

Use o script abaixo na raiz do projeto:

```bat
build_all.bat
```

Esse fluxo executa:

- build APK Android;
- build AAB Android;
- build Windows;
- build Web;
- organização final dos artefatos em `releases_finais/`.

#### No Linux ou macOS

Use:

```bash
./build_all.sh
```

Esse fluxo gera Android e, dependendo do sistema operacional:

- Linux, quando executado em ambiente Linux;
- iOS e macOS, quando executado em ambiente macOS.

### Onde os arquivos finais ficam

Após o processo de release, os arquivos organizados ficam em:

```text
releases_finais/
```

Os nomes seguem o padrão:

```text
AppPEC14_vX.Y.Z_buildN.ext
```

Exemplos:

- `AppPEC14_v2.2.0_build15.aab`
- `AppPEC14_v2.2.0_build15.apk`
- `AppPEC14_v2.2.0_build15.exe`
- `AppPEC14_v2.2.0_build15_web/`

### Como instalar os artefatos

#### Android APK

- transfira o arquivo `.apk` para o dispositivo Android;
- habilite a instalação de aplicativos de fontes permitidas, se necessário;
- abra o arquivo e conclua a instalação.

#### Android AAB

- o arquivo `.aab` não é instalado diretamente no aparelho;
- ele deve ser enviado para distribuição em loja ou pipeline compatível, como Google Play.

#### Windows

- utilize o executável gerado na pasta de release;
- se necessário, distribua junto dos arquivos complementares exigidos pelo build Desktop.

#### Web

- publique o conteúdo da pasta gerada para um servidor estático ou serviço de hospedagem;
- abra a aplicação pelo navegador após o deploy.

## Comandos Úteis

```bash
flutter pub get
flutter analyze
flutter test
flutter run
dart run rename_builds.dart
```

## Observações Importantes

- o aplicativo atualmente suporta apenas a localidade `pt_BR`;
- a versão do produto segue `X.Y.Z` e o número local de build fica em `+N` no `pubspec.yaml`;
- no GitHub Actions, o número Android é gerado como `16 + GITHUB_RUN_NUMBER`, começando em 17 para ficar acima do último artefato `build15`;
- cada push bem-sucedido em `main` publica uma GitHub Release `vX.Y.Z-buildN` com APK e AAB anexados;
- em releases locais, aumente `N` em `X.Y.Z+N` a cada nova publicação;
- `rename_builds.dart` usa o mesmo número de build passado pelo CI ou definido no `pubspec.yaml`;
- o projeto utiliza uma arquitetura Flutter híbrida, mantendo a calculadora e o quiz como módulos separados dentro de `lib/modules/`.

## Licença e Uso

Este projeto está licenciado sob a GNU GPL v3.0. Isso permite uso, cópia, modificação e distribuição do código, desde que as redistribuições e trabalhos derivados mantenham a mesma licença e disponibilizem o código-fonte correspondente nos termos da GPL.

Consulte o arquivo `LICENSE` para o texto completo da licença.
