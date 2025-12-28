import 'package:flutter/material.dart';
import 'dart:convert'; // REQUIRED for jsonEncode/jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // REQUIRED for caching
import '../models/meal_model.dart';
import '../services/api_service.dart';


class MealProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Meal> _meals = [];
  bool _isLoading = false;

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;

  // REFINED ML LOGIC: Discovery-based Recommendation
  List<Meal> getRecommendedMeals(String favoriteCategory, List<String> favoriteIds) {
    if (favoriteCategory == "None") return [];
    List<Meal> recommendations = _meals.where((m) {
      return m.category == favoriteCategory && !favoriteIds.contains(m.id);
    }).toList();
    recommendations.shuffle();
    return recommendations.take(10).toList();
  }

  // UPDATED: Step 4 - Offline Caching for Realism
  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. Try to fetch fresh data from API
      _meals = await _apiService.fetchMeals();

      // 2. Cache the data locally as a string
      final String encodedData = jsonEncode(_meals.map((m) => m.toJson()).toList());
      await prefs.setString('cached_meals', encodedData);

      debugPrint("Meals updated from API and cached.");
    } catch (e) {
      debugPrint("API Fetch failed: $e. Loading from cache...");

      // 3. If API fails (no internet), load from local cache
      final String? cachedData = prefs.getString('cached_meals');
      if (cachedData != null) {
        final List<dynamic> decodedData = jsonDecode(cachedData);
        _meals = decodedData.map((m) => Meal.fromJson(m)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}