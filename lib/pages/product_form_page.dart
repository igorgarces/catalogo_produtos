import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;

  Uint8List? _imageBytes;
  String? _imagePath;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _imageBytes = p?.imageBytes;
    _imagePath = p?.imagePath;
    _isFeatured = p?.isFeatured ?? false;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() => _imageBytes = result.files.single.bytes);
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _imagePath = result.files.single.path;
          _imageBytes = null; // para evitar conflito
        });
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      description: _descController.text,
      stock: int.tryParse(_stockController.text) ?? 0,
      category: _categoryController.text,
      imageBytes: _imageBytes,
      imagePath: _imagePath,
      isFeatured: _isFeatured,
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreview;
    if (_imageBytes != null) {
      imagePreview = Image.memory(_imageBytes!, width: 100, height: 100, fit: BoxFit.cover);
    } else if (_imagePath != null && _imagePath!.isNotEmpty) {
      imagePreview = kIsWeb
          ? const Icon(Icons.image, size: 100)
          : Image.file(File(_imagePath!), width: 100, height: 100, fit: BoxFit.cover);
    } else {
      imagePreview = const Icon(Icons.image, size: 100);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Adicionar Produto' : 'Editar Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: GestureDetector(onTap: _pickImage, child: imagePreview)),
              const SizedBox(height: 12),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome'), validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Descrição')),
              TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Estoque'), keyboardType: TextInputType.number),
              TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Categoria')),
              SwitchListTile(title: const Text('Destaque'), value: _isFeatured, onChanged: (v) => setState(() => _isFeatured = v)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
