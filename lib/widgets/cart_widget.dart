import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class CartWidget extends StatelessWidget {
  final List<Product> cart;
  final Function(Product) onRemove;

  const CartWidget({super.key, required this.cart, required this.onRemove});

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, item) => sum + (item.price));

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Carrinho de Compras'),
          content: cart.isEmpty
              ? const Text('O carrinho está vazio.')
              : SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cart.length,
                          itemBuilder: (_, index) {
                            final product = cart[index];
                            return ListTile(
                              leading: product.imageBytes != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          MemoryImage(product.imageBytes!),
                                    )
                                  : (product.imagePath != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(File(product.imagePath!)),
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.image))),
                              title: Text(product.name),
                              subtitle: Text(_formatCurrency(product.price)),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  onRemove(product);
                                  setState(() {}); // Atualiza o total e a lista
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: ${_formatCurrency(total)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
