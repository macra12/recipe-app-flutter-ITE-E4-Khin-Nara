import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_model.dart';
import '../providers/favorite_provider.dart';
import 'package:share_plus/share_plus.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal meal;
  final String heroTag;
  const MealDetailScreen({super.key, required this.meal, required this.heroTag});

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  bool showIngredients = true;

  List<String> get instructionSteps {
    return widget.meal.instructions
        .split(RegExp(r'\r\n|\n|\. '))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetItem(Icons.share, "Share Recipe", () {
              Share.share("Check out this ${widget.meal.name} recipe!");
              Navigator.pop(context);
            }),
            _buildSheetItem(Icons.link, "Copy Recipe Link", () {
              Clipboard.setData(ClipboardData(text: widget.meal.source ?? "app.recipe.co/${widget.meal.id}"));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied!")));
              Navigator.pop(context);
            }),
            _buildSheetItem(
                ref.watch(favoriteProvider.notifier).isFavorite(widget.meal.id) ? Icons.bookmark : Icons.bookmark_border,
                "Save to Favorites",
                    () {
                  ref.read(favoriteProvider.notifier).toggleFavorite(widget.meal);
                  Navigator.pop(context);
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF9800)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.arrow_back, color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.more_horiz, color: Colors.white)),
                onPressed: () => _showActionSheet(context),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.heroTag,
                child: Image.network(widget.meal.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                // Ensure all elements align to the left
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.meal.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniBadge(widget.meal.area, Colors.blue),
                      const SizedBox(width: 8),
                      _buildMiniBadge(widget.meal.category, const Color(0xFFFF9800)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      if (widget.meal.youtube != null && widget.meal.youtube!.isNotEmpty)
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.play_circle_fill,
                            label: "Watch Video",
                            color: const Color(0xFFFF0000),
                            onTap: () => _launchUrl(widget.meal.youtube),
                          ),
                        ),
                      if (widget.meal.youtube != null && widget.meal.youtube!.isNotEmpty) const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.language,
                          label: "View Source",
                          color: const Color(0xFF129575),
                          onTap: () => _launchUrl(widget.meal.source),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  Container(
                    height: 55,
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        _buildToggleButton("Ingredients", showIngredients),
                        _buildToggleButton("Instructions", !showIngredients),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  showIngredients ? _buildIngredientsList() : _buildStepFlow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String title, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => showIngredients = (title == "Ingredients")),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFF9800) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.white60)),
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.meal.ingredients.map((ing) {
        final parts = ing.split(': ');
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFFFF9800)),
              const SizedBox(width: 15),
              Expanded(child: Text(parts[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))),
              Text(parts.length > 1 ? parts[1] : "", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepFlow() {
    final steps = instructionSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Step ${index + 1}", style: const TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 10),
              Text(steps[index], style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.white70)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMiniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}