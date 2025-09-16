import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
//import 'dart:typed_data';

// dart:html só importado em runtime (para web)
import 'dart:html' as html;

class FileStorage {
  static Future<String?> _localDirPath() async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<void> saveJson(String fileName, dynamic data) async {
    final content = jsonEncode(data);
    if (kIsWeb) {
      html.window.localStorage[fileName] = content;
    } else {
      final dir = await _localDirPath();
      if (dir == null) return;
      final path = '$dir/$fileName';
      await File(path).writeAsString(content);
    }
  }

  static Future<dynamic> readJson(String fileName) async {
    if (kIsWeb) {
      final content = html.window.localStorage[fileName];
      return content != null ? jsonDecode(content) : null;
    } else {
      final dir = await _localDirPath();
      if (dir == null) return null;
      final path = '$dir/$fileName';
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isEmpty) return null;
        return jsonDecode(content);
      }
      return null;
    }
  }
}
