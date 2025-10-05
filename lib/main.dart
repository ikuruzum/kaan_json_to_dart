import 'dart:io';

import 'package:kaan_json_to_dart/clipboard.dart';
import "package:path/path.dart" show dirname, join, normalize;

import 'json_to_dart.dart';

String _scriptPath() {
  var script = Platform.script.toString();
  if (script.startsWith("file://")) {
    script = script.substring(7);
  } else {
    final idx = script.indexOf("file:/");
    script = script.substring(idx + 5);
  }
  return script;
}

main() async{
  final classGenerator = ModelGenerator('Sample');
  var currentDirectory = dirname(_scriptPath());
  // currentDirectory = currentDirectory.substring(1);
  var filePath = normalize(join(currentDirectory, 'input.json'));
  if (Platform.isWindows) {
    if (filePath.startsWith(r"\")) {
      filePath = filePath.substring(1);
    }
  }
  String jsonRawData = await File(filePath).readAsString().catchError((e)=> cl.read());
  DartCode dartCode = classGenerator.generateDartClasses(jsonRawData);
  print(dartCode.code);
  cl.write(dartCode.code);
}
