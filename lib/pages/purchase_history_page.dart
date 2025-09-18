import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/order_repository.dart';

class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRepo = context.watch<OrdersRepository>();
    final orders = ordersRepo.allOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Nenhuma compra realizada.'))
          : ListView.builder(
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
                        ...purchase.items.map((p) => Text('- ${p.name} (R\$ ${p.price.toStringAsFixed(2)})')),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await ordersRepo.deleteOrder(purchase.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pedido removido')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
