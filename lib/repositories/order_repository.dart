import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../notifiers/cart_notifier.dart';

class OrderRepository {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/orders.json');
  }

  Future<List<Map<String, dynamic>>> _readOrders() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) return [];
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(jsonDecode(content));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOrder(CartNotifier cart) async {
    final orders = await _readOrders();
    final order = {
      "id": "order_${DateTime.now().millisecondsSinceEpoch}",
      "items": cart.items
          .map((i) => {"productId": i.product.id, "quantity": i.quantity})
          .toList(),
      "total": cart.totalPrice,
      "date": DateTime.now().toIso8601String()
    };
    orders.add(order);

    final file = await _localFile;
    await file.writeAsString(jsonEncode(orders));
  }
}
