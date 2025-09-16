import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Preferível salvar apenas o id e a quantidade para armazenar no "carrinho".
  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json, Product Function(String id) findProduct) {
    final pid = json['productId']?.toString();
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final product = pid != null ? findProduct(pid) : throw Exception('productId ausente');
    return CartItem(product: product, quantity: qty);
  }
}
