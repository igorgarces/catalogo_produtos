import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/cart_notifier.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();

    return Stack(
      children: [
        const Icon(Icons.shopping_cart),
        if (cart.totalItems > 0)
          Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                cart.totalItems.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          )
      ],
    );
  }
}
