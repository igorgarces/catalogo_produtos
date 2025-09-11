import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import '../repositories/products_repository.dart';
import '../widgets/product_tile.dart';
import '../widgets/filters_bottom_sheet.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const CatalogPage({super.key, required this.onToggleTheme});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;

  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 6000);
  bool _filterInStock = false;
  bool _filterFavorites = false;
  bool _filterFeatured = false;
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final repo = context.read<ProductsRepository>();
    final newItems = await repo.fetchProducts(start: _products.length, limit: 10);
    setState(() {
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newItems);
      }
      _isLoading = false;
    });
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormPage()),
    );
    if (result != null) setState(() => _products.insert(0, result));
  }

  Future<void> _editProduct(Product p) async {
    final result = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: p)),
    );
    if (result != null) {
      setState(() {
        final i = _products.indexWhere((x) => x.id == p.id);
        if (i != -1) _products[i] = result;
      });
    }
  }

  void _deleteProduct(Product p) {
    setState(() => _products.removeWhere((x) => x.id == p.id));
  }

  List<Product> get _filteredProducts {
    final fav = context.read<FavoritesNotifier>();
    final q = _searchQuery.trim().toLowerCase();

    return _products.where((p) {
      final matchCat =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchPrice = p.price >= _priceRange.start &&
          p.price <= _priceRange.end;
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final matchStock = !_filterInStock || p.stock > 0;
      final matchFav = !_filterFavorites || fav.isFavorite(p);
      final matchFeatured = !_filterFeatured || p.isFeatured;

      return matchCat && matchPrice && matchSearch && matchStock && matchFav && matchFeatured;
    }).toList();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final repo = context.read<ProductsRepository>();
        return FiltersBottomSheet(
          selectedCategory: _selectedCategory,
          priceRange: _priceRange,
          filterInStock: _filterInStock,
          filterFavorites: _filterFavorites,
          filterFeatured: _filterFeatured,
          categories: repo.categories,
          onApply: (cat, range, inStock, fav, featured) {
            setState(() {
              _selectedCategory = cat;
              _priceRange = range;
              _filterInStock = inStock;
              _filterFavorites = fav;
              _filterFeatured = featured;
            });
            Navigator.pop(ctx);
          },
          onClear: () {
            setState(() {
              _selectedCategory = null;
              _priceRange = const RangeValues(0, 6000);
              _filterInStock = false;
              _filterFavorites = false;
              _filterFeatured = false;
            });
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
          builder: (_, cart, __) {
            return SizedBox(
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
                            onPressed: () => Navigator.pop(ctx)),
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
                                        child: Text(item.product.name[0].toUpperCase())),
                                title: Text(item.product.name),
                                subtitle: Text(
                                    'R\$ ${item.product.price.toStringAsFixed(2)} x ${item.quantity}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () => cart.removeProduct(item.product),
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
                                : () {
                                    cart.clearCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Compra finalizada!')));
                                    Navigator.pop(ctx);
                                  },
                            child: const Text('Finalizar compra'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();
    final fav = context.watch<FavoritesNotifier>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Catálogo'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: _addProduct),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final q = await showSearch<String>(
                    context: context,
                    delegate: _ProductSearchDelegate(_products));
                if (q != null) setState(() => _searchQuery = q);
              }),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFilters),
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: widget.onToggleTheme),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _products.clear();
            _hasMore = true;
          });
          await _loadMore();
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _filteredProducts.length + (_isLoading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= _filteredProducts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final p = _filteredProducts[i];
            return ProductTile(
              product: p,
              isFavorite: fav.isFavorite(p),
              onAddToCart: () => cart.addProduct(p),
              onEditProduct: () => _editProduct(p),
              onDeleteProduct: () => _deleteProduct(p),
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
          if (cart.totalItems > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cart.totalItems.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// SearchDelegate simples
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
      itemBuilder: (_, i) =>
          ListTile(title: Text(results[i].name), onTap: () => query = results[i].name),
    );
  }
}
