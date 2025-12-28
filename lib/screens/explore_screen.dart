import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/meal_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = "All";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final navProvider = context.watch<NavigationProvider>(); // Listen to global filters

    final filteredMeals = mealProvider.meals.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = navProvider.categoryFilter == "All" || m.category == navProvider.categoryFilter;
      final matchesArea = navProvider.areaFilter == "All" || m.area == navProvider.areaFilter;
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: "Search recipes...",
                        prefixIcon: Icon(Icons.search, color: Colors.orange),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Refined Filter Chips (Requirement: Categories as filter chips)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: ["All", "Beef", "Chicken", "Dessert", "Seafood", "Pork", "Vegetarian", "Vegan"]
                    .map((cat) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() => selectedCategory = selected ? cat : "All");
                    },
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: selectedCategory == cat ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(color: selectedCategory == cat ? Colors.orange : Colors.grey[300]!),
                  ),
                ))
                    .toList(),
              ),
            ),

            // 3. Results Grid (Requirement: Filtered meal list displayed below)
            const SizedBox(height: 10),
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
                itemBuilder: (context, index) => MealCard(meal: filteredMeals[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fancy Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "No recipes found",
            style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Text("Try a different category or search term"),
        ],
      ),
    );
  }
}