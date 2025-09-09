import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/products_repository.dart';
import '../repositories/cart_repository.dart';
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
  final ScrollController _scrollController = ScrollController();
  final ProductsRepository _repository = ProductsRepository();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;

  // Filtros
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 6000);
  String _searchQuery = '';
  bool _filterInStock = false;
  bool _filterFavorites = false;
  bool _filterFeatured = false;

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
    setState(() => _isLoading = true);
    final newItems = await _repository.fetchProducts();
    setState(() {
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newItems);
      }
      _isLoading = false;
    });
  }

  void _addOrUpdateProduct(Product product) {
    final i = _products.indexWhere((p) => p.id == product.id);
    setState(() {
      if (i == -1) {
        _products.insert(0, product);
      } else {
        _products[i] = product;
      }
    });
  }

  String _normalize(String s) {
    // busca sem acento/maiúsculas
    const from = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñ';
    const to   = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNn';
    String out = s.toLowerCase();
    for (int i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  List<Product> get _filteredProducts {
    final q = _normalize(_searchQuery);
    return _products.where((p) {
      final matchesCategory = _selectedCategory == null || p.category == _selectedCategory;
      final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
      final target = '${p.name} ${p.description}';
      final matchesSearch = _normalize(target).contains(q);
      final matchesStock = !_filterInStock || p.stock > 0;
      final matchesFav = !_filterFavorites || p.isFavorite;
      final matchesFeatured = !_filterFeatured || p.isFeatured;
      return matchesCategory && matchesPrice && matchesSearch && matchesStock && matchesFav && matchesFeatured;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartRepository>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Catálogo"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              final result = await Navigator.push<Product?>(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormPage()),
              );
              if (result != null) _addOrUpdateProduct(result);
            },
            tooltip: 'Novo produto',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_4_outlined),
            onPressed: widget.onToggleTheme,
            tooltip: 'Alternar tema',
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Busca
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Buscar produto...",
                    fillColor: Colors.white24,
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),
                // Filtro de categorias
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: _selectedCategory == null,
                        onSelected: (_) => setState(() => _selectedCategory = null),
                      ),
                      ..._repository.categories.map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: _selectedCategory == c,
                            onSelected: (_) => setState(() => _selectedCategory = c),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Favoritos'),
                        selected: _filterFavorites,
                        onSelected: (v) => setState(() => _filterFavorites = v),
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: const Text('Promoções'),
                        selected: _filterFeatured,
                        onSelected: (v) => setState(() => _filterFeatured = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Filtro faixa de preço
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 6000,
                  divisions: 60,
                  labels: RangeLabels(
                    'R\$${_priceRange.start.toStringAsFixed(0)}',
                    'R\$${_priceRange.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) => setState(() => _priceRange = values),
                ),
                // Filtro estoque
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Apenas em estoque", style: TextStyle(color: Colors.white)),
                    Switch(
                      value: _filterInStock,
                      onChanged: (val) => setState(() => _filterInStock = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _filteredProducts.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredProducts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }
          final product = _filteredProducts[index];
          return ProductTile(
            product: product,
            onAddToCart: () => cart.addProduct(product),
            onEditProduct: () async {
              final result = await Navigator.push<Product?>(
                context,
                MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
              );
              if (result != null) _addOrUpdateProduct(result);
            },
            onDeleteProduct: () => setState(() => _products.removeWhere((p) => p.id == product.id)),
            onToggleFavorite: () => setState(() {
              final i = _products.indexWhere((p) => p.id == product.id);
              if (i != -1) _products[i] = _products[i].copyWith(isFavorite: !_products[i].isFavorite);
            }),
            onOpenDetails: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
          );
        },
      ),
      floatingActionButton: CartWidget(
        totalItems: cart.totalItems,
        onPressed: () => _showCartDialog(context, cart),
      ),
    );
  }

  void _showCartDialog(BuildContext context, CartRepository cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Carrinho"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cart.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Seu carrinho está vazio."),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.items.length,
                    itemBuilder: (_, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('Quantidade: ${item.quantity} | R\$ ${item.product.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cart.removeProduct(item.product),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              if (cart.items.isNotEmpty)
                Column(
                  children: [
                    Divider(color: Colors.grey.shade700),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("R\$ ${cart.totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Compra finalizada com sucesso!")),
                        );
                        cart.clearCart();
                        Navigator.pop(context);
                      },
                      child: const Text("Finalizar Compra"),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fechar")),
        ],
      ),
    );
  }
}
