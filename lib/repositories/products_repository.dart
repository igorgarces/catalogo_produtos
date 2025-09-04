import '../models/product.dart';

class ProductsRepository {
  final List<Product> _products = [
    Product(
      name: 'Camiseta',
      price: 39.90,
      description: 'Camiseta confortável de algodão',
      category: 'Roupas',
      imagePath: 'assets/camiseta.jpg',
    ),
    Product(
      name: 'Notebook',
      price: 3500.00,
      description: 'Notebook rápido e leve',
      category: 'Eletrônicos',
      imagePath: 'assets/notebook.jpg',
    ),
    Product(
      name: 'As cronicas de Galliot: O homem da mascara negra',
      price: 50.90,
      description: 'Meu livro autoral de fantasia',
      category: 'Livros',
      imagePath: 'assets/livro_flutter.jpg',
    ),
  ];

  List<Product> getAll() => _products;

  void add(Product product) => _products.add(product);

  void delete(int index) => _products.removeAt(index);

  void updated(int index, Product product) => _products[index] = product;
}
