import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/products_repository.dart';

class FiltersBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final RangeValues priceRange;
  final bool filterInStock;
  final bool filterFavorites;
  final void Function(String? category, RangeValues range, bool inStock, bool favorites) onApply;
  final VoidCallback onClear;

  const FiltersBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.priceRange,
    required this.filterInStock,
    required this.filterFavorites,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late String? _tempCategory;
  late RangeValues _tempRange;
  late bool _tempInStock;
  late bool _tempFav;

  @override
  void initState() {
    super.initState();
    _tempCategory = widget.selectedCategory;
    _tempRange = widget.priceRange;
    _tempInStock = widget.filterInStock;
    _tempFav = widget.filterFavorites;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProductsRepository>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  ChoiceChip(
                      label: const Text('Todas'),
                      selected: _tempCategory == null,
                      onSelected: (_) => setState(() => _tempCategory = null)),
                  const SizedBox(width: 8),
                  ...repo.categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _tempCategory == c,
                        onSelected: (_) => setState(() => _tempCategory = c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Faixa de preço'),
                  RangeSlider(
                    values: _tempRange,
                    min: 0,
                    max: 6000,
                    divisions: 60,
                    labels: RangeLabels(
                      'R\$${_tempRange.start.toStringAsFixed(0)}',
                      'R\$${_tempRange.end.toStringAsFixed(0)}',
                    ),
                    onChanged: (v) => setState(() => _tempRange = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Apenas em estoque'),
                      Switch(value: _tempInStock, onChanged: (v) => setState(() => _tempInStock = v)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Apenas favoritos'),
                      Switch(value: _tempFav, onChanged: (v) => setState(() => _tempFav = v)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_tempCategory, _tempRange, _tempInStock, _tempFav);
                        Navigator.pop(context);
                      },
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
