import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  final VoidCallback onTap;

  const CartWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.onPrimary),
      onPressed: onTap,
    );
  }
}
