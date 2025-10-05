# kaan_json_to_dart

A Dart library that automatically generates Dart model classes from JSON strings, complete with `fromJson` and `toJson` methods for seamless serialization and deserialization.

## Features

- **Automatic Class Generation**: Converts JSON objects into Dart classes with proper type inference
- **Nested Object Support**: Handles complex nested JSON structures and generates separate classes for nested objects
- **Array Handling**: Intelligently processes JSON arrays and generates appropriate List types
- **Type Safety**: Infers correct Dart types (int, double, String, bool, DateTime, custom classes)
- **Merge Capability**: Merges multiple JSON objects to create comprehensive class definitions
- **Code Formatting**: Generates properly formatted, idiomatic Dart code using `dart_style`
- **Warning System**: Provides warnings for ambiguous types, empty lists, and type conflicts
- **Private Fields Support**: Optional generation of classes with private fields and getters/setters

## Usage

### Quick Start

1. **Option A:** Place your JSON data in `lib/input.json`
2. **Option B:** Copy your JSON to the clipboard (used as fallback if file not found)
3. Run the main script:

```bash
dart run lib/main.dart
```

The generated Dart classes will be:

- Printed to the console
- Copied to your clipboard automatically

### How It Works

The `main.dart` script reads JSON from `lib/input.json`, or falls back to reading from your clipboard if the file doesn't exist:

```dart
import 'dart:io';
import 'package:kaan_json_to_dart/clipboard.dart';
import 'json_to_dart.dart';

main() async {
  final classGenerator = ModelGenerator('Sample');
  var currentDirectory = dirname(_scriptPath());
  var filePath = normalize(join(currentDirectory, 'input.json'));
  
  // Read from file, or fallback to clipboard if file not found
  String jsonRawData = await File(filePath).readAsString().catchError((e) => cl.read());
  DartCode dartCode = classGenerator.generateDartClasses(jsonRawData);
  
  print(dartCode.code);  // Print to console
  cl.write(dartCode.code);  // Copy to clipboard
}
```

### Programmatic Usage

You can also use the library programmatically in your own code:

```dart
import 'package:kaan_json_to_dart/json_to_dart.dart';

void main() {
  final jsonString = '''
  {
    "id": "1046",
    "name": "John Doe",
    "age": 25,
    "isActive": true
  }
  ''';

  final generator = ModelGenerator('User');
  final dartCode = generator.generateDartClasses(jsonString);
  
  print(dartCode.code);
  
  // Check for warnings
  for (var warning in dartCode.warnings) {
    print('Warning at ${warning.path}: ${warning.warning}');
  }
}
```

### Generated Output

The above example generates:

```dart
class User {
  String aId = '';
  String name = '';
  int age = 0;
  bool isActive = false;

  User({String? aId, String? name, int? age, bool? isActive}) {
    this.aId = aId ?? this.aId;
    this.name = name ?? this.name;
    this.age = age ?? this.age;
    this.isActive = isActive ?? this.isActive;
  }

  User.fromJson(Map<String, dynamic> json) {
    var json = j.map((key, value) => MapEntry(key, value is String ? value.trim() : value));
    aId = json['id'];
    name = json['name'];
    age = json['age'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = aId;
    data['name'] = name;
    data['age'] = age;
    data['isActive'] = isActive;
    return data;
  }
}
```

### Advanced Features

#### Private Fields

```dart
final generator = ModelGenerator('User', true); // Enable private fields
```

#### Type Hints

```dart
final hints = [
  Hint('/user/createdAt', 'DateTime'),
  Hint('/user/tags', 'List<String>')
];
final generator = ModelGenerator('User', false, hints);
```

#### Handling Arrays

When JSON contains arrays of objects, the library automatically merges them to create a comprehensive class definition:

```dart
final jsonString = '''
[
  {"id": 1, "name": "Alice"},
  {"id": 2, "email": "bob@example.com"}
]
''';

// Generates a class with all fields: id, name, and email
```

## API Reference

### ModelGenerator

**Constructor:**

```dart
ModelGenerator(String rootClassName, [bool privateFields = false, List<Hint>? hints])
```

**Methods:**

- `generateDartClasses(String rawJson)`: Generates formatted Dart code with validation
- `generateUnsafeDart(String rawJson)`: Generates unformatted Dart code (faster, no validation)

### DartCode

Contains the generated code and any warnings:

- `code`: The generated Dart code as a String
- `warnings`: List of Warning objects

### Warning

- `warning`: Description of the warning
- `path`: JSON path where the warning occurred

## Type Inference

The library automatically infers types:

- **Primitives**: `int`, `double`, `String`, `bool`
- **DateTime**: Detected from ISO 8601 strings
- **Lists**: Typed lists like `List<int>`, `List<String>`, or `List<CustomClass>`
- **Custom Classes**: Generated for nested objects
- **Null Safety**: Handles nullable types appropriately

## Warning Types

- **Empty List**: When a JSON array is empty, type cannot be inferred
- **Ambiguous List**: When array elements have different types
- **Ambiguous Type**: When the same field has different types across merged objects

## Project Structure

```text
lib/
├── json_to_dart.dart       # Main export file
├── model_generator.dart    # Core generator logic
├── syntax.dart            # Class and type definitions
├── helpers.dart           # Utility functions
├── clipboard.dart         # Clipboard operations
├── json_ast/              # JSON AST parser
└── main.dart              # Example usage
```

## Contributing

This is a fork of [json_to_dart](https://github.com/javiercbk/json_to_dart) with enhancements and improvements.

## License

See LICENSE file for details.

## Version

Current version: 1.0.6
