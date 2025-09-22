import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/products_repository.dart';
import 'favorites_notifier.dart';

class ProductsNotifier extends ChangeNotifier {
  final ProductsRepository repo;
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

  ProductsNotifier({required this.repo}) {
    init();
  }

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

  Future<void> init() async {
    print('🔄 ProductsNotifier init()');
    await refresh(forceReload: true);
  }

  Future<void> refresh({bool forceReload = false}) async {
    print('🔄 ProductsNotifier refresh(forceReload: $forceReload)');
    
    _isLoading = true;
    notifyListeners();

    try {
      await repo.loadProducts(forceReload: forceReload);
      _products.clear();
      _products.addAll(repo.allProducts());
      _hasMore = true;
      print('✅ ProductsNotifier - ${_products.length} produtos carregados');
    } catch (e) {
      print('❌ Erro no ProductsNotifier.refresh: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    _filterInStock = inStock ?? _filterInStock; // 🔹 CORREÇÃO: usar inStock
    _filterFavorites = onlyFav ?? _filterFavorites;
    _filterFeatured = featured ?? _filterFeatured;
    _searchQuery = query ?? _searchQuery;
    
    print('🎯 Filtros aplicados:');
    print('   - Categoria: $_selectedCategory');
    print('   - Preço: ${_priceRange.start} - ${_priceRange.end}');
    print('   - Em estoque: $_filterInStock');
    print('   - Favoritos: $_filterFavorites');
    print('   - Destaques: $_filterFeatured');
    print('   - Busca: "$_searchQuery"');
    
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _priceRange = const RangeValues(0, 6000);
    _filterInStock = false;
    _filterFavorites = false;
    _filterFeatured = false;
    _searchQuery = '';
    print('🧹 Filtros limpos');
    notifyListeners();
  }

  List<Product> getFilteredProducts(FavoritesNotifier favRepo) {
    final q = _searchQuery.trim().toLowerCase();
    
    print('🔍 Aplicando filtros:'); 
    print('   - Categoria: $_selectedCategory');
    print('   - Preço: R\$${_priceRange.start} - R\$${_priceRange.end}');
    print('   - Busca: "$q"');
    print('   - Em estoque: $_filterInStock');
    print('   - Favoritos: $_filterFavorites');
    print('   - Destaques: $_filterFeatured');
    
    final filtered = _products.where((p) {
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
      
      final result = matchesCategory &&
          matchesPrice &&
          matchesSearch &&
          matchesStock &&
          matchesFav &&
          matchesFeatured;
          
      if (result) {
        print('   ✅ ${p.name} - PASSOU nos filtros');
      }
      
      return result;
    }).toList();
    
    print('🔍 Resultado: ${filtered.length} produtos encontrados');
    return filtered;
  }
}