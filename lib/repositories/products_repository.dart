import '../models/product.dart';
import 'file_storage.dart';

class ProductsRepository {
  final List<String> categories = ['Roupas', 'Livros', 'Eletrônicos'];
  final List<Product> _products = [];

  ProductsRepository();

  Future<void> init() async {
    await loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await FileStorage.readJson('products.json');
    if (data != null) {
      _products.clear();
      _products.addAll(
        (data as List).map(
          (x) => Product.fromJson(Map<String, dynamic>.from(x)),
        ),
      );
    } else {
      // Produtos iniciais
      _products.addAll([
        Product(
          id: '1',
          name: 'Camisa branca',
          description: 'Camisa branca de algodão',
          price: 49.9,
          category: 'Roupas',
          stock: 10,
          isFeatured: true,
        ),
        Product(
          id: '2',
          name: 'As Crônicas de Galliot',
          description: 'Meu livro autoral de fantasia',
          price: 79.9,
          category: 'Livros',
          stock: 5,
        ),
        Product(
          id: '3',
          name: 'Fone de Ouvido',
          description: 'Fone Bluetooth sem fio',
          price: 199.9,
          category: 'Eletrônicos',
          stock: 3,
          isFeatured: true,
        ),
      ]);
      await saveProducts();
    }
  }

  Future<void> saveProducts() async {
    final data = _products.map((p) => p.toJson()).toList();
    await FileStorage.saveJson('products.json', data);
  }

  Future<List<Product>> fetchProducts({int start = 0, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
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

  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> allProducts() => List.unmodifiable(_products);
}
