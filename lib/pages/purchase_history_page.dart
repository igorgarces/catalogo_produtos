import 'package:catalogo_produtos/models/purchase.dart';
import 'package:catalogo_produtos/storage/purchase_storage.dart';
import 'package:flutter/material.dart';
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
    _purchasesFuture = PurchaseStorage.loadPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
      ),
      body: FutureBuilder<List<Purchase>>(
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
                  subtitle: Text('Total: R\$ ${purchase.total.toStringAsFixed(2)}'),
                  children: purchase.items.map((p) => _buildProductRow(p)).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return ListTile(
      leading: product.imageBytes != null
          ? Image.memory(product.imageBytes!, width: 40, height: 40, fit: BoxFit.cover)
          : const Icon(Icons.image),
      title: Text(product.name),
      subtitle: Text('Preço: R\$ ${product.price.toStringAsFixed(2)} - Estoque: ${product.stock}'),
    );
  }
}
