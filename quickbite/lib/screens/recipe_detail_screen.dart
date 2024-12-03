import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_services.dart';

/// Displays detailed information for a recipe, including:
/// - Image, title, nutrition, ingredients, and instructions
class RecipeDetailsScreen extends StatelessWidget {
  final int recipeId;
  final String title;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeId,
    required this.title,
  });

  static const String _baseShareUrl = 'quickbite://recipe';

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
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRecipe(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRecipeDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No details available"));
          }

          final recipeDetails = snapshot.data!;
          final nutrition = recipeDetails['nutrition']?['nutrients'] ?? [];
          final instructions = recipeDetails['instructions'] ?? 'No instructions available';
          final usedIngredients = recipeDetails['usedIngredients'] ?? [];
          final missedIngredients = recipeDetails['missedIngredients'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    recipeDetails['image'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 200),
                  ),
                ),
                const SizedBox(height: 16),

                // Recipe Title
                Text(
                  recipeDetails['title'] ?? 'Recipe Title',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Nutritional Information
                const Text(
                  "Nutritional Information:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (nutrition.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nutrition.map<Widget>((nutrient) {
                      return Text(
                        "${nutrient['name'] ?? 'Unknown'}: ${nutrient['amount'] ?? 'N/A'} ${nutrient['unit'] ?? ''}",
                        style: const TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  )
                else
                  const Text("No nutritional data available."),
                const SizedBox(height: 16),

                // Ingredients Section
                const Text(
                  "Ingredients:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Used Ingredients (${usedIngredients.length}):",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                for (var ingredient in usedIngredients)
                  Text(
                    "- ${ingredient['original'] ?? ingredient['name']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 8),
                Text(
                  "Missing Ingredients (${missedIngredients.length}):",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                for (var ingredient in missedIngredients)
                  Text(
                    "- ${ingredient['original'] ?? ingredient['name']}",
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                const SizedBox(height: 16),

                // Instructions Section
                const Text(
                  "Instructions:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Html(data: instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}