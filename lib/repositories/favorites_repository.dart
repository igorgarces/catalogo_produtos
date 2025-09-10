import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesRepository extends ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  bool isFavorite(Product product) => _favorites.contains(product);

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.remove(product);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }
}
