import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // For video and source links
import '../models/meal_model.dart';
import '../providers/favorite_provider.dart';
import 'package:share_plus/share_plus.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;
  final String heroTag; // NEW: Receive the unique tag
  const MealDetailScreen({super.key, required this.meal, required this.heroTag});

  // Helper to open YouTube or Source links
  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) throw Exception('Could not launch $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Fancy Hero Image with Gradient
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.network(meal.imageUrl, fit: BoxFit.cover),
                  ),

                  // Gradient overlay to make text readable
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => Share.share(
                    "Check out this delicious ${meal.name} recipe I found on Recipe Finder! \n\nView here: ${meal.source ?? 'Open App'}"
                ),
              ),
              Consumer<FavoriteProvider>(
                builder: (context, favProvider, child) {
                  final isFav = favProvider.isFavorite(meal.id);
                  return Container(
                    margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                      color: isFav ? Colors.red : Colors.grey,
                      onPressed: () => favProvider.toggleFavorite(meal),
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title and Tags
                  Text(meal.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBadge(meal.area, Colors.blue),
                      const SizedBox(width: 8),
                      _buildBadge(meal.category, Colors.orange),
                    ],
                  ),

                  if (meal.tags != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: meal.tags!.split(',').map((tag) =>
                          Text("#$tag", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic))
                      ).toList(),
                    ),
                  ],

                  const Divider(height: 40),

                  // 3. Fancy Action Buttons (Video & Source)
                  Row(
                    children: [
                      if (meal.youtube != null && meal.youtube!.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(meal.youtube),
                            icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                            label: const Text("Watch Video"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red[900]),
                          ),
                        ),
                      if (meal.source != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(meal.source),
                            icon: const Icon(Icons.language, color: Colors.blue),
                            label: const Text("Source"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], foregroundColor: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 4. Ingredients Section
                  const Text(
                      "Ingredients (Check as you cook)",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),

                  // ...meal.ingredients.map((ing) => Container(
                  //   margin: const EdgeInsets.only(bottom: 8),
                  //   padding: const EdgeInsets.all(12),
                  //   decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  //   child: Row(
                  //     children: [
                  //       const Icon(Icons.shopping_basket_outlined, size: 20, color: Colors.orange),
                  //       const SizedBox(width: 12),
                  //       Expanded(child: Text(ing, style: const TextStyle(fontSize: 16))),
                  //     ],
                  //   ),
                  // )),
                  IngredientChecklist(ingredients: meal.ingredients),
                  const SizedBox(height: 30),

                  // 5. Instructions Section
                  const Text("Instructions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(meal.instructions, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), // FIX: deprecated_member_use
          borderRadius: BorderRadius.circular(20)
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
class IngredientChecklist extends StatefulWidget {
  final List<String> ingredients;
  const IngredientChecklist({super.key, required this.ingredients});

  @override
  State<IngredientChecklist> createState() => _IngredientChecklistState();
}

class _IngredientChecklistState extends State<IngredientChecklist> {
  late List<bool> _checked;
  @override
  void initState() {
    super.initState();
    _checked = List.filled(widget.ingredients.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.ingredients.length, (index) => CheckboxListTile(
        value: _checked[index],
        onChanged: (val) => setState(() => _checked[index] = val!),
        title: Text(widget.ingredients[index],
            style: TextStyle(
              decoration: _checked[index] ? TextDecoration.lineThrough : null,
              color: _checked[index] ? Colors.grey : Colors.black,
            )),
        activeColor: Colors.orange,
        controlAffinity: ListTileControlAffinity.leading,
      )),
    );
  }
}