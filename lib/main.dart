import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipefinderapp/providers/meal_provider.dart';
import 'package:recipefinderapp/providers/favorite_provider.dart'; // Add this import
import 'screens/onboarding_screen.dart'; // Add this for Requirement 1
import 'package:recipefinderapp/providers/navigation_provider.dart';
import 'package:flutter/services.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

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
      title: 'Recipe Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        // Ensure the scaffold background doesn't flash white during transitions
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          // Ensure app bars don't overlap the transparent status bar weirdly
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}