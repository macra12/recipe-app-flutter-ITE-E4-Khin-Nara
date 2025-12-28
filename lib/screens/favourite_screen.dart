import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../models/meal_model.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/meal_detail_screen.dart';
import 'package:lottie/lottie.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override

  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return; // FIX: use_build_context_synchronously
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. Fancy Sliver App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: const Text(
                'My Saved Recipes',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
              ),
              background: Container(color: Colors.white),
            ),
          ),

          // 2. Main Content Area
          favProvider.favorites.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState(context))
              : SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final mealData = favProvider.favorites[index];
                  return _buildFavouriteCard(context, mealData, favProvider);
                },
                childCount: favProvider.favorites.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Modern Recipe Card for Favorites
  Widget _buildFavouriteCard(BuildContext context, Map<String, dynamic> mealData, FavoriteProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            final fullMeal = context.read<MealProvider>().meals.firstWhere(
                  (m) => m.id == mealData['id'],
              orElse: () => Meal(
                id: mealData['id'],
                name: mealData['name'],
                imageUrl: mealData['imageUrl'],
                category: mealData['category'],
                area: 'Local Favorite',
                // Better fallback text
                instructions: "Please wait while we sync the full recipe...",
                ingredients: [],
              ),
            );
            // Pass a unique heroTag to avoid hero animation conflicts
            Navigator.push(context, MaterialPageRoute(
                builder: (_) => MealDetailScreen(meal: fullMeal, heroTag: 'fav-${fullMeal.id}')
            ));
          },
          child: Row(
            children: [
              // Image Section
              Image.network(
                mealData['imageUrl'],
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealData['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mealData['category'],
                        style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => provider.toggleFavorite(mealData),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Engaging Empty State
  // Inside _FavouriteScreenState class in favourite_screen.dart
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CREATIVITY: Animated empty cookbook for professional feel
            Lottie.asset(
              'assets/animations/empty_cook.json',
              height: 220,
            ),
            const SizedBox(height: 16),
            const Text(
              "Your cookbook is empty",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Save your favorite recipes to view them here later!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Switch to the Home tab via the provider
                context.read<NavigationProvider>().setIndex(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                elevation: 5,
              ),
              child: const Text("Go Explore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}