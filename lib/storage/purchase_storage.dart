import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/purchase.dart';

class PurchaseStorage {
  static Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/purchases.json';
  }

  static Future<void> savePurchase(Purchase purchase) async {
    final path = await _filePath;
    final file = File(path);

    List<dynamic> existing = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) existing = jsonDecode(content) as List<dynamic>;
    }

    existing.add(purchase.toJson());
    await file.writeAsString(jsonEncode(existing));
  }

  static Future<List<Purchase>> loadPurchases() async {
    final path = await _filePath;
    final file = File(path);

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    final list = jsonDecode(content) as List;
    return list.map((e) => Purchase.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> clearCart() async {}

  static Future loadCart() async {}
}
