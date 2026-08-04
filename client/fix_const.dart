import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      
      content = content.replaceAllMapped(
        RegExp(r'const\s+([A-Za-z0-9_]+)\([^]*?context\.colors[^]*?\)'),
        (match) => match.group(0)!.replaceFirst('const ', '')
      );
      
      entity.writeAsStringSync(content);
    }
  }
  print('Done');
}
