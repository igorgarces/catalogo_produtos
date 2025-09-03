import '../models/product.dart';

class CartRepository {
  final List<Product> _items = [];

  List<Product> getAll() => List.unmodifiable(_items);

  void add(Product product) {
    _items.add(product);
  }

  void remove(Product product) {
    _items.remove(product);
  }

  void clear() {
    _items.clear();
  }
}