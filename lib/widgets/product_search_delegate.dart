import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;
  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado.'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(results[i].name),
        subtitle: Text('R\$ ${results[i].price.toStringAsFixed(2)}'),
        onTap: () => close(context, results[i].name),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i].name),
        onTap: () => query = suggestions[i].name,
      ),
    );
  }
}
