import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/cart_notifier.dart';

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
          const Text(
            "Carrinho",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Lista de itens no carrinho
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

          // Total e botão de checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: cart.items.isEmpty
                    ? null
                    : () {
                        // Aqui futuramente podemos abrir uma tela de pagamento/checkout
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Finalizar compra ainda não implementado")),
                        );
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

// 🔹 Função helper para abrir o BottomSheet
void openCartSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const CartBottomSheet(),
  );
}
