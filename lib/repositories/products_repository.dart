import 'dart:math';

class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class ProductsRepository {
  int _page = 0;
  final int _itemsPerPage = 6;
  final Random _random = Random();

  // Limites de preço
  final double _minPrice = 10;      // preço mínimo
  final double _maxPrice = 5000;    // preço máximo

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 2)); // simula delay API

    if (_page >= 5) {
      return []; 
    }

    List<Product> newItems = List.generate(_itemsPerPage, (index) {
      int number = _page * _itemsPerPage + index + 1;
      double price = _minPrice + _random.nextDouble() * (_maxPrice - _minPrice);

      return Product(
        name: "Produto $number",
        description: "Descrição breve do produto $number...",
        price: price,
        imageUrl: "https://via.placeholder.com/100?text=$number",
      );
    });

    _page++;
    return newItems;
  }
}
