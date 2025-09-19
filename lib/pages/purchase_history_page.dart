import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/order_repository.dart';
import '../models/purchase.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<Purchase>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final ordersRepo = context.read<OrdersRepository>();
    _futureOrders = ordersRepo.fetchOrders();
  }

  Future<void> _deleteOrder(String id) async {
    final ordersRepo = context.read<OrdersRepository>();
    await ordersRepo.deleteOrder(id);
    _loadOrders(); // recarrega lista
    setState(() {}); // força rebuild do FutureBuilder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido removido')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Compras')),
      body: FutureBuilder<List<Purchase>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma compra realizada.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final purchase = orders[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('Compra #${purchase.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: R\$ ${purchase.total.toStringAsFixed(2)}'),
                      Text('Data: ${purchase.date.toLocal()}'),
                      const SizedBox(height: 4),
                      ...purchase.items.map(
                        (p) => Text('- ${p.name} (R\$ ${p.price.toStringAsFixed(2)})'),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(purchase.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
