import 'dart:typed_data';

class Product {
  String name; 
  double price;
  String description;
  String category;
  String? imagePath;
  Uint8List? imageBytes;

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    this.imagePath,
    this.imageBytes,
  });
}