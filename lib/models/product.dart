import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;

  // Novo campos para imagens e destaque
  final Uint8List? imageBytes; // Web + Mobile
  final String? imagePath;     // Mobile
  final bool isFeatured;

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
}
