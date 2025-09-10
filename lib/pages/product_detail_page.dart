import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (product.imageBytes != null) {
      imageWidget = Image.memory(product.imageBytes!, width: double.infinity, height: 250, fit: BoxFit.cover);
    } else if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      imageWidget = kIsWeb
          ? const Icon(Icons.image, size: 200)
          : Image.file(File(product.imagePath!), width: double.infinity, height: 250, fit: BoxFit.cover);
    } else {
      imageWidget = Container(width: double.infinity, height: 250, color: Colors.grey, child: const Icon(Icons.image, size: 50));
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          imageWidget,
          const SizedBox(height: 12),
          Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('R\$ ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green)),
          const SizedBox(height: 8),
          Text('Estoque: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red)),
          const SizedBox(height: 12),
          Text(product.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          if (product.isFeatured)
            Container(padding: const EdgeInsets.all(8), color: Colors.orange, child: const Text('Produto em destaque', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
