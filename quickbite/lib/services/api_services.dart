import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; // Import rootBundle to load assets
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../recipe/recipe.dart';

class ApiService {
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';
  static final Logger _logger = Logger(); // Initialize the logger

  // Method to load the API key from api_key.txt file using rootBundle
  static Future<String> _loadApiKey() async {
    try {
      final apiKey = await rootBundle.loadString('assets/api_key.txt'); // Use rootBundle to load API key
      return apiKey;
    } catch (e) {
      _logger.e("Failed to load API key: $e"); // Log as an error
      throw Exception('Failed to load API key: $e');
    }
  }

  // Method to search for recipes by ingredients with no missing ingredients
  static Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients) async {
    final apiKey = await _loadApiKey();
    final ingredientsString = ingredients.join(',');
    final url = '$_baseUrl/findByIngredients?apiKey=$apiKey&ingredients=$ingredientsString&number=10&ranking=1&ignorePantry=true';

    _logger.i("Requesting URL: $url"); // Log as informational
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        List<dynamic> data = jsonDecode(response.body);
        final recipes = data.map((recipe) => Recipe.fromJson(recipe)).toList();
        _logger.i("Recipes found: ${recipes.length}"); // Log count as informational
        return recipes;
      } catch (e) {
        _logger.e("Error parsing JSON: $e"); // Log parsing error
        throw Exception('Failed to parse recipe data');
      }
    } else {
      _logger.w("Request failed with status: ${response.statusCode}"); // Log as a warning
      throw Exception('Failed to load recipes');
    }
  }

  // Method to fetch recipe details by ID for nutrition and instructions
  static Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final apiKey = await _loadApiKey();
    final url = '$_baseUrl/$recipeId/information?apiKey=$apiKey&includeNutrition=true';

    _logger.i("Fetching recipe details for ID: $recipeId"); // Log detail request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        _logger.e("Error parsing recipe details JSON: $e"); // Log parsing error
        throw Exception('Failed to parse recipe details');
      }
    } else {
      _logger.w("Request for recipe details failed with status: ${response.statusCode}"); // Log as a warning
      throw Exception('Failed to load recipe details');
    }
  }
}