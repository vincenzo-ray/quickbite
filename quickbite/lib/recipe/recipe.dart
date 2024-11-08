// recipe.dart

// The Recipe model represents a single recipe item, with essential details like
// ID, title, image URL, used ingredient count, and missed ingredient count.
class Recipe {
  final int id; // Unique identifier for the recipe
  final String title; // Title of the recipe
  final String imageUrl; // URL of the recipe's image
  final int usedIngredientCount; // Count of ingredients used from user input
  final int missedIngredientCount; // Count of ingredients not matched

  // Constructor for the Recipe model
  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
  });

  // Factory constructor to create a Recipe instance from JSON data
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? 0,  // Fallback to 0 if 'id' is missing
      title: json['title'] ?? 'Untitled Recipe',  // Default title if 'title' is missing
      imageUrl: json['image'] ?? '',  // Empty string if 'image' is missing
      usedIngredientCount: json['usedIngredientCount'] ?? 0,  // Default to 0
      missedIngredientCount: json['missedIngredientCount'] ?? 0,  // Default to 0
    );
  }
}