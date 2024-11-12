import 'package:flutter/material.dart';
import '../recipe/recipe.dart';
import '../services/api_services.dart';
import 'recipe_detail_screen.dart';

class RecipeResultsScreen extends StatelessWidget {
  final List<String> ingredients;
  final String? dietFilter;

  const RecipeResultsScreen({
    super.key,
    required this.ingredients,
    this.dietFilter,
  });

  Future<List<Recipe>> _fetchRecipes() async {
    final recipes = await ApiService.searchRecipesByIngredients(
      ingredients,
      diet: dietFilter,
    );

    for (final recipe in recipes) {
      final nutritionData = await ApiService.fetchNutritionData(recipe.id);
      recipe.setNutritionData(nutritionData);
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for contrast
      appBar: AppBar(
        title: const Text("Recipe Results"),
        backgroundColor: Colors.orangeAccent,
        elevation: 0, // Flat AppBar for modern look
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _fetchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No recipes found"));
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final healthTags = recipe.getHealthTags();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3, // Slight shadow for depth
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
                            const SizedBox(height: 8),
                            Text(
                              "Used Ingredients: ${recipe.usedIngredientCount}, "
                              "Missing Ingredients: ${recipe.missedIngredientCount}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
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