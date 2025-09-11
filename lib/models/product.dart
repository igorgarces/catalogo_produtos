import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final bool isFeatured;

  // Imagem
  final Uint8List? imageBytes; // preview web/mobile
  final String? imagePath;     // mobile storage

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    this.imageBytes,
    this.imagePath,
    this.isFeatured = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? stock,
    Uint8List? imageBytes,
    String? imagePath,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageBytes: imageBytes ?? this.imageBytes,
      imagePath: imagePath ?? this.imagePath,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
