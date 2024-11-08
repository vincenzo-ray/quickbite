// recipe_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/api_services.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final int recipeId;
  final String title;

  const RecipeDetailsScreen({Key? key, required this.recipeId, required this.title}) : super(key: key);

  Future<Map<String, dynamic>> _fetchRecipeDetails() async {
    return await ApiService.fetchRecipeDetails(recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  recipeDetails['image'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
                const SizedBox(height: 16),
                Text(
                  recipeDetails['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text("Nutritional Information:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                for (var nutrient in nutrition)
                  Text(
                    "${nutrient['name'] ?? 'Unknown'}: ${nutrient['amount'] ?? 'N/A'} ${nutrient['unit'] ?? ''}",
                    style: TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),
                Text("Instructions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Html(data: instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}