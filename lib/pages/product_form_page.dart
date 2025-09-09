import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../repositories/products_repository.dart';
import 'package:file_picker/file_picker.dart';

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
  late TextEditingController _imageUrlController;
  late TextEditingController _descController;
  late String _category;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _category = widget.product?.category ?? 'Eletrônicos';
    _imageBytes = widget.product?.imageBytes;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _imageBytes = result.files.single.bytes);
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.product != null;
      final product = (widget.product ?? Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        description: '',
        price: 0,
        category: _category,
        stock: 0,
      )).copyWith(
        name: _nameController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        category: _category,
        imageBytes: _imageBytes,
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      );

      Navigator.pop(context, product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _imageBytes != null
        ? Image.memory(_imageBytes!, height: 150)
        : (_imageUrlController.text.isNotEmpty
            ? Image.network(_imageUrlController.text, height: 150, errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder());

    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "Novo Produto" : "Editar Produto")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              preview,
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(onPressed: _pickImage, child: const Text("Selecionar imagem")),
                  OutlinedButton(
                    onPressed: () { setState(() { _imageBytes = null; }); },
                    child: const Text("Remover imagem local"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "URL da imagem (opcional)"),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Preço"),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: "Estoque"),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: const ['Eletrônicos', 'Roupas', 'Alimentos']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: "Categoria"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _saveProduct, child: Text(widget.product == null ? "Salvar" : "Atualizar")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: Text("Sem imagem")),
      );
}
