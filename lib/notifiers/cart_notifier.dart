import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../repositories/order_repository.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartNotifier extends ChangeNotifier {
  static final Logger _logger = Logger('CartNotifier');
  
  final OrdersRepository ordersRepo;
  final List<CartItem> _items = [];

  CartNotifier({required this.ordersRepo});

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (prev, e) => prev + e.quantity);

  double get totalPrice =>
      _items.fold(0, (prev, e) => prev + e.product.price * e.quantity);

  void addProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index != -1) {
      _items[index].quantity--;
      if (_items[index].quantity <= 0) _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeFromCart(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> finalizePurchase() async {
    if (_items.isEmpty) {
      _logger.warning('Carrinho vazio - não é possível finalizar compra');
      return;
    }

    _logger.info('Finalizando compra com ${_items.length} itens');
    _logger.info('Itens no carrinho:');
    for (final item in _items) {
      _logger.info(' - ${item.product.name} x ${item.quantity} = R\$${(item.product.price * item.quantity).toStringAsFixed(2)}');
    }
    
    final purchase = Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _items.map((i) => i.product).toList(),
      total: totalPrice,
      date: DateTime.now(),
    );

    _logger.info('Pedido criado: ${purchase.id}');
    _logger.info('Total do pedido: R\$${purchase.total.toStringAsFixed(2)}');
    
    try {
      await ordersRepo.addOrder(purchase);
      _logger.info('Compra finalizada com sucesso!');
      clearCart();
    } catch (e) {
      _logger.severe('Erro ao finalizar compra: $e');
      rethrow;
    }
  }
}