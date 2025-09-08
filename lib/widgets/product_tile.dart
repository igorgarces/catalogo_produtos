import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:catalogo_produtos/repositories/products_repository.dart';
import 'package:intl/intl.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final Uint8List? webImageBytes;
  final VoidCallback? onEdit;
  final VoidCallback? onAddToCart;

  const ProductTile({
    super.key,
    required this.product,
    this.webImageBytes,
    this.onEdit,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // Formatação de preço para padrão brasileiro
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    Widget imageWidget;

    if (product.imageUrl.isNotEmpty) {
      if (product.imageUrl.startsWith("http")) {
        imageWidget = Image.network(
          product.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) { return _fallbackImage(); },
        );
      } else {
        if (kIsWeb) {
          if (webImageBytes != null) {
            imageWidget = Image.memory(webImageBytes!, width: 60, height: 60, fit: BoxFit.cover);
          } else {
            imageWidget = _fallbackImage();
          }
        } else {
          imageWidget = Image.file(
            File(product.imageUrl),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) { return _fallbackImage(); },
          );
        }
      }
    } else {
      imageWidget = _fallbackImage();
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
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
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(product.price),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () { if (onEdit != null) { onEdit!(); } },
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () { if (onAddToCart != null) { onAddToCart!(); } },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _fallbackImage() => Container(
        width: 60,
        height: 60,
        color: Colors.grey.shade800,
        child: const Icon(Icons.image_not_supported, color: Colors.white),
      );
}
