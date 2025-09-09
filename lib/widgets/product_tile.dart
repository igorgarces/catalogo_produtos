import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../repositories/products_repository.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onEditProduct;
  final VoidCallback onDeleteProduct;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenDetails;

  const ProductTile({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onToggleFavorite,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildImage();
    final outOfStock = product.stock <= 0;

    return InkWell(
      onTap: onOpenDetails,
      child: Container(
        color: const Color(0xFF111111),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
                if (product.isFeatured)
                  Positioned(
                    left: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Promo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (outOfStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text('Sem estoque', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.pinkAccent),
                        onPressed: onToggleFavorite,
                        tooltip: 'Favoritar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("R\$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.white)),
                      const SizedBox(width: 8),
                      Icon(Icons.inventory_2, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 2),
                      Text('${product.stock}', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: onAddToCart),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.yellow), onPressed: onEditProduct),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDeleteProduct),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final placeholder = Container(
      width: 60, height: 60,
      color: Colors.grey.shade800,
      child: const Icon(Icons.image_not_supported, color: Colors.white),
    );

    if (product.imageBytes != null) {
      return Image.memory(product.imageBytes!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
    }
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(product.imageUrl!, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
    }
    return placeholder;
  }
}
