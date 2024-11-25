import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_services.dart';

/// RecipeDetailsScreen displays detailed information for a specific recipe, including:
/// - An image of the recipe
/// - Nutritional information
/// - Cooking instructions
/// 
/// This screen is navigated to from RecipeListScreen when a user selects a recipe.
class RecipeDetailsScreen extends StatelessWidget {
  // Unique ID of the recipe to fetch details for
  final int recipeId;
  // Title of the recipe, displayed in the app bar
  final String title;

  // custom URL scheme
  static const String _baseShareUrl = 'quickbite://recipe';

  // Constructor with required parameters and the super.key parameter
  // to properly use keys with this widget.
  const RecipeDetailsScreen({
    super.key, // Use super parameter for `key`
    required this.recipeId,
    required this.title,
  });

  // Private method to fetch recipe details from the API.
  // This method calls ApiService.fetchRecipeDetails, which connects
  // to the Spoonacular API to retrieve detailed information about the recipe.
  Future<Map<String, dynamic>> _fetchRecipeDetails() async {
    return await ApiService.fetchRecipeDetails(recipeId);
  }

  Future<void> _shareRecipe(BuildContext context) async {
    final String shareableLink = '$_baseShareUrl/$recipeId';
    
    final String shareMessage = '''
Check out this recipe: $title

Open in QuickBite app: $shareableLink

Don't have QuickBite? Search for "QuickBite" in your app store!''';
    
    
    await Share.share(
      shareMessage,
      subject: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Display the recipe title in the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRecipe(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRecipeDetails(), // Calls the method to fetch recipe details
        builder: (context, snapshot) {
          // Show a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display error message if there's an error during fetching
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // Display message if no data is found
          else if (!snapshot.hasData) {
            return const Center(child: Text("No details available"));
          }

          // Unpack the data from the API response
          final recipeDetails = snapshot.data!;
          final nutrition = recipeDetails['nutrition']?['nutrients'] ?? [];
          final instructions = recipeDetails['instructions'] ?? 'No instructions available';

          // Build the layout for recipe details using a ScrollView
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image, with a placeholder icon if the image fails to load
                Image.network(
                  recipeDetails['image'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
                const SizedBox(height: 16),

                // Recipe title
                Text(
                  recipeDetails['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Nutritional information section
                const Text("Nutritional Information:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Loop through each nutrient and display its name, amount, and unit
                for (var nutrient in nutrition)
                  Text(
                    "${nutrient['name'] ?? 'Unknown'}: ${nutrient['amount'] ?? 'N/A'} ${nutrient['unit'] ?? ''}",
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),

                // Cooking instructions section
                const Text("Instructions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Display instructions as HTML, allowing rich text formatting
                Html(data: instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}