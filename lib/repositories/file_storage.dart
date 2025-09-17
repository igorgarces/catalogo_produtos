import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class FileStorage {
  static Future<void> saveJson(String fileName, dynamic data) async {
    final content = jsonEncode(data);

    if (kIsWeb) {
      html.window.localStorage[fileName] = content;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$fileName';
      final file = File(path);
      await file.writeAsString(content);
    }
  }

  static Future<dynamic> readJson(String fileName) async {
    if (kIsWeb) {
      final content = html.window.localStorage[fileName];
      return content != null ? jsonDecode(content) : null;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$fileName';
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        return content.isNotEmpty ? jsonDecode(content) : null;
      }
      return null;
    }
  }
}
