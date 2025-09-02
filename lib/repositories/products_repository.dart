import '../models/product.dart';

class ProductsRepository {
  final List<Product> _products = [
    Product(
      name: 'Camiseta',
      price: 49.9, 
      description: 'Camiseta de algodão confortável',
      category: 'Roupas',
    ),
    Product(
      name: 'Fone Bluetooth',
      price: 199.0,
      description: 'Fone sem fio com cancelamento de ruído',
      category: 'Eletrônicos',
    ),
    Product(
      name: 'As cronicas de Galliot: O homem da mascara negra',
      price: 50.0,
      description: 'Meu livro autoral de fantasia',
      category: 'Livros',
    ),
  ];

  List<Product> getAll() => List.unmodifiable(_products);

  void add(Product product) => _products.add(product);

  void updated(int index, Product product) => _products[index] = product;

  void delete(int index) => _products.removeAt(index);
}