import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  String? _category;
  bool _isFeatured = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _category = p?.category;
    _isFeatured = p?.isFeatured ?? false;
    _imageBytes = p?.imageBytes;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _imageBytes = result.files.first.bytes);
      }
    } else {
      // Mobile
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        final bytes = await result.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    }
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      description: _descriptionController.text,
      category: _category ?? 'Sem categoria',
      isFeatured: _isFeatured,
      imageBytes: _imageBytes,
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? 'Adicionar Produto'
            : 'Editar Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[200],
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    v!.isEmpty ? 'Preencha o nome do produto' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v!.isEmpty ? 'Preencha o preço do produto' : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Estoque'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'Preencha o estoque do produto' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextFormField(
                controller: TextEditingController(text: _category),
                decoration: const InputDecoration(labelText: 'Categoria'),
                onChanged: (v) => _category = v,
              ),
              CheckboxListTile(
                title: const Text('Destaque'),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v ?? false),
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
