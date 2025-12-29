import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

// 1. Define the Global Provider
final mealProvider = StateNotifierProvider<MealNotifier, MealState>((ref) {
  return MealNotifier();
});

// 2. Define a State class to hold the data
class MealState {
  final List<Meal> meals;
  final bool isLoading;

  MealState({required this.meals, required this.isLoading});
}

// 3. The Notifier (Replaces ChangeNotifier)
class MealNotifier extends StateNotifier<MealState> {
  final ApiService _apiService = ApiService();

  MealNotifier() : super(MealState(meals: [], isLoading: false));

  // Recommendation logic (Requirement 2 & Bonus Points)
  List<Meal> getRecommendedMeals(String favoriteCategory, List<String> favoriteIds) {
    if (favoriteCategory == "None") return [];
    List<Meal> recommendations = state.meals.where((m) {
      return m.category == favoriteCategory && !favoriteIds.contains(m.id);
    }).toList();
    recommendations.shuffle();
    return recommendations.take(10).toList();
  }

  // Load Meals with Offline Caching (Requirement 4)
  Future<void> loadMeals() async {
    state = MealState(meals: state.meals, isLoading: true);
    final prefs = await SharedPreferences.getInstance();

    try {
      final fetchedMeals = await _apiService.fetchMeals();
      final String encodedData = jsonEncode(fetchedMeals.map((m) => m.toJson()).toList());
      await prefs.setString('cached_meals', encodedData);

      state = MealState(meals: fetchedMeals, isLoading: false);
    } catch (e) {
      final String? cachedData = prefs.getString('cached_meals');
      if (cachedData != null) {
        final List<dynamic> decodedData = jsonDecode(cachedData);
        final cachedList = decodedData.map((m) => Meal.fromJson(m)).toList();
        state = MealState(meals: cachedList, isLoading: false);
      } else {
        state = MealState(meals: [], isLoading: false);
      }
    }
  }
}