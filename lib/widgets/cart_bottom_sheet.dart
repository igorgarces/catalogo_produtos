import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/cart_repository.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartRepository>(builder: (context, cart, _) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Carrinho', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(child: Text('Seu carrinho está vazio.'))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (_, i) {
                        final it = cart.items[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text(it.product.name[0].toUpperCase())),
                          title: Text(it.product.name),
                          subtitle: Text('R\$ ${it.product.price.toStringAsFixed(2)} x ${it.quantity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => cart.removeProduct(it.product),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6, offset: const Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('R\$ ${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cart.items.isEmpty
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Compra finalizada com sucesso!')));
                              cart.clearCart();
                              Navigator.pop(context);
                            },
                      child: const Text('Finalizar compra'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
