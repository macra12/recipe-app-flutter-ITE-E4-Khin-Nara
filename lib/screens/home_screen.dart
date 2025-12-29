import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/meal_card.dart';
import '../screens/meal_detail_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<AccelerometerEvent>? _shakeSubscription;
  DateTime? _lastShake;
  Meal? _featuredMeal;

  final Map<String, String> _categoryIcons = {
    "Beef": "🥩", "Chicken": "🍗", "Dessert": "🍰",
    "Pasta": "🍝", "Seafood": "🍤", "Vegan": "🥗",
    "Pork": "🥓", "Vegetarian": "🥦"
  };

  final Map<String, String> _areaFlags = {
    "Italian": "🇮🇹", "British": "🇬🇧", "American": "🇺🇸",
    "French": "🇫🇷", "Indian": "🇮🇳", "Canadian": "🇨🇦", "Chinese": "🇨🇳"
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final mealState = ref.read(mealProvider);
      if (mealState.meals.isEmpty) {
        ref.read(mealProvider.notifier).loadMeals().then((_) => _pickRandomMeal());
      } else if (_featuredMeal == null) {
        _pickRandomMeal();
      }
    });
    _startShakeDetection();
  }

  void _pickRandomMeal() {
    final mealState = ref.read(mealProvider);
    if (mealState.meals.isNotEmpty && mounted) {
      setState(() {
        _featuredMeal = mealState.meals[Random().nextInt(mealState.meals.length)];
      });
    }
  }

  void _startShakeDetection() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _shakeSubscription = accelerometerEventStream().listen((event) {
        final now = DateTime.now();
        if (_lastShake == null || now.difference(_lastShake!) > const Duration(seconds: 1)) {
          if (event.x.abs() > 15 || event.y.abs() > 15) {
            _lastShake = now;
            _pickRandomMeal();
            HapticFeedback.mediumImpact();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealState = ref.watch(mealProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => ref.read(mealProvider.notifier).loadMeals().then((_) => _pickRandomMeal()),
        child: mealState.isLoading && mealState.meals.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : CustomScrollView(
          slivers: [
            _buildFancyHeader(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_featuredMeal != null)
                    _buildFeaturedBanner(context, _featuredMeal!),
                  if (_featuredMeal == null && mealState.meals.isNotEmpty)
                    _buildFeaturedBanner(context, mealState.meals[0]),

                  _buildSmartRecommendationSection(),
                  _buildSectionHeader("Explore Categories"),
                  _buildHorizontalList(context, ["Beef", "Chicken", "Dessert", "Pasta", "Seafood", "Vegan"], isCategory: true),
                  _buildSectionHeader("Popular Areas"),
                  _buildHorizontalList(context, ["Italian", "British", "American", "French", "Indian", "Canadian"], isCategory: false),
                  _buildSectionHeader("All Recipes"),
                ],
              ),
            ),
            _buildMainGrid(mealState.meals),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // --- ALL HELPER METHODS ARE NOW CORRECTLY INSIDE THE CLASS ---

  Widget _buildFancyHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, Chef!", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Text("Find your taste",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, dynamic meal) {
    final String heroTag = 'meal-image-${meal.id}-banner';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => MealDetailScreen(meal: meal, heroTag: heroTag)
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.orange.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10)
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: Image.network(meal.imageUrl, fit: BoxFit.cover),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "🔥 SURPRISE PICK",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      meal.name,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Tap to view full recipe ➔",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartRecommendationSection() {
    final favorites = ref.watch(favoriteProvider);
    final mealNotifier = ref.read(mealProvider.notifier);
    final favoriteIds = favorites.map((f) => f['id'].toString()).toList();
    final topCat = ref.read(favoriteProvider.notifier).topCategory;
    final recommended = mealNotifier.getRecommendedMeals(topCat, favoriteIds);

    if (recommended.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Smart Suggestions ✨"),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemCount: recommended.length,
            itemBuilder: (context, index) => SizedBox(
              width: 170,
              child: MealCard(meal: recommended[index], heroSuffix: "-rec"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<String> items, {required bool isCategory}) {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final String item = items[index];
          final String icon = isCategory ? (_categoryIcons[item] ?? "🍽️") : (_areaFlags[item] ?? "🏳️");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: ActionChip(
              onPressed: () {
                if (isCategory) {
                  ref.read(navigationProvider.notifier).setCategoryAndNavigate(item);
                } else {
                  ref.read(navigationProvider.notifier).setAreaAndNavigate(item);
                }
              },
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              label: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(item, style: TextStyle(
                      color: isCategory ? Colors.orange[800] : Colors.blue[800],
                      fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildMainGrid(List<Meal> meals) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => MealCard(meal: meals[index], heroSuffix: "-grid"),
          childCount: meals.length,
        ),
      ),
    );
  }
} // Final closing brace for the class