import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';
import 'file_storage.dart';

class ProductsRepository {
  final List<String> categories = ['Roupas', 'Livros', 'Eletrônicos'];
  final List<Product> _products = [];
  final String _fileName = 'products.json';

  ProductsRepository();

  Future<void> init() async {
    print('🔄 Inicializando ProductsRepository...');
    await FileStorage.ensureLocalFile(_fileName, _fileName);
    await loadProducts(forceReload: true);
  }

  Future<void> loadProducts({bool forceReload = false}) async {
    print('📦 Carregando produtos... forceReload: $forceReload');
    
    try {
      if (forceReload) {
        print('🔄 Forçando recarregamento...');
        final data = await FileStorage.readJson(_fileName);
        _products.clear();

        if (data != null && data is List && data.isNotEmpty) {
          print('✅ JSON local encontrado com ${data.length} produtos');
          _products.addAll(
            data.map((x) => Product.fromJson(Map<String, dynamic>.from(x))),
          );
          print('✅ ${_products.length} produtos carregados na memória');
        } else {
          print('❌ JSON local vazio, carregando do assets...');
          await _loadFromAssets();
        }
        return;
      }

      if (_products.isNotEmpty) {
        print('ℹ️  Produtos já carregados: ${_products.length}');
        return;
      }

      final data = await FileStorage.readJson(_fileName);
      _products.clear();

      if (data != null && data is List && data.isNotEmpty) {
        print('✅ Carregando do arquivo local...');
        _products.addAll(
          data.map((x) => Product.fromJson(Map<String, dynamic>.from(x))),
        );
      } else {
        print('❌ Arquivo local vazio, carregando do assets...');
        await _loadFromAssets();
      }
    } catch (e) {
      print('❌ Erro em loadProducts: $e');
      await _loadFromAssets();
    }
  }

  Future<void> _loadFromAssets() async {
    try {
      print('📁 Tentando carregar do assets/products.json...');
      final data = await rootBundle.loadString('assets/products.json');
      final jsonList = jsonDecode(data) as List;
      
      _products.clear();
      _products.addAll(
        jsonList.map((x) => Product.fromJson(Map<String, dynamic>.from(x))),
      );
      
      print('✅ ${_products.length} produtos carregados do assets');
      
      // Salva no storage local para próxima vez
      await saveProducts();
      print('💾 Produtos salvos no storage local');
      
    } catch (e) {
      print('❌ Erro ao carregar do assets: $e');
      // Fallback hardcoded
      _products.clear();
      _products.addAll(_getDefaultProducts());
      print('🔄 Usando produtos padrão: ${_products.length}');
      await saveProducts();
    }
  }

  List<Product> _getDefaultProducts() {
    return [
      Product(
        id: '1',
        name: 'Camisa branca',
        description: 'Camisa branca de algodão',
        price: 49.9,
        category: 'Roupas',
        stock: 10,
        isFeatured: true,
      ),
      Product(
        id: '2',
        name: 'As Crônicas de Galliot',
        description: 'Meu livro autoral de fantasia',
        price: 79.9,
        category: 'Livros',
        stock: 5,
      ),
      Product(
        id: '3',
        name: 'Fone de Ouvido',
        description: 'Fone Bluetooth sem fio',
        price: 199.9,
        category: 'Eletrônicos',
        stock: 3,
        isFeatured: true,
      ),
    ];
  }

  Future<void> saveProducts() async {
    try {
      final data = _products.map((p) => p.toJson()).toList();
      await FileStorage.saveJson(_fileName, data);
      print('💾 ${_products.length} produtos salvos em $_fileName');
    } catch (e) {
      print('❌ Erro ao salvar produtos: $e');
    }
  }

  Future<List<Product>> fetchProducts({int start = 0, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (start >= _products.length) return [];
    final end = (start + limit).clamp(0, _products.length);
    return _products.sublist(start, end);
  }

  void addProduct(Product p) {
    _products.insert(0, p);
    saveProducts();
  }

  void updateProduct(Product p) {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i != -1) {
      _products[i] = p;
      saveProducts();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    saveProducts();
  }

  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> allProducts() {
    print('📋 Solicitando lista de produtos: ${_products.length} itens');
    return List.unmodifiable(_products);
  }
}