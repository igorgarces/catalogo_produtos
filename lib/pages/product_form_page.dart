import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductFormPage({super.key, this.product, required this.onSave});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _imageFile; // Mobile
  Uint8List? _webImage; // Web

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _categoryController.text = widget.product!.category;

      _imageFile = widget.product!.imagePath != null ? File(widget.product!.imagePath!) : null;
      _webImage = widget.product!.imageBytes;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() => _webImage = bytes);
    } else {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        description: _descriptionController.text,
        category: _categoryController.text,
        imagePath: kIsWeb ? null : _imageFile?.path,
        imageBytes: kIsWeb ? _webImage : null,
      );

      widget.onSave(product);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe o preço' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    if (_imageFile != null)
                      Image.file(_imageFile!, height: 100)
                    else if (_webImage != null)
                      Image.memory(_webImage!, height: 100)
                    else
                      const Icon(Icons.image, size: 100, color: Colors.grey),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Selecionar Imagem'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
