import 'package:catalogo_produtos/pages/product_form_page.dart';
import 'package:catalogo_produtos/repositories/products_repository.dart';
import 'package:catalogo_produtos/widgets/product_tile.dart';
import 'package:catalogo_produtos/widgets/cart_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:catalogo_produtos/main.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();
  final ProductsRepository _repository = ProductsRepository();
  final List<Product> _products = [];
  final Map<Product, Uint8List?> _webImages = {};
  final List<CartItem> _cart = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() { _isLoading = true; });
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

  void _addOrEditProduct(Product product, {Uint8List? bytes, Product? existing}) {
    setState(() {
      if (existing != null) {
        final index = _products.indexOf(existing);
        _products[index] = product;
        _webImages[product] = bytes;
        _webImages.remove(existing);
      } else {
        _products.insert(0, product);
        if (bytes != null) _webImages[product] = bytes;
      }
    });
  }

  void _addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product == product);
    setState(() {
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(Product product) {
    final index = _cart.indexWhere((item) => item.product == product);
    setState(() {
      if (index >= 0) {
        if (_cart[index].quantity > 1) {
          _cart[index].quantity--;
        } else {
          _cart.removeAt(index);
        }
      }
    });
  }

  double get _cartTotal => _cart.fold(0, (prev, item) => prev + item.product.price * item.quantity);

  void _openCart() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._cart.map((item) => ListTile(
                title: Text(item.product.name, style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
                subtitle: Text(
                  'Qtd: ${item.quantity} - R\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    setModalState(() { _removeFromCart(item.product); });
                  },
                ),
              )),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total: R\$ ${_cartTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Catálogo"),
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.dark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () { themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark; },
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormPage()));
              if (result != null && result is Map<String, dynamic>) {
                _addOrEditProduct(result['product'], bytes: result['bytes']);
              }
            },
          ),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: _openCart),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _products.length + 1,
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          final product = _products[index];
          return ProductTile(
            product: product,
            webImageBytes: _webImages[product],
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormPage(existingProduct: product, existingWebImage: _webImages[product]),
                ),
              );
              if (result != null && result is Map<String, dynamic>) {
                _addOrEditProduct(result['product'], bytes: result['bytes'], existing: product);
              }
            },
            onAddToCart: () { _addToCart(product); },
          );
        },
      ),
      floatingActionButton: CartWidget(onTap: _openCart),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
