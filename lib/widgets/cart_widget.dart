import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  final int totalItems;
  final VoidCallback onPressed;

  const CartWidget({
    super.key,
    required this.totalItems,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: onPressed,
              child: const Icon(Icons.shopping_cart),
            ),
          ),
          if (totalItems > 0)
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(
                radius: 11,
                backgroundColor: Colors.red,
                child: Text(
                  totalItems.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
