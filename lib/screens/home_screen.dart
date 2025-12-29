import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
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
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF262626),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Placeholder
            Container(
              margin: const EdgeInsets.all(20),
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
            ),

            // Section Title Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(width: 150, height: 20, color: Colors.white),
            ),

            // Grid Placeholder
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.7,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final mealState = ref.watch(mealProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: RefreshIndicator(
        onRefresh: () => ref.read(mealProvider.notifier).loadMeals().then((_) => _pickRandomMeal()),
        child: mealState.isLoading && mealState.meals.isEmpty
            ? _buildLoadingShimmer()
            : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildFancyHeader(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_featuredMeal != null)
                    _buildFeaturedBanner(context, _featuredMeal!),

                  _buildSmartRecommendationSection(),

                  _buildSectionHeader("Explore Categories", "Discover by type"),
                  _buildHorizontalList(context, ["Beef", "Chicken", "Dessert", "Pasta", "Seafood", "Vegan"], isCategory: true),

                  _buildSectionHeader("Popular Areas", "Cuisines of the world"),
                  _buildHorizontalList(context, ["Italian", "British", "American", "French", "Indian", "Canadian"], isCategory: false),

                  _buildSectionHeader("All Recipes", "Everything we've got"),
                ],
              ),
            ),
            _buildMainGrid(mealState.meals),

            _buildInterestingFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        centerTitle: false,
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust opacity based on scroll height
            final isCollapsed = constraints.maxHeight <= kToolbarHeight + 40;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isCollapsed)
                      Text("Hello, Chef!",
                          style: TextStyle(color: Colors.orange.shade300, fontSize: 10, letterSpacing: 1.2)),
                    const Text("Find your taste",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF1E1E1E),
                    child: Icon(Icons.person_outline, color: Colors.orange, size: 20),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, dynamic meal) {
    final String heroTag = 'meal-image-${meal.id}-banner';
    return Container(
      margin: const EdgeInsets.all(20),
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => MealDetailScreen(meal: meal, heroTag: heroTag)
          )),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(tag: heroTag, child: Image.network(meal.imageUrl, fit: BoxFit.cover)),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 25,
                right: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("🔥 SURPRISE PICK",
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 12),
                    Text(meal.name,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 5),
                        const Text("Check full recipe", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                      ],
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
        _buildSectionHeader("Smart Suggestions ✨", "Based on your favorites"),
        SizedBox(
          height: 240,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommended.length,
            itemBuilder: (context, index) => Container(
              width: 180,
              margin: const EdgeInsets.only(right: 15),
              child: MealCard(meal: recommended[index], heroSuffix: "-rec"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<String> items, {required bool isCategory}) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
              backgroundColor: const Color(0xFF1E1E1E),
              side: BorderSide.none,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              label: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(item, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 35, 25, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5
              )
          ),
          const SizedBox(height: 4),
          Text(
              subtitle,
              style: TextStyle(
                  color: Colors.orange.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              )
          ),
        ],
      ),
    );
  }
  Widget _buildMainGrid(List<Meal> meals) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => MealCard(meal: meals[index], heroSuffix: "-grid"),
          childCount: meals.length,
        ),
      ),
    );
  }

  Widget _buildInterestingFooter() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.orange.withValues(alpha: 0.05)],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.orange, size: 30),
            const SizedBox(height: 15),
            const Text("That's all for today!",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 5),
            const Text("Keep cooking and stay healthy!",
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _footerSocialIcon(Icons.camera_alt_outlined),
                _footerSocialIcon(Icons.facebook_outlined),
                _footerSocialIcon(Icons.language_outlined),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _footerSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white54, size: 18),
    );
  }
}