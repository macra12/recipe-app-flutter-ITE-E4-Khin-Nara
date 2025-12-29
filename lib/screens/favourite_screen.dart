import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED
import '../providers/favorite_provider.dart';
import '../models/meal_model.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/meal_detail_screen.dart';
import 'package:lottie/lottie.dart';

// 1. Change to ConsumerStatefulWidget
class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    // Use ref.read for initial loading logic
    Future.microtask(() {
      ref.read(favoriteProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Watch the favorites list from the provider
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
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

          // 3. Conditional UI based on state
          favorites.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final mealData = favorites[index];
                  return _buildFavouriteCard(mealData);
                },
                childCount: favorites.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavouriteCard(Map<String, dynamic> mealData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // Access the meal list from your Riverpod mealProvider
            final meals = ref.read(mealProvider).meals;
            final fullMeal = meals.firstWhere(
                  (m) => m.id == mealData['id'],
              orElse: () => Meal(
                id: mealData['id'],
                name: mealData['name'],
                imageUrl: mealData['imageUrl'],
                category: mealData['category'],
                area: 'Local Favorite',
                instructions: "Please wait while we sync the full recipe...",
                ingredients: [],
              ),
            );

            Navigator.push(context, MaterialPageRoute(
                builder: (_) => MealDetailScreen(meal: fullMeal, heroTag: 'fav-${fullMeal.id}')
            ));
          },
          child: Row(
            children: [
              Image.network(
                mealData['imageUrl'],
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
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
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  // This now works because the notifier handles the dynamic 'mealData' Map
                  ref.read(favoriteProvider.notifier).toggleFavorite(mealData);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                // Navigate back to Home using NavigationProvider (Riverpod)
                ref.read(navigationProvider.notifier).setIndex(0);
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