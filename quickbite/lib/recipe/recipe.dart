// recipe.dart
import 'package:logger/logger.dart';

// The Recipe model represents a single recipe item, with essential details like
// ID, title, image URL, used ingredient count, and missed ingredient count.
class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final List<String> usedIngredients; // List of used ingredients
  final List<String> missedIngredients; // List of missed ingredients
  final int usedIngredientCount;
  final int missedIngredientCount;
  double? calories;
  double? fat;
  double? protein;
  double? carbs;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.usedIngredients,
    required this.missedIngredients,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
    this.calories,
    this.fat,
    this.protein,
    this.carbs,
  });

  // Factory constructor to parse JSON without nutrition data
  factory Recipe.fromJson(Map<String, dynamic> json) {
  Logger().d("Parsing Recipe JSON: $json");

  // Check if the fields exist and are lists
  final usedIngredientsList = json['usedIngredients'] as List<dynamic>? ?? [];
  final missedIngredientsList = json['missedIngredients'] as List<dynamic>? ?? [];

  // Debug logs for extracted raw lists
  Logger().d("Raw usedIngredients: $usedIngredientsList");
  Logger().d("Raw missedIngredients: $missedIngredientsList");

  // Map the lists to extract 'original' field or handle empty values
  final usedIngredients = usedIngredientsList
      .map((ingredient) => ingredient is Map<String, dynamic> && ingredient.containsKey('original') 
          ? ingredient['original'] as String 
          : "Unknown")
      .toList();

  final missedIngredients = missedIngredientsList
      .map((ingredient) => ingredient is Map<String, dynamic> && ingredient.containsKey('original') 
          ? ingredient['original'] as String 
          : "Unknown")
      .toList();

  // Debug logs for mapped ingredients
  Logger().d("Extracted usedIngredients: $usedIngredients");
  Logger().d("Extracted missedIngredients: $missedIngredients");

  return Recipe(
    id: json['id'] ?? 0,
    title: json['title'] ?? 'Untitled Recipe',
    imageUrl: json['image'] ?? '',
    usedIngredients: usedIngredients,
    missedIngredients: missedIngredients,
    usedIngredientCount: usedIngredients.length,
    missedIngredientCount: missedIngredients.length,
  );
}

  // Add a method to set nutrition data after fetching it
  void setNutritionData(Map<String, double> nutritionData) {
    calories = nutritionData["calories"];
    fat = nutritionData["fat"];
    protein = nutritionData["protein"];
    carbs = nutritionData["carbs"];
  }

  // Generate health tags based on the recipe's nutrition values
  List<String> getHealthTags() {
    final tags = <String>[];
    if (fat != null && fat! < 10) tags.add("Low Fat");
    if (protein != null && protein! > 20) tags.add("High Protein");
    if (carbs != null && carbs! < 20) tags.add("Low Carb");
    if (calories != null && calories! < 300) tags.add("Low Calorie");
    return tags;
  }
}