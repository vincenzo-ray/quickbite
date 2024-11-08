import 'package:flutter/material.dart';
import '../recipe/recipe.dart';
import '../services/api_services.dart';
import 'recipe_detail_screen.dart';

class RecipeResultsScreen extends StatelessWidget {
  final List<String> ingredients;

  const RecipeResultsScreen({
    super.key, // Use super parameter for `key`
    required this.ingredients,
  });

  // Fetch recipes using ApiService
  Future<List<Recipe>> _fetchRecipes() async {
    return await ApiService.searchRecipesByIngredients(ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Results"),
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
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Image.network(
                    recipe.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  title: Text(recipe.title),
                  subtitle: Text(
                    "Used Ingredients: ${recipe.usedIngredientCount}, "
                    "Missing Ingredients: ${recipe.missedIngredientCount}",
                  ),
                  onTap: () {
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
              );
            },
          );
        },
      ),
    );
  }
}