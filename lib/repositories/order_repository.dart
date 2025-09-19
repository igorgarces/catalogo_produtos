import '../models/purchase.dart';
import 'file_storage.dart';

class OrdersRepository {
  final String _fileName = 'orders.json';
  final List<Purchase> _orders = [];

  OrdersRepository();

  /// Inicializa o repositório garantindo que o arquivo existe
  Future<void> init() async {
    await FileStorage.ensureLocalFile(_fileName, _fileName);
    await fetchOrders(forceReload: true);
  }

  /// Busca pedidos já existentes
  Future<List<Purchase>> fetchOrders({bool forceReload = false}) async {
    if (_orders.isNotEmpty && !forceReload) {
      return List.unmodifiable(_orders);
    }

    final data = await FileStorage.readJson(_fileName);
    _orders.clear();

    if (data != null) {
      _orders.addAll(
        (data as List)
            .map((x) => Purchase.fromJson(Map<String, dynamic>.from(x))),
      );
    }

    return List.unmodifiable(_orders);
  }

  /// Retorna lista atual em memória
  List<Purchase> allOrders() => List.unmodifiable(_orders);

  /// Adiciona pedido novo
  Future<void> addOrder(Purchase order) async {
    _orders.insert(0, order);
    await _save();
  }

  /// Exclui pedido pelo id
  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _save();
  }

  /// Salva todos os pedidos no arquivo
  Future<void> _save() async {
    final data = _orders.map((o) => o.toJson()).toList();
    await FileStorage.saveJson(_fileName, data);
  }
}
