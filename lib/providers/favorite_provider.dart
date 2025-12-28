import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class FavoriteProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> get favorites => _favorites;

  // Smart Engine Logic: Calculates the most frequent category in favorites
  String get topCategory {
    if (_favorites.isEmpty) return "None";
    Map<String, int> counts = {};
    for (var fav in _favorites) {
      // Ensure we have a valid string and filter out "None" or empty tags
      String cat = fav['category']?.toString() ?? "";
      if (cat.isNotEmpty && cat != "None") {
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return "None";

    // Advanced tie-breaking: Pick the category with the most items
    var sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sortedKeys.first;
  }

  Future<void> loadFavorites() async {
    _favorites = await DatabaseHelper.instance.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(dynamic meal) async {
    final String id = (meal is Map) ? meal['id'] : meal.id;
    final isExist = _favorites.any((element) => element['id'] == id);
    if (isExist) {
      await DatabaseHelper.instance.deleteFavorite(id);
    } else {
      await DatabaseHelper.instance.insertFavorite(meal);
    }
    await loadFavorites();
  }

  bool isFavorite(String id) => _favorites.any((element) => element['id'] == id);
}