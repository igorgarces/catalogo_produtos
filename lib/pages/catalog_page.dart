import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../widgets/cart_widget.dart';
import '../widgets/product_tile.dart';
import 'product_form_page.dart';

class CatalogPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const CatalogPage({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<Product> products = [
    Product(name: 'Camiseta', price: 29.9, description: 'Camiseta confortável', category: 'Roupas'),
    Product(name: 'Fone de Ouvido', price: 199.9, description: 'Fone bluetooth', category: 'Eletrônicos'),
    Product(name: 'As Crônicas de Galliot', price: 48.99, description: 'Meu livro autoral de fantasia', category: 'Livros')
  ];

  List<Product> cart = [];

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  void _addOrEditProduct({Product? product, int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          product: product,
          onSave: (p) {
            setState(() {
              if (index == null) {
                products.add(p);
              } else {
                products[index] = p;
              }
            });
          },
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() => cart.add(product));
  }

  void _removeFromCart(Product product) {
    setState(() => cart.remove(product));
  }

  void _removeProduct(Product product) {
    setState(() => products.remove(product));
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (_) => CartWidget(cart: cart, onRemove: _removeFromCart),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeChanged,
          ),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: _showCartDialog),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(cart.length.toString(), style: const TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('Nenhum produto disponível.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final product = products[index];
                return ProductTile(
                  product: product,
                  onEdit: () => _addOrEditProduct(product: product, index: index),
                  onAddToCart: () => _addToCart(product),
                  onRemove: () => _removeProduct(product), // Adiciona botão remover
                  formatPrice: _formatCurrency, // Passa função de formatação
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditProduct(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
