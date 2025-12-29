class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final String? tags;
  final String? youtube;
  final String? source;
  final List<String> ingredients;
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal': name,
      'category': category,
      'area': area,
      'instructions': instructions,
      'mealThumb': imageUrl,
      'tags': tags,
      'youtube': youtube,
      'source': source,
      'ingredients': ingredients.map((ing) {
        final parts = ing.split(': ');
        return {
          'ingredient': parts.isNotEmpty ? parts[0] : '',
          'measure': parts.length > 1 ? parts[1] : '',
        };
      }).toList(),
    };
  }

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    this.tags,
    this.youtube,
    this.source,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id']?.toString() ?? '',
      name: json['meal']?.toString() ?? 'Unknown Meal',
      category: json['category']?.toString() ?? 'General',
      area: json['area']?.toString() ?? 'Unknown Area',
      instructions: json['instructions']?.toString() ?? '',
      imageUrl: json['mealThumb']?.toString() ?? '',
      youtube: json['youtube'],
      source: json['source'],
      tags: json['tags'],
      ingredients: (json['ingredients'] as List? ?? []).map((item) {
        return "${item['ingredient']}: ${item['measure']}";
      }).toList(),
    );
  }
}