import 'package:flutter/material.dart';
import 'recipe_results_screen.dart';
import 'filter_screen.dart';
import '../widgets/search_bar.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  final Map<String, dynamic> filters = {};
  String query = "";

  void _setQuery(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  void _applyFilters(Map<String, dynamic> appliedFilters) {
    setState(() {
      filters.addAll(appliedFilters);
    });
  }

  void _openFilterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          onFiltersApplied: _applyFilters,
          initialFilters: filters,
        ),
      ),
    );
  }

  void _findMeals() {
  if (query.isNotEmpty) {
    filters['type'] = 'query'; // Search by query
    filters['query'] = query;
  } else if (filters['includeIngredients'] != null && filters['includeIngredients'].isNotEmpty) {
    filters['type'] = 'ingredients'; // Search by ingredients

    // Convert the comma-separated string into a list of strings
    filters['includeIngredients'] = filters['includeIngredients']
        .split(',')
        .map((ingredient) => ingredient.trim())
        .toList();
  } else {
    // Log a warning if no valid input is provided
    _logger.e("No valid input provided. Either query or includeIngredients is required.");
    return;
  }

  // Log the filters being passed
  _logger.d("Filters applied: $filters");

  // Navigate to RecipeResultsScreen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeResultsScreen(filters: filters),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF657D5D), Color(0xFF657D5D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "QuickBite",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text("How to use QuickBite"),
                          content: Text(
                            "- Got something in mind? Enter it in the search box.\n\n" "- Otherwise use the filters for a random search!\n\n"
                                "- Press 'Find Meals' to get recipes.\n\n",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24), // Space between header and content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QuerySearchBar(
                    onQueryAdded: _setQuery,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _findMeals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF657D5D),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Find Meals",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _openFilterScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDE8E3F),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Filters",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}