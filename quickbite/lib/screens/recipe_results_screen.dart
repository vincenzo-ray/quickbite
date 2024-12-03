import 'package:flutter/material.dart';
import '../recipe/recipe.dart';
import '../services/api_services.dart';
import 'recipe_detail_screen.dart';
import 'package:logger/logger.dart';

class RecipeResultsScreen extends StatelessWidget {
  final Map<String, dynamic> filters;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    level: Level.debug,
  );

  const RecipeResultsScreen({super.key, required this.filters});

  Future<List<Recipe>> _fetchRecipes() async {
    _logger.d("Filters: $filters");

    // Validate filters
    if (filters['type'] == null) {
      _logger.w("Filter type is null. Please provide a valid filter type.");
      return [];
    }

    if (filters['type'] == 'ingredients' &&
        (filters['includeIngredients'] == null ||
            filters['includeIngredients'].isEmpty)) {
      _logger.w("No ingredients provided for ingredient-based search.");
      return [];
    }

    if (filters['type'] == 'query' &&
        (filters['query'] == null || filters['query'].isEmpty)) {
      _logger.w("No query provided for query-based search.");
      return [];
    }

    List<Recipe> recipes = [];
    try {
      if (filters['type'] == 'ingredients') {
        _logger.i(
            "Fetching recipes by ingredients: ${filters['includeIngredients']}");
        recipes = await ApiService.searchRecipesByIngredients(
          ingredients: filters['includeIngredients'],
        );
      } else if (filters['type'] == 'query') {
        _logger.i("Fetching recipes by query: ${filters['query']}");
        recipes = await ApiService.searchRecipesComplex(
          query: filters['query'],
          cuisine: filters['cuisine'],
          diet: filters['diet'],
          intolerances: filters['intolerances'],
          equipment: filters['equipment'],
          includeIngredients: filters['includeIngredients'],
          excludeIngredients: filters['excludeIngredients'],
          type: filters['type'],
          minCalories: filters['minCalories'],
          maxCalories: filters['maxCalories'],
          minCarbs: filters['minCarbs'],
          maxCarbs: filters['maxCarbs'],
          minProtein: filters['minProtein'],
          maxProtein: filters['maxProtein'],
          minFat: filters['minFat'],
          maxFat: filters['maxFat'],
        );
      }

      // Fetch and set nutrition data for each recipe
      for (final recipe in recipes) {
        _logger.d("Fetching nutrition data for recipe ID: ${recipe.id}");
        final nutritionData = await ApiService.fetchNutritionData(recipe.id);
        recipe.setNutritionData(nutritionData);
      }

      _logger.i("Successfully fetched ${recipes.length} recipes.");
    } catch (e, stackTrace) {
      _logger.e("Error fetching recipes", e, stackTrace);
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          filters['type'] == 'ingredients'
              ? "Recipes by Ingredients"
              : "Recipe Results",
        ),
        backgroundColor: const Color(0xFF657D5D),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _fetchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            _logger.e("Error in FutureBuilder: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            _logger.w("No recipes found for the applied filters");
            return const Center(child: Text("No recipes found"));
          }

          final recipes = snapshot.data!;
          _logger.d("Rendering ${recipes.length} recipes");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final healthTags = recipe.getHealthTags();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          recipe.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: healthTags.map((tag) {
                                Color tagColor;
                                if (tag.contains("Low Fat")) {
                                  tagColor = Colors.green;
                                } else if (tag.contains("High Protein")) {
                                  tagColor = Colors.blue;
                                } else if (tag.contains("Low Carb")) {
                                  tagColor = Colors.purple;
                                } else {
                                  tagColor = Colors.orange;
                                }
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: tagColor.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: tagColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                            if (filters['type'] == 'ingredients') ...[
                              const SizedBox(height: 8),
                              Text(
                                "Used Ingredients: ${recipe.usedIngredients.length}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                "Missing Ingredients: ${recipe.missedIngredients.length}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        color: Colors.grey[600],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailsScreen(
                                recipeId: recipe.id,
                                title: recipe.title,
                                usedIngredients: recipe.usedIngredients,
                                missedIngredients: recipe.missedIngredients,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}