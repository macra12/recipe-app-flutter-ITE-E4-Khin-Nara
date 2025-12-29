import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED [cite: 109]
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/meal_card.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

// 1. Change to ConsumerStatefulWidget to access 'ref'
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String searchQuery = "";

  // Logic: Debounced search to prevent UI lag (Bonus Point Creativity) [cite: 116]
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Watch your Riverpod providers [cite: 109]
    final mealState = ref.watch(mealProvider);
    final navState = ref.watch(navigationProvider);

    // Filter Logic: Combines search query with global category/area filters [cite: 97]
    final filteredMeals = mealState.meals.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = navState.categoryFilter == "All" || m.category == navState.categoryFilter;
      final matchesArea = navState.areaFilter == "All" || m.area == navState.areaFilter;
      return matchesSearch && matchesCategory && matchesArea;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Explore", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildSearchField(),
                ],
              ),
            ),

            // Category Filter Chips (Requirement: Categories as filter chips) [cite: 96]
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildFilterChips(navState),

            const SizedBox(height: 10),
            // Results Grid (Requirement: Filtered meal list) [cite: 97]
            Expanded(
              child: filteredMeals.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: filteredMeals.length,
                itemBuilder: (context, index) => MealCard(meal: filteredMeals[index], heroSuffix: "-explore"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search recipes...",
          prefixIcon: const Icon(Icons.search, color: Colors.orange),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged("");
              })
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterChips(NavigationState navState) {
    final categories = ["All", "Beef", "Chicken", "Dessert", "Seafood", "Pork", "Vegetarian", "Vegan"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: categories.map((cat) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ChoiceChip(
            label: Text(cat),
            selected: navState.categoryFilter == cat,
            onSelected: (selected) {
              // Trigger Riverpod notifier to update global state [cite: 109]
              ref.read(navigationProvider.notifier).setCategoryAndNavigate(selected ? cat : "All");
            },
            selectedColor: Colors.orange,
            labelStyle: TextStyle(
              color: navState.categoryFilter == cat ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: navState.categoryFilter == cat ? Colors.orange : Colors.grey[300]!),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/empty_search.json',
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 10),
            const Text("No recipes found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Try a different category or search term", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}