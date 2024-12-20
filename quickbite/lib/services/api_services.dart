import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../recipe/recipe.dart';

class ApiService {
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';
  static final Logger _logger = Logger( // Initialize the logger
    level: Level.debug, // Ensures debug-level logs are output.
);
  // Method to load the API key from api_key.txt file using rootBundle
  static Future<String> _loadApiKey() async {
    try {
      final apiKey = await rootBundle.loadString('assets/api_key.txt'); // Use rootBundle to load API key
      return apiKey.trim(); // Remove any accidental whitespace
    } catch (e) {
      _logger.e("Failed to load API key: $e"); // Log as an error
      throw Exception('Failed to load API key: $e');
    }
  }

  // Method to search for recipes by ingredients with optional filters
static Future<List<Recipe>> searchRecipesByIngredients({
  required List<dynamic> ingredients, // Accept a dynamic list
  int number = 5,
  int ranking = 1, // Maximize used ingredients by default
  bool ignorePantry = true,
}) async {
  final apiKey = await _loadApiKey();

  // Ensure all elements in ingredients are Strings
  final List<String> sanitizedIngredients = ingredients.map((ingredient) {
    if (ingredient is String) {
      return ingredient;
    } else {
      throw Exception("Ingredient must be a string. Found: $ingredient");
    }
  }).toList();

  // Log the sanitized ingredients
  _logger.d("Sanitized ingredients: $sanitizedIngredients");

  if (sanitizedIngredients.isEmpty) {
    _logger.e("No ingredients provided for the search");
    throw Exception('Ingredients list cannot be empty');
  }

  final ingredientsString = sanitizedIngredients.join(',');

  // Log the ingredients being searched
  _logger.d("Searching recipes with ingredients: $ingredientsString");

  final queryParameters = {
    'apiKey': apiKey,
    'ingredients': ingredientsString,
    'number': number.toString(),
    'ranking': ranking.toString(),
    'ignorePantry': ignorePantry.toString(),
  };

  final uri = Uri.https('api.spoonacular.com', '/recipes/findByIngredients', queryParameters);

  // Log the URL being requested
  _logger.i("Requesting URL: $uri");

  final response = await http.get(uri);

  // Log the raw response body
  _logger.d("Raw API Response: ${response.body}");

  if (response.statusCode == 200) {
    try {
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) {
        _logger.w("No recipes found for the provided ingredients");
        return [];
      }

      final recipes = data.map((recipe) {
        return Recipe(
          id: recipe['id'],
          title: recipe['title'] ?? 'Untitled Recipe',
          imageUrl: recipe['image'] ?? '',
          usedIngredients: (recipe['usedIngredients'] as List<dynamic>)
              .map((ingredient) => ingredient['original'] as String)
              .toList(),
          missedIngredients: (recipe['missedIngredients'] as List<dynamic>)
              .map((ingredient) => ingredient['original'] as String)
              .toList(),
          usedIngredientCount: recipe['usedIngredientCount'] ?? 0,
          missedIngredientCount: recipe['missedIngredientCount'] ?? 0,
        );
      }).toList();

      _logger.i("Recipes found: ${recipes.length}");
      return recipes;
    } catch (e) {
      _logger.e("Error parsing JSON: $e");
      throw Exception('Failed to parse recipe data');
    }
  } else {
    _logger.w(
      "Request failed with status: ${response.statusCode} and message: ${response.body}",
    );
    throw Exception('Failed to load recipes');
  }
}

  // Method to fetch detailed nutrition information by recipe ID
  // Fetch detailed nutrition data
  static Future<Map<String, double>> fetchNutritionData(int recipeId) async {
    final apiKey = await _loadApiKey();
    final url = '$_baseUrl/$recipeId/nutritionWidget.json?apiKey=$apiKey';

    _logger.i("Fetching nutrition data for recipe ID: $recipeId");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final nutritionData = {
          "calories": _extractNutrientAmount(data, "Calories"),
          "fat": _extractNutrientAmount(data, "Fat"),
          "protein": _extractNutrientAmount(data, "Protein"),
          "carbs": _extractNutrientAmount(data, "Carbohydrates"),
        };
        return nutritionData;
      } catch (e) {
        _logger.e("Error parsing JSON for nutrition data: $e");
        throw Exception('Failed to parse nutrition data');
      }
    } else {
      _logger.w("Request for nutrition data failed with status: ${response.statusCode} and message: ${response.body}");
      throw Exception('Failed to load nutrition data');
    }
  }

  // Helper method to extract nutrient amount safely
  static double _extractNutrientAmount(Map<String, dynamic> data, String nutrientName) {
    try {
      final nutrient = data["nutrients"].firstWhere((n) => n["name"] == nutrientName, orElse: () => {"amount": 0});
      return (nutrient["amount"] as num).toDouble();
    } catch (e) {
      _logger.w("Could not extract nutrient amount for $nutrientName: $e");
      return 0.0;
    }
  }

  // Method to fetch recipe details by ID for nutrition and instructions
  static Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final apiKey = await _loadApiKey();
    final url = '$_baseUrl/$recipeId/information?apiKey=$apiKey&includeNutrition=true';

    _logger.i("Fetching recipe details for ID: $recipeId");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        _logger.e("Error parsing recipe details JSON: $e");
        throw Exception('Failed to parse recipe details');
      }
    } else {
      _logger.w("Request for recipe details failed with status: ${response.statusCode}");
      throw Exception('Failed to load recipe details');
    }
  }

  // Method to fetch autocomplete suggestions for ingredients
  static Future<List<String>> fetchIngredientSuggestions(String query) async {
    final apiKey = await _loadApiKey();
    final url = 'https://api.spoonacular.com/food/ingredients/autocomplete?apiKey=$apiKey&query=$query&number=10';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        List<dynamic> data = jsonDecode(response.body);
        final suggestions = data.map((item) => item['name'] as String).toList();
        _logger.i("Suggestions found: ${suggestions.length}"); // Log count
        return suggestions;
      } catch (e) {
        _logger.e("Error parsing JSON: $e"); // Log parsing error
        throw Exception('Failed to parse suggestion data');
      }
    } else {
      _logger.w("Request failed with status: ${response.statusCode} : ${jsonDecode(response.body)}"); // Log as a warning
      throw Exception('Failed to load suggestions');
    }
  }

  // Query suggestions similar to ingredients suggestions
  static Future<List<String>> fetchQuerySuggestions(String query) async {
    final apiKey = await _loadApiKey();
    final url = 'https://api.spoonacular.com/recipes/autocomplete?query=$query&number=10&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        List<dynamic> data = jsonDecode(response.body);
        final suggestions = data.map((item) => item['title'] as String).toList();
        _logger.i("Suggestions found: ${suggestions.length}"); // Log count
        return suggestions;
      } catch (e) {
        _logger.e("Error parsing JSON: $e");
        throw Exception('Failed to parse query suggestion data');
      }
    } else {
      _logger.w("Request failed with status: ${response.statusCode} : ${jsonDecode(response.body)}");
      throw Exception('Failed to load query suggestions');
    }
  }

  // Method to fetch nutrition widget HTML for a recipe
  static Future<String> fetchNutritionWidgetHtml(String ingredientList, int servings) async {
    final apiKey = await _loadApiKey();
    const url = '$_baseUrl/visualizeNutrition';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'text/html',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'apiKey': apiKey,
        'defaultCss': 'true', // Include default CSS for styling
        'showBacklink': 'false', // Avoid backlink to Spoonacular
        'ingredientList': ingredientList, // Dynamically provided ingredient list
        'servings': servings.toString(), // Dynamically provided servings count
      },
    );

    if (response.statusCode == 200) {
      return response.body; // HTML response for nutrition
    } else {
      _logger.w("Failed to load nutrition widget with status: ${response.statusCode}, message: ${response.body}");
      throw Exception('Failed to load nutrition widget');
    }
  }

  // Search recipes using the complex search endpoint
  static Future<List<Recipe>> searchRecipesComplex({
    String? query,
    String? cuisine,
    String? diet,
    String? intolerances,
    String? equipment,
    String? includeIngredients,
    String? excludeIngredients,
    String? type,
    double? minCalories,
    double? maxCalories,
    double? minCarbs,
    double? maxCarbs,
    double? minProtein,
    double? maxProtein,
    double? minFat,
    double? maxFat,
    bool limitLicense = false,
  }) async {
    final apiKey = await _loadApiKey();

    final queryParameters = {
      'apiKey': apiKey,
      if (query != null && query.isNotEmpty) 'query': query,
      if (cuisine != null && cuisine.isNotEmpty) 'cuisine': cuisine,
      if (diet != null && diet.isNotEmpty) 'diet': diet,
      if (intolerances != null && intolerances.isNotEmpty) 'intolerances': intolerances,
      if (equipment != null && equipment.isNotEmpty) 'equipment': equipment,
      if (includeIngredients != null && includeIngredients.isNotEmpty) 'includeIngredients': includeIngredients,
      if (excludeIngredients != null && excludeIngredients.isNotEmpty) 'excludeIngredients': excludeIngredients,
      if (type != null && type.isNotEmpty) 'type': type,
      if (minCalories != null) 'minCalories': minCalories.toString(),
      if (maxCalories != null) 'maxCalories': maxCalories.toString(),
      if (minCarbs != null) 'minCarbs': minCarbs.toString(),
      if (maxCarbs != null) 'maxCarbs': maxCarbs.toString(),
      if (minProtein != null) 'minProtein': minProtein.toString(),
      if (maxProtein != null) 'maxProtein': maxProtein.toString(),
      if (minFat != null) 'minFat': minFat.toString(),
      if (maxFat != null) 'maxFat': maxFat.toString(),
      'number': '5',
    };

    final uri = Uri.https('api.spoonacular.com', '/recipes/complexSearch', queryParameters);
    _logger.i("Requesting URL: $uri");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final recipes = (data['results'] as List).map((recipe) => Recipe.fromJson(recipe)).toList();
        _logger.i("Recipes found: ${recipes.length}");
        return recipes;
      } catch (e) {
        _logger.e("Error parsing JSON: $e");
        throw Exception('Failed to parse recipe data');
      }
    } else {
      _logger.w("Request failed with status: ${response.statusCode} and message: ${response.body}");
      throw Exception('Failed to load recipes');
    }
  }

  // Method to fetch product name by UPC
  static Future<String?> fetchProductNameByUPC(String upc) async {
    final apiKey = await _loadApiKey(); // Load the API key
    final url = Uri.parse('https://api.spoonacular.com/food/products/upc/$upc?apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['title'] as String?;
      } else {
        _logger.w('Failed to fetch product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching product: $e');
      return null;
    }
  }
}