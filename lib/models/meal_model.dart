class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final String? tags;    // Added for extra info
  final String? youtube; // Added for video link
  final String? source;  // Added for original recipe link
  final List<String> ingredients;

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
    // Handling the specific list structure from your JSON
    var ingredientsFromJson = json['ingredients'] as List? ?? [];
    List<String> ingredientsList = ingredientsFromJson.map((item) {
      return "${item['ingredient']}: ${item['measure']}";
    }).toList();

    return Meal(
      // Matching your provided JSON keys exactly
      id: json['id']?.toString() ?? '',
      name: json['meal']?.toString() ?? 'Unknown Meal',
      category: json['category']?.toString() ?? 'General',
      area: json['area']?.toString() ?? 'Unknown Area',
      instructions: json['instructions']?.toString() ?? '',
      imageUrl: json['mealThumb']?.toString() ?? '',
      tags: json['tags'],
      youtube: json['youtube'],
      source: json['source'],
      ingredients: ingredientsList,
    );
  }
}