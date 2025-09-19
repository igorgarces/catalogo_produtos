import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import '../notifiers/products_notifier.dart';
import '../widgets/product_tile.dart';
import '../widgets/filters_bottom_sheet.dart';
import '../pages/product_form_page.dart';
import '../pages/product_detail_page.dart';
import '../pages/purchase_history_page.dart';

class CatalogPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const CatalogPage({super.key, required this.onToggleTheme});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsNotifier>().refresh(forceReload: true);
    });

    _scrollController.addListener(() {
      final notifier = context.read<ProductsNotifier>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !notifier.isLoading &&
          notifier.hasMore) {
        notifier.fetchNextPage();
      }
    });
  }

  Future<void> _addOrEditProduct(BuildContext context, [Product? product]) async {
    final result = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
    if (result != null) {
      final notifier = context.read<ProductsNotifier>();
      if (product == null) {
        notifier.addProduct(result);
      } else {
        notifier.editProduct(result);
      }
    }
  }

  void _openFilters(BuildContext context) {
    final notifier = context.read<ProductsNotifier>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return FiltersBottomSheet(
          selectedCategory: notifier.selectedCategory,
          priceRange: notifier.priceRange,
          filterInStock: notifier.filterInStock,
          filterFavorites: notifier.filterFavorites,
          filterFeatured: notifier.filterFeatured,
          categories: notifier.repo.categories,
          onApply: (cat, range, inStock, fav, featured) {
            notifier.setFilters(
              category: cat,
              price: range,
              inStock: inStock,
              onlyFav: fav,
              featured: featured,
            );
            Navigator.pop(ctx);
          },
          onClear: () {
            notifier.clearFilters();
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Consumer<CartNotifier>(
          builder: (_, cart, __) => SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Carrinho',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.items.isEmpty
                      ? const Center(child: Text('Seu carrinho está vazio.'))
                      : ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (_, i) {
                            final item = cart.items[i];
                            return ListTile(
                              leading: item.product.imageBytes != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          MemoryImage(item.product.imageBytes!),
                                    )
                                  : CircleAvatar(
                                      child: Text(item.product.name[0]
                                          .toUpperCase()),
                                    ),
                              title: Text(item.product.name),
                              subtitle: Text(
                                  'R\$ ${item.product.price.toStringAsFixed(2)} x ${item.quantity}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    cart.removeProduct(item.product),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cart.items.isEmpty
                              ? null
                              : () async {
                                  await cart.finalizePurchase();
                                  Navigator.pop(ctx); // fecha modal
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Compra finalizada e salva!')),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PurchaseHistoryPage()),
                                  );
                                },
                          child: const Text('Finalizar compra'),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ProductsNotifier>();
    final fav = context.watch<FavoritesNotifier>();
    final products = notifier.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () => _addOrEditProduct(context)),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final q = await showSearch<String>(
                  context: context,
                  delegate: _ProductSearchDelegate(notifier.products),
                );
                if (q != null) notifier.setFilters(query: q);
              }),
          IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _openFilters(context)),
          IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme),
          IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PurchaseHistoryPage()),
                  )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => notifier.refresh(forceReload: true),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: products.length + (notifier.isLoading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= products.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final p = products[i];
            return ProductTile(
              product: p,
              isFavorite: fav.isFavorite(p),
              onAddToCart: () => context.read<CartNotifier>().addProduct(p),
              onEditProduct: () => _addOrEditProduct(context, p),
              onDeleteProduct: () => notifier.deleteProduct(p),
              onToggleFavorite: () => fav.toggleFavorite(p),
              onOpenDetails: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: p))),
            );
          },
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          FloatingActionButton(
            onPressed: () => _showCart(context),
            child: const Icon(Icons.shopping_cart),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Consumer<CartNotifier>(
              builder: (_, cart, __) => cart.totalItems > 0
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cart.totalItems.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 SearchDelegate simples
class _ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;
  _ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(results[i].name),
        subtitle: Text('R\$ ${results[i].price.toStringAsFixed(2)}'),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
          title: Text(results[i].name),
          onTap: () => query = results[i].name),
    );
  }
}
