import '../models/purchase.dart';
import 'file_storage.dart';

class OrdersRepository {
  final String _fileName = 'orders.json';
  final List<Purchase> _orders = [];

  OrdersRepository();

  Future<void> init() async {
    await FileStorage.ensureLocalFile(_fileName, _fileName);
    await loadOrders();
  }

  Future<void> loadOrders() async {
    final data = await FileStorage.readJson(_fileName);
    _orders.clear();

    if (data != null) {
      _orders.addAll(
        (data as List)
            .map((x) => Purchase.fromJson(Map<String, dynamic>.from(x))),
      );
    }
  }

  Future<void> saveOrders() async {
    final data = _orders.map((o) => o.toJson()).toList();
    await FileStorage.saveJson(_fileName, data);
  }

  Future<void> addOrder(Purchase order) async {
    _orders.insert(0, order);
    await saveOrders();
  }

  List<Purchase> allOrders() => List.unmodifiable(_orders);

  Future<void> deleteOrder(String id) async {}
}
