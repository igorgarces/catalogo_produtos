import '../models/product.dart';

class ProductsRepository {
  final List<String> categories = ['Roupas', 'Livros', 'Eletrônicos'];

  final List<Product> _products = [
    Product(
        id: '1',
        name: 'Camisa Azul',
        description: 'Camisa azul de algodão',
        price: 49.9,
        category: 'Roupas',
        stock: 10,
        isFeatured: true),
    Product(
        id: '2',
        name: 'As Cronicas de Galliot',
        description: 'Meu livro autoral de fantasia',
        price: 79.9,
        category: 'Livros',
        stock: 5),
    Product(
        id: '3',
        name: 'Fone de Ouvido',
        description: 'Fone Bluetooth sem fio',
        price: 199.9,
        category: 'Eletrônicos',
        stock: 3,
        isFeatured: true),
  ];

  Future<List<Product>> fetchProducts({int start = 0, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (start >= _products.length) return [];
    final end = (start + limit).clamp(0, _products.length);
    return _products.sublist(start, end);
  }

  void addProduct(Product p) => _products.insert(0, p);

  void updateProduct(Product p) {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i != -1) _products[i] = p;
  }

  void deleteProduct(String id) => _products.removeWhere((p) => p.id == id);
}
