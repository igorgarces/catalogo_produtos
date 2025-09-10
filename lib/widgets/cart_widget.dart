import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/cart_repository.dart';

class CartWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CartWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartRepository>(
      builder: (context, cart, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: onPressed,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                "R\$ ${cart.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            if (cart.totalItems > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    cart.totalItems.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
