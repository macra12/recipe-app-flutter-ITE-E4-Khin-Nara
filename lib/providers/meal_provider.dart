import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

class MealProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Meal> _meals = [];
  bool _isLoading = false;

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;

  // REFINED ML LOGIC: Discovery-based Recommendation
  // Inside MealProvider class
  List<Meal> getRecommendedMeals(String favoriteCategory, List<String> favoriteIds) {
    if (favoriteCategory == "None") return [];

    // Realism: Filter out recipes the user has already saved
    List<Meal> recommendations = _meals.where((m) {
      return m.category == favoriteCategory && !favoriteIds.contains(m.id);
    }).toList();

    recommendations.shuffle(); // Keep it fresh every time they open the app
    return recommendations.take(10).toList();
  }
  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _meals = await _apiService.fetchMeals();
    } catch (e) {
      debugPrint("Error fetching meals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}