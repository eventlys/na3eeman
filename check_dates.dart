import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('pubspec.yaml');
  final lines = await file.readAsLines();
  
  bool inDependencies = false;
  List<String> packages = [];
  
  for (var line in lines) {
    if (line.startsWith('dependencies:')) {
      inDependencies = true;
      continue;
    }
    if (inDependencies && !line.startsWith(' ') && line.trim().isNotEmpty) {
      if (!line.startsWith('dev_dependencies:') && !line.startsWith('flutter:')) {
      } else {
         break;
      }
    }
    
    if (inDependencies && line.trim().isNotEmpty && !line.trim().startsWith('#')) {
      var parts = line.split(':');
      if (parts.length >= 2) {
        var name = parts[0].trim();
        if (name != 'flutter' && name != 'flutter_localizations' && name != 'sdk') {
          packages.add(name);
        }
      }
    }
  }

  for (var name in packages) {
    try {
      var url = Uri.parse('https://pub.dev/api/packages/\$name');
      var response = await HttpClient().getUrl(url).then((req) => req.close());
      var responseBody = await response.transform(utf8.decoder).join();
      var data = jsonDecode(responseBody);
      
      var latest = data['latest'];
      if (latest != null) {
        var published = latest['published'];
        print('\$name: \$published');
      }
    } catch (e) {
    }
  }
}
