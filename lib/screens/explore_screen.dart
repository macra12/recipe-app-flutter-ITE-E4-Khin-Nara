import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/meal_card.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String searchQuery = "";

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = query);
    });
  }

  void _showFilterSheet(BuildContext context, NavigationState navState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E), // Dark surface to match theme
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))
                )
            ),
            const SizedBox(height: 25),
            const Center(
                child: Text("Filter Search",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))
            ),
            const SizedBox(height: 35),
            const Text("Category", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: _buildFilterGrid(navState),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                ),
                child: const Text("Apply Filter", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
    final navState = ref.watch(navigationProvider);

    final filteredMeals = mealState.meals.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = navState.categoryFilter == "All" || m.category == navState.categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Explore",
                        style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    Text("Find your next favorite meal",
                        style: TextStyle(color: Colors.orange.shade300, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 25),
                    _buildAnimatedSearchBar(navState),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _buildHorizontalCategoryBar(navState),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: filteredMeals.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: MealCard(meal: filteredMeals[index], heroSuffix: "-explore"),
                        ),
                      ),
                    );
                  },
                  childCount: filteredMeals.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchBar(NavigationState navState) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search recipes...",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9800)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () => _showFilterSheet(context, navState),
          child: Container(
            height: 58, width: 58,
            decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: const Color(0xFFFF9800).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCategoryBar(NavigationState navState) {
    final categories = ["All", "Beef", "Chicken", "Dessert", "Seafood", "Pork", "Vegetarian", "Vegan"];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = navState.categoryFilter == categories[index];
          return GestureDetector(
            onTap: () => ref.read(navigationProvider.notifier).setCategoryAndNavigate(categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.15), blurRadius: 8)] : [],
              ),
              alignment: Alignment.center,
              child: Text(categories[index],
                  style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterGrid(NavigationState navState) {
    final cats = ["Beef", "Chicken", "Dessert", "Pasta", "Seafood", "Vegan", "Breakfast", "Lunch"];
    return Wrap(
      spacing: 12,
      runSpacing: 15,
      children: cats.map((c) {
        final isSel = navState.categoryFilter == c;
        return GestureDetector(
          onTap: () => ref.read(navigationProvider.notifier).setCategoryAndNavigate(c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFFF9800) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSel ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(c, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/empty_search.json', height: 220),
          const SizedBox(height: 10),
          const Text("No recipes found",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}