import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/purchase_notifier.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Carrinho", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (cart.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Seu carrinho está vazio."),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cart.items.length,
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  return ListTile(
                    leading: item.product.imageBytes != null
                        ? Image.memory(item.product.imageBytes!, width: 40, height: 40, fit: BoxFit.cover)
                        : const Icon(Icons.shopping_bag),
                    title: Text(item.product.name),
                    subtitle: Text("Qtd: ${item.quantity}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("R\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}"),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cart.removeFromCart(item.product),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: cart.items.isEmpty
                    ? null
                    : () async {
                        await cart.finalizePurchase();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Compra finalizada e salva!"),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        await Future.delayed(const Duration(milliseconds: 200));
                        Navigator.of(context).pop();
                      },
                child: const Text("Finalizar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
