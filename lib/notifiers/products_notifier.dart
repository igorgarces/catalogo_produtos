import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/products_repository.dart';
import '../notifiers/favorites_notifier.dart';

class ProductsNotifier extends ChangeNotifier {
  final ProductsRepository repo;
  final FavoritesNotifier favRepo;

  ProductsNotifier({required this.repo, required this.favRepo});

  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;

  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 6000);
  bool _filterInStock = false;
  bool _filterFavorites = false;
  String _searchQuery = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  String? get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  bool get filterInStock => _filterInStock;
  bool get filterFavorites => _filterFavorites;
  String get searchQuery => _searchQuery;

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    final newItems = await repo.fetchProducts();
    if (newItems.isEmpty) {
      _hasMore = false;
    } else {
      _products.addAll(newItems);
    }
    _isLoading = false;
    notifyListeners();
  }

  void refresh() {
    _products.clear();
    _hasMore = true;
    fetchNextPage();
  }

  void addProduct(Product p) {
    _products.insert(0, p);
    notifyListeners();
  }

  void editProduct(Product p) {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i != -1) {
      _products[i] = p;
      notifyListeners();
    }
  }

  void deleteProduct(Product p) {
    _products.removeWhere((x) => x.id == p.id);
    notifyListeners();
  }

  void setFilters({
    String? category,
    RangeValues? price,
    bool? inStock,
    bool? onlyFav,
    String? query,
  }) {
    _selectedCategory = category ?? _selectedCategory;
    _priceRange = price ?? _priceRange;
    _filterInStock = inStock ?? _filterInStock;
    _filterFavorites = onlyFav ?? _filterFavorites;
    _searchQuery = query ?? _searchQuery;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _priceRange = const RangeValues(0, 6000);
    _filterInStock = false;
    _filterFavorites = false;
    _searchQuery = '';
    notifyListeners();
  }

  List<Product> get filteredProducts {
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
}
