import 'dart:math';
import 'dart:typed_data';

class Product {
  final String id;
  String name;
  String description;
  double price;
  String? imageUrl;
  Uint8List? imageBytes;
  String category;
  int stock;
  bool isFavorite;
  bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.imageBytes,
    required this.category,
    required this.stock,
    this.isFavorite = false,
    this.isFeatured = false,
  });

  // Igualdade por id para funcionar bem no carrinho/edição
  @override
  bool operator ==(Object other) => identical(this, other) || (other is Product && other.id == id);
  @override
  int get hashCode => id.hashCode;

  Product copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    Uint8List? imageBytes,
    String? category,
    int? stock,
    bool? isFavorite,
    bool? isFeatured,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class ProductsRepository {
  int _page = 0;
  final int _itemsPerPage = 10;
  final Random _random = Random();

  final List<String> categories = ['Eletrônicos', 'Roupas', 'Alimentos'];

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 600)); // mais ágil

    if (_page >= 5) return [];

    List<Product> newItems = List.generate(_itemsPerPage, (index) {
      int number = _page * _itemsPerPage + index + 1;
      final price = (_random.nextInt(6000) + 10).toDouble();
      return Product(
        id: 'p$number',
        name: "Produto $number",
        description: "Descrição breve do produto $number...",
        price: price,
        imageUrl: "https://via.placeholder.com/300x200?text=$number",
        category: categories[_random.nextInt(categories.length)],
        stock: _random.nextInt(20),
        isFeatured: _random.nextBool() && price > 30, // alguns destaques
      );
    });

    _page++;
    return newItems;
  }
}
