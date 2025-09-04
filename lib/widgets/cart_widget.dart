import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';

class CartWidget extends StatelessWidget {
  final List<Product> cart;
  final Function(Product) onRemove;

  const CartWidget({super.key, required this.cart, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Carrinho de Compras'),
      content: cart.isEmpty
          ? const Text('O carrinho está vazio.')
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cart.length,
                itemBuilder: (_, index) {
                  final product = cart[index];
                  return ListTile(
                    leading: product.imageBytes != null
                        ? CircleAvatar(backgroundImage: MemoryImage(product.imageBytes!))
                        : (product.imagePath != null
                            ? CircleAvatar(backgroundImage: FileImage(File(product.imagePath!)))
                            : const CircleAvatar(child: Icon(Icons.image))),
                    title: Text(product.name),
                    subtitle: Text('R\$ ${product.price}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => onRemove(product),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
      ],
    );
  }
}
