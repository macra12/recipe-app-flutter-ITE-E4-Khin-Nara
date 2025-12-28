import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import 'api_constants.dart';

class ApiService {
  // 1. Fetch all meals
  Future<List<Meal>> fetchMeals() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/meals'),
      headers: ApiConstants.headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  // 2. Fetch categories for the Explore screen
  Future<List<String>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/categories'),
      headers: ApiConstants.headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['strCategory'].toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}