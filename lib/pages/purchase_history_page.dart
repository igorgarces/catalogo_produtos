import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/cart_notifier.dart';
import '../storage/purchase_storage.dart';
import '../models/purchase.dart';
import '../models/product.dart';
import 'catalog_page.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<Purchase>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  void _loadPurchases() {
    setState(() {
      _purchasesFuture = PurchaseStorage.loadPurchases();
    });
  }

  Future<void> _finalizePurchase(BuildContext context) async {
    final cart = context.read<CartNotifier>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carrinho vazio! Adicione produtos antes.")),
      );
      return;
    }

    await cart.finalizePurchase();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compra finalizada e registrada!")),
    );

    // Recarrega histórico
    _loadPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Compras')),
      body: FutureBuilder<List<Purchase>>(
        future: _purchasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final purchases = snapshot.data ?? [];

          if (purchases.isEmpty) {
            return const Center(child: Text('Nenhuma compra realizada ainda.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  title: Text(
                    'Compra #${purchase.id} - ${purchase.date.day}/${purchase.date.month}/${purchase.date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Total: R\$ ${purchase.total.toStringAsFixed(2)}'),
                  children: purchase.items.map(_buildProductRow).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.shopping_cart_checkout),
        label: const Text("Finalizar Compra"),
        onPressed: () => _finalizePurchase(context),
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return ListTile(
      leading: product.imageBytes != null
          ? Image.memory(product.imageBytes!,
              width: 40, height: 40, fit: BoxFit.cover)
          : const Icon(Icons.image),
      title: Text(product.name),
      subtitle: Text(
          'Preço: R\$ ${product.price.toStringAsFixed(2)} - Estoque: ${product.stock}'),
    );
  }
}
