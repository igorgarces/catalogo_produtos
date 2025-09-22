import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesNotifier extends ChangeNotifier { // ✅ Agora herda de ChangeNotifier
  final List<String> _favoriteIds = [];

  List<String> get favoriteIds => List.unmodifiable(_favoriteIds);

  bool isFavorite(Product product) => _favoriteIds.contains(product.id);

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favoriteIds.remove(product.id);
    } else {
      _favoriteIds.add(product.id);
    }
    notifyListeners(); // ✅ Agora pode chamar notifyListeners
  }
}