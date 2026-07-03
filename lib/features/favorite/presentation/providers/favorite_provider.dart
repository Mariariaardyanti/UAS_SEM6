import 'package:flutter/material.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<ProductModel> _favorites = [];

  List<ProductModel> get favorites => _favorites;

  bool isFavorite(int id) {
    return _favorites.any((item) => item.id == id);
  }

  void toggle(ProductModel product) {
    final index = _favorites.indexWhere((item) => item.id == product.id);

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(product);
    }

    notifyListeners();
  }

  void remove(int id) {
    _favorites.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}