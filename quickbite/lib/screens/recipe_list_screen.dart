import 'package:flutter/material.dart';
import '../recipe/recipe.dart'; // Import the Recipe model class
import 'recipe_detail_screen.dart'; // Import the RecipeDetailsScreen for navigation
import 'dart:developer' as developer; // use log for print statements

/// RecipeListScreen displays a list of recipes provided from another screen.
/// It uses ListView to show recipes with a thumbnail, title, and ingredient count.
class RecipeListScreen extends StatelessWidget {
  final List<Recipe> recipes;

  // Constructor with super.key for consistency and to allow for unique identification of the widget
  const RecipeListScreen({super.key, required this.recipes});

// Inside RecipeListScreen class
@override
  Widget build(BuildContext context) {
    // Log the number of recipes for debugging purposes
    developer.log("Number of recipes to display: ${recipes.length}", name: 'RecipeListScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe List'), // App bar title for the screen
      ),
      // Check if there are recipes to display; if not, show a message
      body: recipes.isNotEmpty
          ? ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index]; // Get the recipe at the current index

                return ListTile(
                  // Display recipe image or show an icon if the image fails to load
                  leading: Image.network(
                    recipe.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image),
                  ),
                  // Display recipe title and ingredient count
                  title: Text(recipe.title),
                  subtitle: Text(
                    'Used: ${recipe.usedIngredientCount}, Missing: ${recipe.missedIngredientCount}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  // Navigate to RecipeDetailsScreen when a recipe is tapped
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(
                          recipeId: recipe.id,
                          title: recipe.title,
                          usedIngredients: recipe.usedIngredients, // Pass used ingredients
                          missedIngredients: recipe.missedIngredients, // Pass missed ingredients
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text('No Recipes found'),
            ), // no recipes are available
    );
  }
}