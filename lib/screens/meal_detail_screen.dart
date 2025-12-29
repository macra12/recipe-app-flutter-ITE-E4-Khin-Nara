import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  final Set<int> _checkedIngredients = {};

  List<String> get instructionSteps {
    return widget.meal.instructions
        .split(RegExp(r'\r\n|\n|\. '))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  // Helper to add personality with emojis for ingredients
  String _getIngredientEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('chicken')) return '🍗';
    if (lower.contains('beef') || lower.contains('steak')) return '🥩';
    if (lower.contains('pork') || lower.contains('bacon')) return '🥓';
    if (lower.contains('egg')) return '🥚';
    if (lower.contains('milk') || lower.contains('cream')) return '🥛';
    if (lower.contains('cheese')) return '🧀';
    if (lower.contains('sugar') || lower.contains('salt')) return '🧂';
    if (lower.contains('flour')) return '🌾';
    if (lower.contains('oil') || lower.contains('butter')) return '🧈';
    if (lower.contains('water')) return '💧';
    if (lower.contains('onion') || lower.contains('garlic')) return '🧄';
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('pasta') || lower.contains('spaghetti')) return '🍝';
    if (lower.contains('rice')) return '🍚';
    if (lower.contains('bread')) return '🍞';
    return '🌿'; // Default culinary emoji
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeaderImage(),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE & TAGS
                      _buildMainTitleSection(),
                      const SizedBox(height: 35),

                      _buildActionButtons(),
                      const SizedBox(height: 45),

                      _buildSectionToggle(),
                      const SizedBox(height: 40),

                      AnimationLimiter(
                        key: ValueKey(showIngredients),
                        child: showIngredients ? _buildIngredientsList() : _buildStepFlow(),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildTopNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return SliverAppBar(
      expandedHeight: 460,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0F0F0F),
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.heroTag,
              child: Image.network(widget.meal.imageUrl, fit: BoxFit.cover),
            ),
            // Cinematic Gradient Overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.8, 1.0],
                  colors: [
                    Colors.black26,
                    Colors.transparent,
                    Color(0xFF0F0F0F)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.meal.name,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _buildBadge(widget.meal.area.toUpperCase(), const Color(0xFFFF9800)),
            const SizedBox(width: 10),
            _buildBadge(widget.meal.category.toUpperCase(), Colors.white24),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color == Colors.white24 ? Colors.white60 : color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildRealisticButton(
            icon: Icons.play_arrow_rounded,
            label: "Video Guide",
            color: const Color(0xFF421C1C),
            textColor: Colors.redAccent,
            onTap: () => _launchUrl(widget.meal.youtube),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _buildRealisticButton(
            icon: Icons.chrome_reader_mode_outlined,
            label: "Full Story",
            color: const Color(0xFF1B3A32),
            textColor: const Color(0xFF00C897),
            onTap: () => _launchUrl(widget.meal.source),
          ),
        ),
      ],
    );
  }

  Widget _buildRealisticButton({required IconData icon, required String label, required Color color, required Color textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionToggle() {
    return Container(
      height: 65,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          _buildToggleItem("Ingredients", showIngredients),
          _buildToggleItem("Instructions", !showIngredients),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => showIngredients = (title == "Ingredients")),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFF9800) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.2), blurRadius: 10)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w900, color: active ? Colors.black : Colors.white38)
          ),
        ),
      ),
    );
  }

  // BEAUTIFUL INGREDIENTS LIST WITH EMOJIS
  Widget _buildIngredientsList() {
    return Column(
      children: widget.meal.ingredients.asMap().entries.map((entry) {
        final index = entry.key;
        final parts = entry.value.split(': ');
        final isChecked = _checkedIngredients.contains(index);
        final name = parts[0];
        final measure = parts.length > 1 ? parts[1] : "";

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 400),
          child: SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => isChecked ? _checkedIngredients.remove(index) : _checkedIngredients.add(index));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.transparent : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: isChecked ? Colors.white12 : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Text(_getIngredientEmoji(name), style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(name,
                            style: TextStyle(
                              color: isChecked ? Colors.white24 : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                            )),
                      ),
                      Text(measure,
                          style: TextStyle(color: isChecked ? Colors.white12 : Colors.orange.shade200, fontWeight: FontWeight.w900, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // TIMELINE STEP FLOW: Easy to read and aligned
  Widget _buildStepFlow() {
    final steps = instructionSteps;
    return Column(
      children: List.generate(steps.length, (index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 500),
          child: SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Logic
                    Column(
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                        ),
                        if (index != steps.length - 1)
                          Expanded(child: Container(width: 2, color: Colors.white12, margin: const EdgeInsets.symmetric(vertical: 8))),
                      ],
                    ),
                    const SizedBox(width: 22),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Text(
                          steps[index],
                          style: const TextStyle(fontSize: 17, height: 1.7, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopNavigationBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBlurIcon(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
            _buildBlurIcon(Icons.more_horiz_rounded, () => _showActionSheet(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black26,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    final isFav = ref.watch(favoriteProvider.notifier).isFavorite(widget.meal.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(35),
          decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(45))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: Colors.redAccent, size: 28),
                title: Text(isFav ? "Remove from Cookbook" : "Add to Cookbook", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                onTap: () {
                  ref.read(favoriteProvider.notifier).toggleFavorite(widget.meal);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: Colors.orange, size: 28),
                title: const Text("Share with Friends", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                onTap: () {
                  Share.share("You have to try this ${widget.meal.name} recipe!");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}