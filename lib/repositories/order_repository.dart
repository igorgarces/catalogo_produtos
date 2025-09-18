import '../models/purchase.dart';
import 'file_storage.dart';

class OrdersRepository {
  final List<Purchase> _orders = [];
  final String _fileName = 'orders.json';

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

  List<Purchase> allOrders() => List.unmodifiable(_orders);

  Future<void> addOrder(Purchase order) async {
    _orders.insert(0, order);
    await saveOrders();
  }

  Purchase? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await saveOrders();
  }
}
