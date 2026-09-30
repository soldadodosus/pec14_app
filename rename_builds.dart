import 'dart:io';

void main() {
  const appName = "AppPEC14";

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ Erro: pubspec.yaml não encontrado.');
    return;
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*(.+)$', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    print('❌ Erro: Versão não encontrada no pubspec.yaml');
    return;
  }

  final versionString = match.group(1)!.trim().replaceAll('+', '_build');

  final filesToRename = {
    'build/app/outputs/flutter-apk/app-release.apk':
        '${appName}_v$versionString.apk',
    'build/app/outputs/bundle/release/app-release.aab':
        '${appName}_v$versionString.aab',
  };

  final outputDir = Directory('releases_finais');
  if (!outputDir.existsSync()) {
    outputDir.createSync();
  }

  print('Iniciando organização das builds para a versão $versionString...\n');

  filesToRename.forEach((originalPath, newName) {
    final originalFile = File(originalPath);
    final destination = '${outputDir.path}/$newName';

    if (originalFile.existsSync()) {
      originalFile.copySync(destination);
      print('✅ Sucesso: $newName copiado para a pasta releases_finais/');
    } else {
      print('⚠️  Aviso: $originalPath não encontrado, pulando...');
    }
  });

  final webBuildDir = Directory('build/web');
  final webOutputDir = Directory(
    '${outputDir.path}/${appName}_v${versionString}_web',
  );
  if (webBuildDir.existsSync()) {
    _copyDirectory(webBuildDir, webOutputDir);
    print('✅ Sucesso: Web app copiado para a pasta releases_finais/');
  } else {
    print('⚠️  Aviso: build/web não encontrado, pulando...');
  }

  final winBuildDir = Directory('build/windows/x64/runner/Release');
  final winOutputDir = Directory(
    '${outputDir.path}/${appName}_v${versionString}_windows',
  );

  if (winBuildDir.existsSync()) {
    // 1. Copia o diretório
    _copyDirectory(winBuildDir, winOutputDir);
    print('✅ Sucesso: Windows app copiado para ${winOutputDir.path}');

    // 2. Tenta renomear o executável dentro do novo diretório
    final exeOriginal = File('${winOutputDir.path}/pec14_app.exe');
    final exeNovo = '${winOutputDir.path}/$appName.exe';

    if (exeOriginal.existsSync()) {
      exeOriginal.renameSync(exeNovo);
      print('✅ Sucesso: Executável renomeado para $appName.exe');
    } else {
      print('⚠️  Aviso: Executável original não encontrado para renomear.');
    }
  } else {
    print(
      '⚠️  Aviso: Build Windows não encontrado em ${winBuildDir.path}, pulando...',
    );
  }

  final linuxBuildDir = Directory('build/linux/x64/release/bundle');
  final linuxOutputDir = Directory(
    '${outputDir.path}/${appName}_v${versionString}_linux',
  );
  if (linuxBuildDir.existsSync()) {
    _copyDirectory(linuxBuildDir, linuxOutputDir);
    print('✅ Sucesso: Linux app copiado para ${linuxOutputDir.path}');
  } else {
    print(
      '⚠️  Aviso: Build Linux não encontrado em ${linuxBuildDir.path}, pulando...',
    );
  }

  print('\n🎉 Processo finalizado!');
}

void _copyDirectory(Directory source, Directory destination) {
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }
  for (var entity in source.listSync()) {
    final newPath =
        '${destination.path}/${entity.path.split(Platform.pathSeparator).last}';
    if (entity is File) {
      entity.copySync(newPath);
    } else if (entity is Directory) {
      _copyDirectory(entity, Directory(newPath));
    }
  }
}
