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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onOpenDetails,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: product.imageBytes != null
                  ? Image.memory(product.imageBytes!, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.image)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      if (product.isFeatured)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Destaque', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('R\$ ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Estoque: ${product.stock}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                        onPressed: onToggleFavorite,
                        tooltip: 'Favorito',
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: onAddToCart,
                        tooltip: 'Adicionar ao carrinho',
                      ),
                      const Spacer(),
                      PopupMenuButton(
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        ],
                        onSelected: (v) {
                          if (v == 'edit') onEditProduct();
                          if (v == 'delete') onDeleteProduct();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
