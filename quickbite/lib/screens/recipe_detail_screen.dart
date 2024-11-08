// recipe_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Import flutter_html to handle HTML content
import '../services/api_services.dart'; // Import API service to fetch recipe details

// RecipeDetailsScreen shows detailed information about a selected recipe,
// including nutritional info and instructions, by fetching data from the API.
class RecipeDetailsScreen extends StatelessWidget {
  final int recipeId; // ID of the recipe to fetch details
  final String title; // Title of the recipe for AppBar

  // Constructor requiring recipe ID and title
  const RecipeDetailsScreen({Key? key, required this.recipeId, required this.title}) : super(key: key);

  // Asynchronously fetches recipe details using the recipe ID
  Future<Map<String, dynamic>> _fetchRecipeDetails() async {
    return await ApiService.fetchRecipeDetails(recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // AppBar title shows the recipe name
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRecipeDetails(),
        builder: (context, snapshot) {
          // Show a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // Display error message if there was an error during fetching
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } 
          // Show a "No details available" message if no data is found
          else if (!snapshot.hasData) {
            return const Center(child: Text("No details available"));
          }

          // Extract recipe details from the fetched data
          final recipeDetails = snapshot.data!;
          final nutrition = recipeDetails['nutrition']?['nutrients'] ?? []; // Nutritional data
          final instructions = recipeDetails['instructions'] ?? 'No instructions available'; // Instructions text

          // Display the fetched details in a scrollable layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display recipe image or fallback icon
                Image.network(
                  recipeDetails['image'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
                const SizedBox(height: 16),

                // Display recipe title
                Text(
                  recipeDetails['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Display nutritional information header
                Text("Nutritional Information:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // List nutritional data, showing "Unknown" for missing fields
                for (var nutrient in nutrition)
                  Text(
                    "${nutrient['name'] ?? 'Unknown'}: ${nutrient['amount'] ?? 'N/A'} ${nutrient['unit'] ?? ''}",
                    style: TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),

                // Display instructions header
                Text("Instructions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Use Html widget to format instructions content
                Html(data: instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}