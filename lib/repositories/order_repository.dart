import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import '../models/purchase.dart';
import 'file_storage.dart';

class OrdersRepository {
  static final Logger _logger = Logger('OrdersRepository');
  
  final String _fileName = 'orders.json';
  final List<Purchase> _orders = [];

  OrdersRepository();

  Future<void> init() async {
    await FileStorage.ensureLocalFile(_fileName, _fileName);
    await fetchOrders(forceReload: true);
  }

  Future<List<Purchase>> fetchOrders({bool forceReload = false}) async {
    if (_orders.isNotEmpty && !forceReload) {
      return List.unmodifiable(_orders);
    }

    final data = await FileStorage.readJson(_fileName);
    _orders.clear();

    if (data != null && data is List) {
      _orders.addAll(
        data.map((x) => Purchase.fromJson(Map<String, dynamic>.from(x))),
      );
    }

    _logger.info('Pedidos carregados: ${_orders.length}');
    return List.unmodifiable(_orders);
  }

  List<Purchase> allOrders() => List.unmodifiable(_orders);

  Future<void> addOrder(Purchase order) async {
    _logger.info('SALVANDO PEDIDO: ${order.id} - R\$${order.total}');
    
    _orders.insert(0, order);
    
    try {
      await _save();
      _logger.info('Pedido salvo com sucesso! Total: ${_orders.length} pedidos');
      
      if (kIsWeb) {
        _logger.info('Salvo no localStorage do navegador');
      } else {
        final file = await FileStorage.getLocalFile(_fileName);
        _logger.info('Salvo em: ${file.path}');
      }
    } catch (e) {
      _logger.severe('Erro ao salvar pedido: $e');
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _save();
    _logger.info('Pedido $id removido');
  }

  Future<void> _save() async {
    final data = _orders.map((o) => o.toJson()).toList();
    await FileStorage.saveJson(_fileName, data);
    _logger.info('${_orders.length} pedidos salvos em $_fileName');
  }

  Future<void> debugStorage() async {
    _logger.info('=== DEBUG ORDERS REPOSITORY ===');
    _logger.info('Pedidos em memória: ${_orders.length}');
    
    for (final order in _orders) {
      _logger.info(' - ${order.id} | R\$${order.total.toStringAsFixed(2)} | ${order.date}');
      _logger.info('   Itens: ${order.items.map((p) => p.name).join(", ")}');
    }
    
    try {
      final data = await FileStorage.readJson(_fileName);
      if (data != null && data is List) {
        _logger.info('Pedidos no arquivo: ${data.length}');
      } else {
        _logger.info('Arquivo vazio ou não encontrado');
      }
    } catch (e) {
      _logger.severe('Erro ao ler arquivo: $e');
    }
    
    if (kIsWeb) {
      _logger.info('Plataforma: Web (localStorage)');
    } else {
      final file = await FileStorage.getLocalFile(_fileName);
      _logger.info('Plataforma: Mobile');
      _logger.info('Caminho do arquivo: ${file.path}');
      _logger.info('Arquivo existe: ${await file.exists()}');
    }
    _logger.info('==============================');
  }
}