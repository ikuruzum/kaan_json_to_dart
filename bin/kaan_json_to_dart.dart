import 'dart:io';

import 'package:kaan_json_to_dart/helpers.dart';
import 'package:kaan_json_to_dart/model_generator.dart';
import 'package:path/path.dart';

void main(List<String> arguments) {
  var ayirici = Platform.isWindows ? "\\" : "/";

  stdout.writeln('Json nerede (/x/y/z/abc.json)?');
  final yer = stdin.readLineSync() ?? "";

  if (Directory(yer).existsSync()) {
    Directory(yer).listSync().forEach((entity) {
      if (entity is File) {
        var ad = basename(yer);
        tekDosya(ad, yer, ayirici, true);
      }
    });
  } else if (File(yer).existsSync()) {
    stdout.writeln('Adı ne olsun?');
    final ad = stdin.readLineSync() ?? "";
    tekDosya(camelCase(ad), yer, ayirici, true);
  } else {
    stdout.writeln('Geçerli yer girmelisin');
    exit(1);
  }
}

String reversed(String a) {
  return a.split('').reversed.join();
}

String toSnakeCase(String val) {
  RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
  return val
      .replaceAllMapped(exp, (Match m) => ('_${m.group(0) ?? ""}'))
      .toLowerCase();
}

void tekDosya(String ad, String yer, String ayirici,
    [modelfile = false]) async {
  try {
    final classGenerator = ModelGenerator(ad);
    final jsonRawData = File(yer).readAsStringSync();
    DartCode dartCode = classGenerator.generateDartClasses(jsonRawData);
    var yazilcak = reversed(yer);

    yazilcak = yazilcak.substring(yazilcak.indexOf(ayirici));
    yazilcak = reversed(yazilcak);
    var dosya = File("$yazilcak${toSnakeCase(ad)}.dart");
    if (dosya.existsSync()) {
      stdout.writeln(
          "${basename(dosya.path)} diye bir dosya mevcut, bu es geçiliyor. Geçilmesini istemiyorsan dosyayı sil");
    }
    await dosya.create();
    await dosya.writeAsString(dartCode.code);
  } catch (e) {
    stdout.writeln(
        "bir şeyler yanlış gitti, sorunu bulabilmen için ilgili hata ise şu : \n\n\n  $e");
  }
}
