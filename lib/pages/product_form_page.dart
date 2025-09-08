import 'dart:io';
import 'package:catalogo_produtos/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormPage extends StatefulWidget {
  final Product? existingProduct;
  final Uint8List? existingWebImage;

  const ProductFormPage({super.key, this.existingProduct, this.existingWebImage});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  String? _imageUrl;
  Uint8List? _webImageBytes;
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final prod = widget.existingProduct;
    if (prod != null) {
      _name = prod.name;
      _description = prod.description;
      _price = prod.price;
      _imageUrl = prod.imageUrl;
      _webImageBytes = widget.existingWebImage;
    } else {
      _name = '';
      _description = '';
      _price = 0;
      _imageUrl = null;
      _webImageBytes = null;
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _pickedFile = picked;
          _imageUrl = null;
        });
      } else {
        setState(() {
          _pickedFile = picked;
          _imageUrl = picked.path;
          _webImageBytes = null;
        });
      }
    }
  }

  void _saveProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final product = Product(
        name: _name,
        description: _description,
        price: _price,
        imageUrl: _imageUrl ?? (_pickedFile != null ? _pickedFile!.path : ''),
      );
      Navigator.pop(context, {'product': product, 'bytes': _webImageBytes});
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, width: 100, height: 100, fit: BoxFit.cover);
    } else if (!kIsWeb && _imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.file(File(_imageUrl!), width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey.shade800,
        child: const Icon(Icons.image_not_supported, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingProduct != null ? "Editar Produto" : "Adicionar Produto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(child: _buildImagePreview()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome';
                  }
                  return null;
                },
                onSaved: (value) { _name = value ?? ''; },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a descrição';
                  }
                  return null;
                },
                onSaved: (value) { _description = value ?? ''; },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _price != 0 ? _price.toStringAsFixed(2) : '',
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Digite o preço';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Preço inválido';
                  return null;
                },
                onSaved: (value) { _price = double.parse(value!.replaceAll(',', '.')); },
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _saveProduct, child: const Text('Salvar Produto')),
            ],
          ),
        ),
      ),
    );
  }
}
