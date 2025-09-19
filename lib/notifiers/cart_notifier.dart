import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../repositories/order_repository.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartNotifier extends ChangeNotifier {
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

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> finalizePurchase() async {
    if (_items.isEmpty) return;

    final purchase = Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _items.map((i) => i.product).toList(),
      total: totalPrice,
      date: DateTime.now(),
    );

    await ordersRepo.addOrder(purchase);

    clearCart(); // 🔹 garante que carrinho esvazia depois da compra
  }

  void removeFromCart(Product product) {}
}
