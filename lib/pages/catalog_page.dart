import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../repositories/products_repository.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/product_tile.dart';
import '../widgets/cart_widget.dart';
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
    final newItems = await repo.fetchProducts();
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
    final favRepo = context.read<FavoritesRepository>();
    final q = _searchQuery.trim().toLowerCase();
    return _products.where((p) {
      final matchesCategory = _selectedCategory == null || p.category == _selectedCategory;
      final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final matchesStock = !_filterInStock || p.stock > 0;
      final matchesFav = !_filterFavorites || favRepo.isFavorite(p);
      return matchesCategory && matchesPrice && matchesSearch && matchesStock && matchesFav;
    }).toList();
  }

  void _openFiltersSheet() {
    String? tempCategory = _selectedCategory;
    RangeValues tempRange = _priceRange;
    bool tempInStock = _filterInStock;
    bool tempFav = _filterFavorites;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          final repo = context.read<ProductsRepository>();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filtros',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        ChoiceChip(
                            label: const Text('Todas'),
                            selected: tempCategory == null,
                            onSelected: (_) =>
                                setStateSheet(() => tempCategory = null)),
                        const SizedBox(width: 8),
                        ...repo.categories.map((c) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                  label: Text(c),
                                  selected: tempCategory == c,
                                  onSelected: (_) =>
                                      setStateSheet(() => tempCategory = c)),
                            ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Faixa de preço'),
                        RangeSlider(
                          values: tempRange,
                          min: 0,
                          max: 6000,
                          divisions: 60,
                          labels: RangeLabels(
                              'R\$${tempRange.start.toStringAsFixed(0)}',
                              'R\$${tempRange.end.toStringAsFixed(0)}'),
                          onChanged: (v) => setStateSheet(() => tempRange = v),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Apenas em estoque'),
                            Switch(
                                value: tempInStock,
                                onChanged: (v) =>
                                    setStateSheet(() => tempInStock = v)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Apenas favoritos'),
                            Switch(
                                value: tempFav,
                                onChanged: (v) =>
                                    setStateSheet(() => tempFav = v)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _priceRange = const RangeValues(0, 6000);
                              _filterInStock = false;
                              _filterFavorites = false;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Limpar'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = tempCategory;
                                _priceRange = tempRange;
                                _filterInStock = tempInStock;
                                _filterFavorites = tempFav;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Aplicar filtros'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Consumer<CartRepository>(builder: (context, cart, _) {
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
                      ]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.items.isEmpty
                      ? const Center(child: Text('Seu carrinho está vazio.'))
                      : ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (_, i) {
                            final it = cart.items[i];
                            return ListTile(
                              leading: CircleAvatar(
                                  child: Text(
                                      it.product.name[0].toUpperCase())),
                              title: Text(it.product.name),
                              subtitle: Text(
                                  'R\$ ${it.product.price.toStringAsFixed(2)} x ${it.quantity}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    cart.removeProduct(it.product),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 6,
                          offset: const Offset(0, -2))
                    ],
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
                          ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cart.items.isEmpty
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Compra finalizada com sucesso!')));
                                  cart.clearCart();
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartRepository>();
    final favRepo = context.watch<FavoritesRepository>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Catálogo'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: _addProduct,
              tooltip: 'Adicionar produto'),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final q = await showSearch<String>(
                    context: context,
                    delegate: _ProductSearchDelegate(_products));
                if (q != null) setState(() => _searchQuery = q);
              }),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFiltersSheet),
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: widget.onToggleTheme),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar produto...',
                fillColor: Colors.white24,
                filled: true,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
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
          itemBuilder: (context, index) {
            if (index >= _filteredProducts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final p = _filteredProducts[index];
            final isFav = favRepo.isFavorite(p);

            return ProductTile(
              product: p,
              isFavorite: isFav,
              onAddToCart: () => cart.addProduct(p),
              onEditProduct: () => _editProduct(p),
              onDeleteProduct: () => _deleteProduct(p),
              onToggleFavorite: () => favRepo.toggleFavorite(p),
              onOpenDetails: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: p))),
            );
          },
        ),
      ),
      floatingActionButton:
          CartWidget(onPressed: () => _showCartBottomSheet(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          subtitle: Text('R\$ ${results[i].price.toStringAsFixed(2)}')),
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
