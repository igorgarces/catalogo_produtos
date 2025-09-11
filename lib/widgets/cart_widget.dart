import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/cart_notifier.dart';

class CartWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const CartWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text('${cart.totalItems} itens - R\$ ${cart.totalPrice.toStringAsFixed(2)}'),
      icon: const Icon(Icons.shopping_cart),
    );
  }
}
