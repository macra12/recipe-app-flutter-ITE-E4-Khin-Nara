import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED:
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_model.dart';
import '../providers/favorite_provider.dart';
import 'package:share_plus/share_plus.dart';

// 1. Change to ConsumerWidget to access 'ref'
class MealDetailScreen extends ConsumerWidget {
  final Meal meal;
  final String heroTag;
  const MealDetailScreen({super.key, required this.meal, required this.heroTag});

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) throw Exception('Could not launch $url');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the favorite status using Riverpod ref.watch
    final isFav = ref.watch(favoriteProvider.notifier).isFavorite(meal.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Fancy Hero Image with Gradient
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.orange,
            // 3. Immersive Back Button & Actions
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.network(meal.imageUrl, fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.0, 0.3],
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              _buildAppBarAction(
                icon: Icons.share,
                onPressed: () => Share.share(
                    "Check out this delicious ${meal.name} recipe! \n\nView here: ${meal.source ?? 'Recipe App'}"
                ),
              ),
              _buildAppBarAction(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                iconColor: isFav ? Colors.red : Colors.black,
                // 4. Update state via ref.read notifier
                onPressed: () => ref.read(favoriteProvider.notifier).toggleFavorite(meal),
              ),
              const SizedBox(width: 10),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildBadge(meal.area, Colors.blue),
                      const SizedBox(width: 8),
                      _buildBadge(meal.category, Colors.orange),
                    ],
                  ),

                  if (meal.tags != null && meal.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: meal.tags!.split(',').map((tag) =>
                          Text("#${tag.trim()}", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic))
                      ).toList(),
                    ),
                  ],

                  const Divider(height: 40, thickness: 1),

                  // Fancy Action Buttons
                  Row(
                    children: [
                      if (meal.youtube != null && meal.youtube!.isNotEmpty)
                        Expanded(
                          child: _buildActionButton(
                            label: "Video Guide",
                            icon: Icons.play_circle_fill,
                            color: Colors.red,
                            onTap: () => _launchUrl(meal.youtube),
                          ),
                        ),
                      if (meal.source != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: "Source",
                            icon: Icons.language,
                            color: Colors.blue,
                            onTap: () => _launchUrl(meal.source),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 35),

                  // Ingredients with Checklist (Extra Mile Feature)
                  const Text("Ingredients", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("Check items off as you prepare", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 15),
                  IngredientChecklist(ingredients: meal.ingredients),

                  const SizedBox(height: 35),

                  // Instructions Section
                  const Text("Cooking Instructions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text(meal.instructions, style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87)),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction({required IconData icon, required VoidCallback onPressed, Color iconColor = Colors.black}) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: iconColor), onPressed: onPressed),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
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
              color: _checked[index] ? Colors.grey : Colors.black87,
              fontSize: 15,
            )),
        activeColor: Colors.orange,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      )),
    );
  }
}