// recipe_results_screen.dart

import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/recipe.dart';
import '../screens/recipe_detail_screen.dart';

// RecipeResultsScreen shows a list of recipes based on the user's entered ingredients.
// It fetches data from the Spoonacular API using the ApiService.
class RecipeResultsScreen extends StatelessWidget {
  final List<String> ingredients;

  // Constructor accepting a list of ingredients entered by the user.
  const RecipeResultsScreen({Key? key, required this.ingredients}) : super(key: key);

  // Asynchronously fetches recipes matching the ingredients using the ApiService.
  Future<List<Recipe>> _fetchRecipes() async {
    return await ApiService.searchRecipesByIngredients(ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Results"), // AppBar title
      ),
      // FutureBuilder handles the asynchronous data fetching
      // and displays different widgets based on the request's state.
      body: FutureBuilder<List<Recipe>>(
        future: _fetchRecipes(),
        builder: (context, snapshot) {
          // Display a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // Display an error message if fetching fails
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } 
          // Display a message if no recipes are found
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No recipes found"));
          }

          // Recipes fetched successfully; display them in a list
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
                    // Fallback icon if image fails to load
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                  ),
                  title: Text(recipe.title), // Recipe title
                  subtitle: Text(
                    "Used Ingredients: ${recipe.usedIngredientCount}, "
                    "Missing Ingredients: ${recipe.missedIngredientCount}",
                  ),
                  onTap: () {
                    // Navigate to RecipeDetailsScreen with recipe ID and title
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