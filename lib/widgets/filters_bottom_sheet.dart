import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final maxPrice = 6000.0;

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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: widget.categories?.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
