import 'dart:math';
import '../models/product.dart';

class ProductsRepository {
  int _page = 0;
  final int _itemsPerPage = 6;
  final Random _random = Random();

  final List<String> categories = ['Eletrônicos', 'Roupas', 'Alimentos'];

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_page >= 5) return [];

    List<Product> newItems = List.generate(_itemsPerPage, (index) {
      int number = _page * _itemsPerPage + index + 1;

      return Product(
        id: number.toString(),
        name: "Produto $number",
        description: "Descrição breve do produto $number...",
        price: _random.nextInt(6000).toDouble() + 10,
        category: categories[_random.nextInt(categories.length)],
        stock: _random.nextInt(20),
        isFeatured: _random.nextBool(),
        // Para simulação, podemos deixar imagens nulas
        imageBytes: null,
        imagePath: null,
      );
    });

    _page++;
    return newItems;
  }
}
