import 'package:flutter/material.dart';
import 'recipe_results_screen.dart';
import '../widgets/search_bar.dart';

// HomeScreen serves as the starting point of the QuickBite app,
// where users can enter ingredients and find matching recipes.
class HomeScreen extends StatefulWidget {
  // Use super parameter for key in the constructor
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// State class for HomeScreen, holding and managing ingredient list state
class HomeScreenState extends State<HomeScreen> {
  // List to store the ingredients entered by the user
  final List<String> ingredients = [];

  // Adds a new ingredient to the list if it's not empty
  void _addIngredient(String ingredient) {
    if (ingredient.isNotEmpty) {
      setState(() {
        ingredients.add(ingredient); // Updates the ingredient list
      });
    }
  }

  // Removes an ingredient from the list
  void _removeIngredient(String ingredient) {
    setState(() {
      ingredients.remove(ingredient); // Updates the list to reflect removal
    });
  }

  // Navigates to the RecipeResultsScreen with the entered ingredients
  void _findMeals() {
    if (ingredients.isNotEmpty) {
      // Checks if the list has at least one ingredient
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeResultsScreen(ingredients: ingredients),
        ),
      );
    } else {
      // Shows an alert if no ingredients were added
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one ingredient.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar for the HomeScreen with a title and info icon
      appBar: AppBar(
        title: const Text("QuickBite"),
        backgroundColor: Colors.orangeAccent,
        actions: [
          // Info button shows an AlertDialog with usage instructions
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text("How to use QuickBite"),
                  content: Text("Enter ingredients, then press 'Find Meals' to get recipes."),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom IngredientSearchBar widget for inputting ingredients
            IngredientSearchBar(
              onIngredientAdded: _addIngredient, // Calls _addIngredient when a new ingredient is entered
            ),
            const SizedBox(height: 10),
            // Wrap widget displays the list of entered ingredients as chips
            Wrap(
              spacing: 8, // Spacing between chips
              children: ingredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient), // Displays ingredient name
                  deleteIcon: const Icon(Icons.close), // 'X' icon for deletion
                  onDeleted: () => _removeIngredient(ingredient), // Deletes the ingredient from the list
                );
              }).toList(),
            ),
            const Spacer(), // Adds space between the chips and the "Find Meals" button
            Center(
              // Elevated button to initiate the recipe search
              child: ElevatedButton(
                onPressed: _findMeals, // Calls _findMeals to proceed with the search
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Find Meals",
                  style: TextStyle(fontSize: 18), // Button text styling
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}