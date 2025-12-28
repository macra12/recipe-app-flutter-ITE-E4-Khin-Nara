import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../screens/meal_detail_screen.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final String? heroSuffix; // To make tags unique per section

  const MealCard({super.key, required this.meal, this.heroSuffix});

  @override
  Widget build(BuildContext context) {
    // Unique tag (e.g., 'meal-image-52883-recommended')
    final String heroTag = 'meal-image-${meal.id}${heroSuffix ?? ""}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailScreen(meal: meal, heroTag: heroTag),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: heroTag,
                child: Image.network(meal.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}