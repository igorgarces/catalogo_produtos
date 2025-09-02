import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'models/product.dart';
import 'repositories/products_repository.dart';

void main() {
  runApp(const CatalogApp());
}

class CatalogApp extends StatefulWidget {
  const CatalogApp({super.key});

  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  final ProductsRepository _repository = ProductsRepository();
  String? _selectedCategory;
  String _searchQuery = "";

  final ImagePicker _picker = ImagePicker();

  void _openProductForm({Product? product, int? index}) {
    final nameController = TextEditingController(text: product?.name);
    final priceController =
        TextEditingController(text: product?.price.toString());
    final descriptionController =
        TextEditingController(text: product?.description);
    String category = product?.category ?? 'Roupas';
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
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
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
                      ? FileImage(File(imagePath!))
                      : const AssetImage("assets/placeholder.png")
                          as ImageProvider,
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
                onChanged: (value) => category = value!,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(product == null ? 'Adicionar' : 'Salvar'),
                onPressed: () {
                  final newProduct = Product(
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    description: descriptionController.text,
                    category: category,
                    imagePath: imagePath,
                  );

                  setState(() {
                    if (index != null) {
                      _repository.updated(index, newProduct);
                    } else {
                      _repository.add(newProduct);
                    }
                  });

                  Navigator.pop(context);
                },
              )
            ],
          ),
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
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
            )
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
                            ? FileImage(File(product.imagePath!))
                            : const AssetImage("assets/placeholder.png")
                                as ImageProvider,
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                          '${product.category} • R\$ ${product.price.toStringAsFixed(2)}'),
                      onTap: () =>
                          _openProductForm(product: product, index: index),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() {
                          _repository.delete(
                              _repository.getAll().indexOf(product));
                        }),
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
      ),
    );
  }
}
