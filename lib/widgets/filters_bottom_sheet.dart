import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/products_notifier.dart';
import '../notifiers/favorites_notifier.dart';

class FiltersBottomSheet extends StatefulWidget {
  final List<String>? categories;
  final String? selectedCategory;
  final RangeValues priceRange;
  final bool filterInStock;
  final bool filterFavorites;
  final bool filterFeatured;
  final void Function(String?, RangeValues, bool, bool, bool) onApply;
  final VoidCallback onClear;

  const FiltersBottomSheet({
    super.key,
    this.categories,
    this.selectedCategory,
    required this.priceRange,
    required this.filterInStock,
    required this.filterFavorites,
    this.filterFeatured = false,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  String? _selectedCategory;
  late RangeValues _priceRange;
  bool _filterInStock = false;
  bool _filterFavorites = false;
  bool _filterFeatured = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _priceRange = widget.priceRange;
    _filterInStock = widget.filterInStock;
    _filterFavorites = widget.filterFavorites;
    _filterFeatured = widget.filterFeatured;
  }

  int _calculatePreviewCount(BuildContext context) {
    final notifier = Provider.of<ProductsNotifier>(context, listen: false);
    final favRepo = Provider.of<FavoritesNotifier>(context, listen: false);
    
    // Simulação dos filtros atuais
    final tempProducts = notifier.products.where((p) {
      final matchesCategory = _selectedCategory == null || p.category == _selectedCategory;
      final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
      final matchesStock = !_filterInStock || p.stock > 0;
      final matchesFav = !_filterFavorites || favRepo.isFavorite(p);
      final matchesFeatured = !_filterFeatured || p.isFeatured;
      
      return matchesCategory && matchesPrice && matchesStock && matchesFav && matchesFeatured;
    }).toList();
    
    return tempProducts.length;
  }

  @override
  Widget build(BuildContext context) {
    const maxPrice = 6000.0;
    final previewCount = _calculatePreviewCount(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            
            // Categoria
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas categorias')),
                ...?widget.categories?.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ],
              onChanged: (v) => setState(() => _selectedCategory = v),
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 12),
            
            // Preço
            Text('Preço: R\$ ${_priceRange.start.toInt()} - R\$ ${_priceRange.end.toInt()}'),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: maxPrice,
              divisions: 100,
              labels: RangeLabels(_priceRange.start.toInt().toString(), _priceRange.end.toInt().toString()),
              onChanged: (v) => setState(() => _priceRange = v),
            ),
            const SizedBox(height: 12),
            
            // Checkboxes
            CheckboxListTile(
              title: const Text('Apenas produtos em estoque'),
              value: _filterInStock,
              onChanged: (v) => setState(() => _filterInStock = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Apenas favoritos'),
              value: _filterFavorites,
              onChanged: (v) => setState(() => _filterFavorites = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Apenas produtos em destaque'),
              value: _filterFeatured,
              onChanged: (v) => setState(() => _filterFeatured = v ?? false),
            ),
            
            // Preview
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$previewCount produtos correspondem aos filtros',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClear,
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(
                      _selectedCategory,
                      _priceRange,
                      _filterInStock,
                      _filterFavorites,
                      _filterFeatured,
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}