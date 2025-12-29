import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/favorite_provider.dart';
import '../models/meal_model.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/meal_detail_screen.dart';
import 'package:lottie/lottie.dart';

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(favoriteProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildPremiumHeader(),

          favorites.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            sliver: AnimationLimiter(
              child: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final mealData = favorites[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildDismissibleCard(mealData),
                        ),
                      ),
                    );
                  },
                  childCount: favorites.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Saved Recipes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Your personal cookbook collection',
              style: TextStyle(
                color: Colors.orange.shade300,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(Map<String, dynamic> mealData) {
    return Dismissible(
      key: Key(mealData['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(favoriteProvider.notifier).toggleFavorite(mealData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${mealData['name']} removed from favorites")),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 30),
      ),
      child: _buildFavouriteCard(mealData),
    );
  }

  Widget _buildFavouriteCard(Map<String, dynamic> mealData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final meals = ref.read(mealProvider).meals;
              final fullMeal = meals.firstWhere(
                    (m) => m.id == mealData['id'],
                orElse: () => Meal(
                  id: mealData['id'],
                  name: mealData['name'],
                  imageUrl: mealData['imageUrl'],
                  category: mealData['category'],
                  area: 'Local Favorite',
                  instructions: "Syncing recipe details...",
                  ingredients: [],
                ),
              );

              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MealDetailScreen(meal: fullMeal, heroTag: 'fav-${fullMeal.id}')
              ));
            },
            child: Row(
              children: [
                Hero(
                  tag: 'fav-${mealData['id']}',
                  child: Image.network(
                    mealData['imageUrl'],
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealData['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mealData['category'],
                            style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 28),
                  onPressed: () => ref.read(favoriteProvider.notifier).toggleFavorite(mealData),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/empty_cook.json', height: 240),
            const SizedBox(height: 20),
            const Text(
              "Your cookbook is empty",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              "Start exploring and save your favorite recipes to see them here!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => ref.read(navigationProvider.notifier).setIndex(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 18),
                elevation: 8,
                shadowColor: const Color(0xFFFF9800).withValues(alpha: 0.4),
              ),
              child: const Text("Go Explore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}