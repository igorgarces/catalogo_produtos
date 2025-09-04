import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onAddToCart;

  const ProductTile({super.key, required this.product, required this.onEdit, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: product.imageBytes != null
            ? CircleAvatar(backgroundImage: MemoryImage(product.imageBytes!))
            : (product.imagePath != null
                ? CircleAvatar(backgroundImage: FileImage(File(product.imagePath!)))
                : const CircleAvatar(child: Icon(Icons.image))),
        title: Text(product.name),
        subtitle: Text('${product.category} - R\$ ${product.price}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: onAddToCart),
          ],
        ),
      ),
    );
  }
}
