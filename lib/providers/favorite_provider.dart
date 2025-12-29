import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED
import '../models/meal_model.dart';
import '../services/database_helper.dart';

// 1. Define the Global Provider
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<Map<String, dynamic>>>((ref) {
  return FavoriteNotifier();
});

// 2. The Notifier (Replaces ChangeNotifier)
class FavoriteNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoriteNotifier() : super([]) {
    // Automatically load favorites when the provider is initialized
    loadFavorites();
  }

  // REFINED: Smart Engine Logic for Recommendations
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

  // Asynchronous operation using Future
  Future<void> loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavorites();
    state = favorites; // Directly update the state to trigger UI refresh
  }

  Future<void> toggleFavorite(Meal meal) async { // Use Meal model for type safety
    final isExist = state.any((element) => element['id'] == meal.id);

    if (isExist) {
      await DatabaseHelper.instance.deleteFavorite(meal.id);
    } else {
      // Requirements: Save favorites locally
      await DatabaseHelper.instance.insertFavorite(meal);
    }
    // Requirement: Refresh state to update UI reactively [cite: 103]
    await loadFavorites();
  }

  bool isFavorite(String id) => state.any((element) => element['id'] == id);
}