import '../models/product.dart';
import 'file_storage.dart';
import 'dart:typed_data';

class ProductsRepository {
  final List<String> categories = ['Roupas', 'Livros', 'Eletrônicos'];
  final List<Product> _products = [];

  ProductsRepository() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await FileStorage.readJson('products.json');
    if (data != null) {
      _products.clear();
      _products.addAll((data as List).map((x) => Product(
        id: x['id'],
        name: x['name'],
        description: x['description'],
        price: (x['price'] as num).toDouble(),
        category: x['category'],
        stock: x['stock'],
        isFeatured: x['isFeatured'] ?? false,
        imageBytes: x['imageBytes'] != null
            ? Uint8List.fromList(List<int>.from(x['imageBytes']))
            : null,
      )));
    } else {
      // Se não existir, cria com produtos iniciais hardcoded
      _products.addAll([
        Product(id: '1', name: 'Camisa branca', description: 'Camisa branca de algodão', price: 49.9, category: 'Roupas', stock: 10, isFeatured: true),
        Product(id: '2', name: 'As Crônicas de Galliot', description: 'Meu livro autoral de fantasia', price: 79.9, category: 'Livros', stock: 5),
        Product(id: '3', name: 'Fone de Ouvido', description: 'Fone Bluetooth sem fio', price: 199.9, category: 'Eletrônicos', stock: 3, isFeatured: true),
      ]);
      saveProducts();
    }
  }

  Future<void> saveProducts() async {
    final data = _products.map((p) => {
      'id': p.id,
      'name': p.name,
      'description': p.description,
      'price': p.price,
      'category': p.category,
      'stock': p.stock,
      'isFeatured': p.isFeatured,
      'imageBytes': p.imageBytes?.toList(),
    }).toList();
    await FileStorage.saveJson('products.json', data);
  }

  Future<List<Product>> fetchProducts({int start = 0, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (start >= _products.length) return [];
    final end = (start + limit).clamp(0, _products.length);
    return _products.sublist(start, end);
  }

  void addProduct(Product p) {
    _products.insert(0, p);
    saveProducts();
  }

  void updateProduct(Product p) {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i != -1) {
      _products[i] = p;
      saveProducts();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    saveProducts();
  }
}
