import 'package:catalogo_produtos/models/purchase.dart';
import 'package:catalogo_produtos/storage/purchase_storage.dart';
import 'package:flutter/material.dart';
import 'catalog_page.dart';
import '../models/product.dart';

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
    final cartItems = await PurchaseStorage.loadCart();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carrinho vazio! Adicione produtos antes.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CatalogPage(onToggleTheme: () {}),
        ),
      );
      return;
    }

    final purchase = Purchase.fromCart(cartItems);
    await PurchaseStorage.savePurchase(purchase);

    await PurchaseStorage.clearCart();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compra finalizada e registrada!")),
    );

    _loadPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Atualizar lista",
            onPressed: _loadPurchases,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadPurchases();
        },
        child: FutureBuilder<List<Purchase>>(
          future: _purchasesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchases = snapshot.data ?? [];

            if (purchases.isEmpty) {
              return const Center(
                child: Text('Nenhuma compra realizada ainda.'),
              );
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
                    subtitle:
                        Text('Total: R\$ ${purchase.total.toStringAsFixed(2)}'),
                    children:
                        purchase.items.map((p) => _buildProductRow(p)).toList(),
                  ),
                );
              },
            );
          },
        ),
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
