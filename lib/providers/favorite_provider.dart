import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../services/database_helper.dart';


final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<Map<String, dynamic>>>((ref) {
  return FavoriteNotifier();
});


class FavoriteNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoriteNotifier() : super([]) {

    loadFavorites();
  }


  String get topCategory {
    if (state.isEmpty) return "None";
    Map<String, int> counts = {};
    for (var fav in state) {
      String cat = fav['category']?.toString() ?? "";
      if (cat.isNotEmpty && cat != "None") {
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return "None";
    var sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sortedKeys.first;
  }


  Future<void> loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavorites();
    state = favorites;
  }

  Future<void> toggleFavorite(dynamic mealData) async {

    final String id = (mealData is Meal) ? mealData.id : mealData['id'];

    final isExist = state.any((element) => element['id'] == id);

    if (isExist) {
      await DatabaseHelper.instance.deleteFavorite(id);
    } else {
      if (mealData is Meal) {
        await DatabaseHelper.instance.insertFavorite(mealData);
      }
    }
    await loadFavorites();
  }

  bool isFavorite(String id) => state.any((element) => element['id'] == id);
}