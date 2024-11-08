import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../recipe/recipe.dart';

class ApiService {
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  // Method to load the API key from api_key.txt file
  static Future<String> _loadApiKey() async {
    try {
      final file = File('lib/services/api_key.txt'); // path to api key
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to load API key: $e');
    }
  }

  // Method to search for recipes by ingredients with no missing ingredients
  static Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients) async {
    final apiKey = await _loadApiKey();
    final ingredientsString = ingredients.join(',');
    final url = '$_baseUrl/findByIngredients?apiKey=$apiKey&ingredients=$ingredientsString&number=10&ranking=1&ignorePantry=true';

    print("Requesting URL: $url");  // Log the complete request URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        List<dynamic> data = jsonDecode(response.body);
        final recipes = data.map((recipe) => Recipe.fromJson(recipe)).toList();
        print("Recipes found: ${recipes.length}");  // Check the count of recipes
        return recipes;
      } catch (e) {
        print("Error parsing JSON: $e");
        throw Exception('Failed to parse recipe data');
      }
    } else {
      print("Request failed with status: ${response.statusCode}");
      throw Exception('Failed to load recipes');
    }
  }

  // Method to fetch recipe details by ID for nutrition and instructions
  static Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final apiKey = await _loadApiKey();
    final url = '$_baseUrl/$recipeId/information?apiKey=$apiKey&includeNutrition=true';

    print("Fetching recipe details for ID: $recipeId");  // Log the detail request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print("Error parsing recipe details JSON: $e");
        throw Exception('Failed to parse recipe details');
      }
    } else {
      print("Request for recipe details failed with status: ${response.statusCode}");
      throw Exception('Failed to load recipe details');
    }
  }
}