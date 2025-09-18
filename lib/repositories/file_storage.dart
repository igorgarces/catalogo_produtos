import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:universal_html/html.dart' as html;

class FileStorage {
  /// Salva JSON em arquivo local (Mobile) ou localStorage (Web)
  static Future<void> saveJson(String fileName, dynamic data) async {
    final content = jsonEncode(data);

    if (kIsWeb) {
      html.window.localStorage[fileName] = content;
    } else {
      final file = await getLocalFile(fileName);
      await file.writeAsString(content);
    }
  }

  /// Lê JSON de arquivo local (Mobile) ou localStorage (Web)
  static Future<dynamic> readJson(String fileName) async {
    if (kIsWeb) {
      final content = html.window.localStorage[fileName];
      return content != null ? jsonDecode(content) : null;
    } else {
      final file = await getLocalFile(fileName);
      if (await file.exists()) {
        final content = await file.readAsString();
        return content.isNotEmpty ? jsonDecode(content) : null;
      }
      return null;
    }
  }

  /// Retorna arquivo local (somente Mobile)
  static Future<File> getLocalFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Garante que arquivo local exista (somente Mobile)
  static Future<void> ensureLocalFile(String fileName, String defaultAsset) async {
    if (kIsWeb) return;
    final file = await getLocalFile(fileName);
    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/$fileName');
      await file.writeAsString(data);
    }
  }
}
