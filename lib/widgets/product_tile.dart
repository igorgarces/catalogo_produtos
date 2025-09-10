import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onEditProduct;
  final VoidCallback onDeleteProduct;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenDetails;

  const ProductTile({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onToggleFavorite,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (product.imageBytes != null) {
      imageWidget = Image.memory(product.imageBytes!, width: 60, height: 60, fit: BoxFit.cover);
    } else if (!kIsWeb && product.imagePath != null) {
      imageWidget = Image.file(File(product.imagePath!), width: 60, height: 60, fit: BoxFit.cover);
    } else {
      imageWidget = _fallbackImage();
    }

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    ),
                    if (product.isFeatured)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Destaque', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(product.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                const SizedBox(height: 4),
                Text("R\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: onAddToCart),
              Row(
                children: [
                  IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
                      onPressed: onToggleFavorite),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.yellow), onPressed: onEditProduct),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDeleteProduct),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(width: 60, height: 60, color: Colors.grey.shade800, child: const Icon(Icons.image_not_supported, color: Colors.white));
  }
}
