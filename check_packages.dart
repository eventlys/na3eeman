import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('pubspec.yaml');
  final lines = await file.readAsLines();
  
  bool inDependencies = false;
  List<String> packages = [];
  Map<String, String> versions = {};
  
  for (var line in lines) {
    if (line.startsWith('dependencies:')) {
      inDependencies = true;
      continue;
    }
    if (inDependencies && !line.startsWith(' ') && line.trim().isNotEmpty) {
      if (!line.startsWith('dev_dependencies:') && !line.startsWith('flutter:')) {
         // might be a blank line
      } else {
         break;
      }
    }
    
    if (inDependencies && line.trim().isNotEmpty && !line.trim().startsWith('#')) {
      var parts = line.split(':');
      if (parts.length >= 2) {
        var name = parts[0].trim();
        var version = parts.sublist(1).join(':').trim();
        if (name != 'flutter' && name != 'flutter_localizations' && name != 'sdk') {
          packages.add(name);
          versions[name] = version;
        }
      }
    }
  }

  for (var name in packages) {
    var v = versions[name]!;
    bool is0x = v.startsWith('^0.') || v.startsWith('0.');
    bool isBetaAlpha = v.contains('beta') || v.contains('alpha') || v.contains('dev');
    
    try {
      var url = Uri.parse('https://pub.dev/api/packages/\$name');
      var response = await HttpClient().getUrl(url).then((req) => req.close());
      var responseBody = await response.transform(utf8.decoder).join();
      var data = jsonDecode(responseBody);
      
      bool isDiscontinued = data['isDiscontinued'] ?? false;
      var latest = data['latest']?['version'] ?? 'unknown';
      
      var scoreUrl = Uri.parse('https://pub.dev/api/packages/\$name/score');
      var scoreResponse = await HttpClient().getUrl(scoreUrl).then((req) => req.close());
      var scoreBody = await scoreResponse.transform(utf8.decoder).join();
      var scoreData = jsonDecode(scoreBody);
      
      int likes = scoreData['likeCount'] ?? 0;
      
      print('\$name (\$v): Likes=\$likes, Discontinued=\$isDiscontinued, 0.x=\$is0x, beta/alpha=\$isBetaAlpha, latest=\$latest');
    } catch (e) {
      print('\$name (\$v): Error \$e');
    }
  }
}
