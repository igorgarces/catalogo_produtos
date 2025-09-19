import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/products_repository.dart';
import 'favorites_notifier.dart';

class ProductsNotifier extends ChangeNotifier {
  final ProductsRepository repo;
  final FavoritesNotifier favRepo;

  ProductsNotifier({required this.repo, required this.favRepo}) {
    init();
  }

  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;

  // Filtros e busca
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 6000);
  bool _filterInStock = false;
  bool _filterFavorites = false;
  bool _filterFeatured = false;
  String _searchQuery = '';

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  String? get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  bool get filterInStock => _filterInStock;
  bool get filterFavorites => _filterFavorites;
  bool get filterFeatured => _filterFeatured;
  String get searchQuery => _searchQuery;

  // Inicializa carregando produtos do repositório
  Future<void> init() async {
    await repo.init();
    _products
      ..clear()
      ..addAll(repo.allProducts());
    notifyListeners();
  }

  // Paginação
  Future<void> fetchNextPage({int limit = 10}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newItems = await repo.fetchProducts(
        start: _products.length,
        limit: limit,
      );
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newItems);
      }
    } catch (_) {
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Agora o refresh SEMPRE recarrega do arquivo
  Future<void> refresh({bool forceReload = true}) async {
    _isLoading = true;
    notifyListeners();

    await repo.loadProducts(forceReload: forceReload);
    _products
      ..clear()
      ..addAll(repo.allProducts());

    _hasMore = true;
    _isLoading = false;
    notifyListeners();
  }

  // Manipulação de produtos
  void addProduct(Product p) {
    repo.addProduct(p);
    _products.insert(0, p);
    notifyListeners();
  }

  void editProduct(Product p) {
    repo.updateProduct(p);
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i != -1) {
      _products[i] = p;
      notifyListeners();
    }
  }

  void deleteProduct(Product p) {
    repo.deleteProduct(p.id);
    _products.removeWhere((x) => x.id == p.id);
    notifyListeners();
  }

  Product? findById(String id) => repo.findById(id);

  // Filtros
  void setFilters({
    String? category,
    RangeValues? price,
    bool? inStock,
    bool? onlyFav,
    bool? featured,
    String? query,
  }) {
    _selectedCategory = category ?? _selectedCategory;
    _priceRange = price ?? _priceRange;
    _filterInStock = inStock ?? _filterInStock;
    _filterFavorites = onlyFav ?? _filterFavorites;
    _filterFeatured = featured ?? _filterFeatured;
    _searchQuery = query ?? _searchQuery;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _priceRange = const RangeValues(0, 6000);
    _filterInStock = false;
    _filterFavorites = false;
    _filterFeatured = false;
    _searchQuery = '';
    notifyListeners();
  }

  // Produtos filtrados
  List<Product> get filteredProducts {
    final q = _searchQuery.trim().toLowerCase();
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesPrice =
          p.price >= _priceRange.start && p.price <= _priceRange.end;
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final matchesStock = !_filterInStock || p.stock > 0;
      final matchesFav = !_filterFavorites || favRepo.isFavorite(p);
      final matchesFeatured = !_filterFeatured || p.isFeatured;
      return matchesCategory &&
          matchesPrice &&
          matchesSearch &&
          matchesStock &&
          matchesFav &&
          matchesFeatured;
    }).toList();
  }
}
