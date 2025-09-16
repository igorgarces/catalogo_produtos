import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

class FileStorage {
  // Retorna o caminho do arquivo (Mobile/desktop) ou null na Web
  static Future<String?> getFilePath(String fileName) async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  static Future<void> saveJson(String fileName, dynamic data) async {
    final content = jsonEncode(data);
    if (kIsWeb) {
      html.window.localStorage[fileName] = content;
    } else {
      final path = await getFilePath(fileName);
      if (path != null) File(path).writeAsStringSync(content);
    }
  }

  static Future<dynamic> readJson(String fileName) async {
    if (kIsWeb) {
      final content = html.window.localStorage[fileName];
      return content != null ? jsonDecode(content) : null;
    } else {
      final path = await getFilePath(fileName);
      if (path != null && File(path).existsSync()) {
        return jsonDecode(File(path).readAsStringSync());
      }
      return null;
    }
  }
}
