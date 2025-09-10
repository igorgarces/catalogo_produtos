import 'package:catalogo_produtos/widgets/product_search_delegate.dart';
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
import '../widgets/filters_bottom_sheet.dart';
import '../widgets/cart_bottom_sheet.dart';

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
  late final FavoritesRepository _favRepo;

  @override
  void initState() {
    super.initState();
    _favRepo = context.read<FavoritesRepository>();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final repo = context.read<ProductsRepository>();
    final newItems = await repo.fetchProducts();

    if (!mounted) return;
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
    if (result != null && mounted) {
      setState(() => _products.insert(0, result));
    }
  }

  Future<void> _editProduct(Product p) async {
    final result = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: p)),
    );
    if (result != null && mounted) {
      setState(() {
        final i = _products.indexWhere((x) => x.id == p.id);
        if (i != -1) _products[i] = result;
      });
    }
  }

  void _deleteProduct(Product p) {
    setState(() => _products.removeWhere((x) => x.id == p.id));
  }

  // ===== FILTROS =====
  bool _matchesCategory(Product p) =>
      _selectedCategory == null || p.category == _selectedCategory;
  bool _matchesPrice(Product p) =>
      p.price >= _priceRange.start && p.price <= _priceRange.end;
  bool _matchesSearch(Product p) {
    final q = _searchQuery.trim().toLowerCase();
    return q.isEmpty ||
        p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q);
  }

  bool _matchesStock(Product p) => !_filterInStock || p.stock > 0;
  bool _matchesFavorites(Product p) => !_filterFavorites || _favRepo.isFavorite(p);

  List<Product> get _filteredProducts => _products
      .where((p) =>
          _matchesCategory(p) &&
          _matchesPrice(p) &&
          _matchesSearch(p) &&
          _matchesStock(p) &&
          _matchesFavorites(p))
      .toList();

  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => FiltersBottomSheet(
        selectedCategory: _selectedCategory,
        priceRange: _priceRange,
        filterInStock: _filterInStock,
        filterFavorites: _filterFavorites,
        onApply: (cat, range, inStock, fav) {
          setState(() {
            _selectedCategory = cat;
            _priceRange = range;
            _filterInStock = inStock;
            _filterFavorites = fav;
          });
        },
        onClear: () {
          setState(() {
            _selectedCategory = null;
            _priceRange = const RangeValues(0, 6000);
            _filterInStock = false;
            _filterFavorites = false;
          });
        },
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
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
            final isFav = _favRepo.isFavorite(p);

            return ProductTile(
              product: p,
              isFavorite: isFav,
              onAddToCart: () => context.read<CartRepository>().addProduct(p),
              onEditProduct: () => _editProduct(p),
              onDeleteProduct: () => _deleteProduct(p),
              onToggleFavorite: () => _favRepo.toggleFavorite(p),
              onOpenDetails: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
            );
          },
        ),
      ),
      floatingActionButton: CartWidget(onPressed: _showCartBottomSheet),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Catálogo'),
      backgroundColor: Colors.black,
      actions: [
        IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: _addProduct),
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final q = await showSearch<String>(
                  context: context,
                  delegate: ProductSearchDelegate(_products),
              ); 
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
    );
  }
}

// ===== SearchDelegate =====
// ignore: unused_element
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
    final results =
        products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) =>
          ListTile(title: Text(results[i].name), subtitle: Text('R\$ ${results[i].price.toStringAsFixed(2)}')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results =
        products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(title: Text(results[i].name), onTap: () => query = results[i].name),
    );
  }
}
