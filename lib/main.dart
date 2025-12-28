import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipefinderapp/providers/meal_provider.dart';
import 'package:recipefinderapp/providers/favorite_provider.dart'; // Add this import
import 'screens/onboarding_screen.dart'; // Add this for Requirement 1
import 'package:recipefinderapp/providers/navigation_provider.dart';

void main() {
  // Required for sqflite initialization
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // Manages API data (Requirement 2 & 3)
        ChangeNotifierProvider(create: (_) => MealProvider()),
        // Manages Local Database / Favorites (Requirement 5)
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()), // Add this
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Finder App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // Requirement 1: Show Onboarding before the app starts
      home: const OnboardingScreen(),
    );
  }
}