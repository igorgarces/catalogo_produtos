import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import '../notifiers/products_notifier.dart';
import '../repositories/products_repository.dart';
import '../repositories/order_repository.dart';
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
      // 🔹 Força refresh no init para carregar JSON atualizado
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
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(ctx); // fecha modal
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Compra finalizada e salva!')),
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

  void _debugProducts(BuildContext context) {
    final notifier = context.read<ProductsNotifier>();
    final repo = context.read<ProductsRepository>();
    
    print('=== DEBUG PRODUTOS ===');
    print('Produtos no Notifier: ${notifier.products.length}');
    print('Produtos no Repository: ${repo.allProducts().length}');
    print('Filtros ativos:');
    print(' - Categoria: ${notifier.selectedCategory}');
    print(' - Busca: "${notifier.searchQuery}"');
    print(' - Preço: R\$${notifier.priceRange.start} - R\$${notifier.priceRange.end}');
    print(' - Em estoque: ${notifier.filterInStock}');
    print(' - Favoritos: ${notifier.filterFavorites}');
    print(' - Destaques: ${notifier.filterFeatured}');
    
    if (notifier.products.isNotEmpty) {
      print('Lista de produtos no Notifier:');
      for (final product in notifier.products) {
        print(' - ${product.name} (ID: ${product.id}) - R\$${product.price}');
      }
    } else {
      print('⚠️ Nenhum produto no Notifier!');
    }

    if (repo.allProducts().isNotEmpty) {
      print('Lista de produtos no Repository:');
      for (final product in repo.allProducts().take(3)) {
        print(' - ${product.name} (ID: ${product.id}) - R\$${product.price}');
      }
      if (repo.allProducts().length > 3) {
        print(' - ... e mais ${repo.allProducts().length - 3} produtos');
      }
    } else {
      print('⚠️ Nenhum produto no Repository!');
    }

    // 🔹 Tenta recarregar os produtos
    print('🔄 Tentando recarregar produtos...');
    repo.loadProducts(forceReload: true).then((_) {
      print('✅ Recarregamento completo');
      print('📊 Produtos após recarregar: ${repo.allProducts().length}');
      
      // Força o notifier a atualizar
      if (mounted) {
        context.read<ProductsNotifier>().refresh(forceReload: true);
        print('🔄 Notifier atualizado');
      }
    });

    print('=====================');
  }

  void _debugOrders(BuildContext context) {
    final ordersRepo = context.read<OrdersRepository>();
    print('=== DEBUG PEDIDOS ===');
    ordersRepo.debugStorage();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ProductsNotifier>();
    final fav = context.watch<FavoritesNotifier>();
    final cart = context.watch<CartNotifier>();
    
    // 🔹 CORREÇÃO: Usar a lista de produtos diretamente do notifier
    final products = notifier.products;

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
          // 🔹 BOTÃO DEBUG PRODUTOS
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () => _debugProducts(context),
            tooltip: 'Debug Produtos',
          ),
          // 🔹 BOTÃO DEBUG PEDIDOS
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => _debugOrders(context),
            tooltip: 'Debug Pedidos',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          print('🔄 Pull-to-refresh acionado');
          await context.read<ProductsNotifier>().refresh(forceReload: true);
          print('✅ Pull-to-refresh completo');
        },
        child: notifier.isLoading && products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum produto encontrado', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Puxe para baixo para recarregar',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _debugProducts(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Debug executado - verifique o console')),
                            );
                          },
                          child: const Text('Debug Carregamento'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // 🔹 Indicador de filtros ativos
                      if (notifier.selectedCategory != null ||
                          notifier.searchQuery.isNotEmpty ||
                          notifier.filterInStock ||
                          notifier.filterFavorites ||
                          notifier.filterFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.blue[50],
                          child: Row(
                            children: [
                              const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Filtros ativos: ${products.length} produto(s)',
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => notifier.clearFilters(),
                                child: const Text(
                                  'Limpar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // 🔹 Lista de produtos
                      Expanded(
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
                              onAddToCart: () {
                                cart.addProduct(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${p.name} adicionado ao carrinho!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              onEditProduct: () => _addOrEditProduct(context, p),
                              onDeleteProduct: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Excluir produto'),
                                    content: Text('Deseja excluir "${p.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          notifier.deleteProduct(p);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('"${p.name}" excluído!')),
                                          );
                                        },
                                        child: const Text('Excluir', 
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onToggleFavorite: () => fav.toggleFavorite(p),
                              onOpenDetails: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(product: p))),
                            );
                          },
                        ),
                      ),
                    ],
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
        onTap: () {
          close(context, results[i].name);
        },
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
          subtitle: Text('R\$ ${results[i].price.toStringAsFixed(2)}'),
          onTap: () {
            query = results[i].name;
            showResults(context);
          }),
    );
  }
}