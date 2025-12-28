import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // <--- ADD THIS
import '../models/meal_model.dart';
import '../screens/meal_detail_screen.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final String? heroSuffix;

  const MealCard({super.key, required this.meal, this.heroSuffix});

  @override
  Widget build(BuildContext context) {
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
                child: CachedNetworkImage( // Now this will be recognized
                  imageUrl: meal.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  meal.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }
}