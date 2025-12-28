import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/meal_card.dart';
import '../screens/meal_detail_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mapping for Category Emojis
  final Map<String, String> _categoryIcons = {
    "Beef": "🥩", "Chicken": "🍗", "Dessert": "🍰",
    "Pasta": "🍝", "Seafood": "🍤", "Vegan": "🥗",
    "Pork": "🥓", "Vegetarian": "🥦"
  };

  // Mapping for Area Flags
  final Map<String, String> _areaFlags = {
    "Italian": "🇮🇹", "British": "🇬🇧", "American": "🇺🇸",
    "French": "🇫🇷", "Indian": "🇮🇳", "Canadian": "🇨🇦", "Chinese": "🇨🇳"
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<MealProvider>().loadMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Realistic soft background
      // EXTRA MILE: Added RefreshIndicator so users can pull down to refresh recipes
      body: RefreshIndicator(
        onRefresh: () => context.read<MealProvider>().loadMeals(),
        color: Colors.orange,
        child: mealProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : CustomScrollView(
          slivers: [
            _buildFancyHeader(), // Professional pinning header
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SURPRISE PICK AT THE VERY TOP (High visual impact)
                  if (mealProvider.meals.isNotEmpty)
                    _buildFeaturedBanner(context, mealProvider.meals[Random().nextInt(mealProvider.meals.length)]),

                  // 2. SMART RECOMMENDATIONS UNDER BANNER (Personalized discovery)
                  _buildSmartRecommendationSection(mealProvider),

                  _buildSectionHeader("Explore Categories"),
                  _buildHorizontalList(
                      context,
                      ["Beef", "Chicken", "Dessert", "Pasta", "Seafood", "Vegan"],
                      isCategory: true
                  ),

                  _buildSectionHeader("Popular Areas"),
                  _buildHorizontalList(
                      context,
                      ["Italian", "British", "American", "French", "Indian", "Canadian"],
                      isCategory: false
                  ),

                  _buildSectionHeader("All Recipes"),
                ],
              ),
            ),
            // 3. MAIN GRID (Organized and even layout)
            _buildMainGrid(mealProvider),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

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
    final String heroTag = 'meal-image-${meal.id}-banner'; // Unique for banner
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => MealDetailScreen(meal: meal, heroTag: heroTag)
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 300, // Optimized height for a balanced look
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // image: DecorationImage(image: NetworkImage(meal.imageUrl), fit: BoxFit.cover),
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
              // 1. THE HERO IMAGE (The "Realistic" Motion part)
              Hero(
                tag: heroTag,
                child: Image.network(meal.imageUrl, fit: BoxFit.cover),
              ),

              // 2. THE FANCY GRADIENT (Makes text readable)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                  ),
                ),
              ),

              // 3. THE TEXT CONTENT
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

  Widget _buildSmartRecommendationSection(MealProvider mealProvider) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final favoriteIds = favProvider.favorites.map((f) => f['id'].toString()).toList();
        final recommended = mealProvider.getRecommendedMeals(favProvider.topCategory, favoriteIds);

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
                  child: MealCard(meal: recommended[index], heroSuffix: "-rec"), // UNIQUE suffix
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // UPDATED: Horizontal list with Emojis and Flags
  Widget _buildHorizontalList(BuildContext context, List<String> items, {required bool isCategory}) {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final String item = items[index];
          final String icon = isCategory
              ? (_categoryIcons[item] ?? "🍽️")
              : (_areaFlags[item] ?? "🏳️");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: ActionChip(
              onPressed: () {
                if (isCategory) {
                  context.read<NavigationProvider>().setCategoryAndNavigate(item);
                } else {
                  context.read<NavigationProvider>().setAreaAndNavigate(item);
                }
              },
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              label: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(item,
                      style: TextStyle(
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

  Widget _buildMainGrid(MealProvider mealProvider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82, // Balanced ratio for grid items
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => MealCard(meal: mealProvider.meals[index], heroSuffix: "-grid"), // Unique suffix
          childCount: mealProvider.meals.length,
        ),
      ),
    );
  }
}