import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'models/product.dart';
import 'repositories/products_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo de Produtos',
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: CatalogApp(onThemeChanged: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class CatalogApp extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final ThemeMode themeMode;

  const CatalogApp({
    super.key,
    required this.onThemeChanged,
    required this.themeMode,
  });

  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  final ProductsRepository _repository = ProductsRepository();
  String? _selectedCategory;
  String _searchQuery = "";
  final List<Product> _cart = []; // Carrinho de compras

  final ImagePicker _picker = ImagePicker();

  void _openProductForm({Product? product, int? index}) {
    final nameController = TextEditingController(text: product?.name);
    final priceController =
        TextEditingController(text: product?.price.toString());
    final descriptionController =
        TextEditingController(text: product?.description);

    String? category = product?.category ?? 'Roupas';
    String? imagePath = product?.imagePath;

    Future<void> pickImage() async {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          imagePath = picked.path;
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imagePath != null
                      ? (kIsWeb
                          ? NetworkImage(imagePath!)
                          : FileImage(File(imagePath!))) as ImageProvider
                      : const AssetImage("assets/placeholder.png"),
                  child: imagePath == null
                      ? const Icon(Icons.image, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Roupas', 'Eletrônicos', 'Livros']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => category = value,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text(product == null ? 'Adicionar' : 'Salvar'),
                    onPressed: () {
                      final newProduct = Product(
                        name: nameController.text,
                        price: double.tryParse(priceController.text) ?? 0,
                        description: descriptionController.text,
                        category: category ?? 'Roupas',
                        imagePath: imagePath,
                      );

                      setState(() {
                        if (index != null) {
                          _repository.updated(index, newProduct);
                        } else {
                          _repository.add(newProduct);
                        }
                      });

                      Navigator.pop(ctx);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto adicionado ao carrinho')),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Carrinho de Compras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._cart.map(
              (p) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: p.imagePath != null
                      ? (kIsWeb
                          ? NetworkImage(p.imagePath!)
                          : FileImage(File(p.imagePath!))) as ImageProvider
                      : const AssetImage("assets/placeholder.png"),
                ),
                title: Text(p.name),
                subtitle: Text('R\$ ${p.price.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = _repository.getAll();

    final filtered = allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('Categoria'),
            items: ['Roupas', 'Eletrônicos', 'Livros']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() {
              _selectedCategory = null;
              _searchQuery = "";
            }),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _openCart,
          ),
          Switch(
            value: widget.themeMode == ThemeMode.dark,
            onChanged: widget.onThemeChanged,
            activeColor: Colors.yellow,
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final product = filtered[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: product.imagePath != null
                          ? (kIsWeb
                              ? NetworkImage(product.imagePath!)
                              : FileImage(File(product.imagePath!)))
                          as ImageProvider
                          : const AssetImage("assets/placeholder.png"),
                      child: product.imagePath == null
                          ? const Icon(Icons.image, size: 20)
                          : null,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                        '${product.category} • R\$ ${product.price.toStringAsFixed(2)}'),
                    onTap: () =>
                        _openProductForm(product: product, index: index),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart,
                              color: Colors.green),
                          onPressed: () => _addToCart(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() {
                            _repository
                                .delete(_repository.getAll().indexOf(product));
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
