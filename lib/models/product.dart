import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final bool isFeatured;

  final Uint8List? imageBytes;
  final String? imagePath;

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

  factory Product.fromJson(Map<String, dynamic> json) {
    Uint8List? bytes;
    if (json['imageBytes'] != null) {
      // imageBytes pode ser lista int ou base64 string — tratamos ambos
      final raw = json['imageBytes'];
      if (raw is String) {
        try {
          bytes = base64Decode(raw);
        } catch (_) {
          bytes = null;
        }
      } else if (raw is List) {
        bytes = Uint8List.fromList(List<int>.from(raw));
      }
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? 'Sem categoria',
      stock: (json['stock'] is int) ? json['stock'] : int.tryParse('${json['stock']}') ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      imageBytes: bytes,
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'isFeatured': isFeatured,
      // Salvamos imageBytes como base64 (mais compacto para JSON e compatível com web)
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'imagePath': imagePath,
    };
  }
}
