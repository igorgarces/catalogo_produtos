import 'package:flutter/material.dart';
import '../repositories/products_repository.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageBytes != null)
              Image.memory(product.imageBytes!, height: 250, fit: BoxFit.cover)
            else if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Image.network(product.imageUrl!, height: 250, fit: BoxFit.cover)
            else
              Container(height: 250, color: Colors.grey[300], child: const Center(child: Text("Sem imagem"))),
            const SizedBox(height: 16),
            Text(product.name, style: titleStyle),
            const SizedBox(height: 8),
            Text("Preço: R\$${product.price.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            Text("Estoque: ${product.stock} unidades"),
            const SizedBox(height: 8),
            Text("Categoria: ${product.category}"),
            const SizedBox(height: 8),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}
