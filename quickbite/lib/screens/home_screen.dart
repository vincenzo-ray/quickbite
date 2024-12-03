import 'package:flutter/material.dart';
import 'recipe_results_screen.dart';
import 'filter_screen.dart';
import '../widgets/search_bar.dart';
import 'saved_filters_screen.dart';
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
    // Log the current state of filters and query
    _logger.d("Current query: $query");
    _logger.d("Current filters: $filters");

    // If there's a query, use it as the primary search method
    if (query.isNotEmpty) {
      filters['type'] = 'query';
      filters['query'] = query;
    } 
    // If there are ingredients, use them as the search method
    else if (filters['includeIngredients'] != null && filters['includeIngredients'].toString().isNotEmpty) {
      filters['type'] = 'ingredients';
      
      if (filters['includeIngredients'] is String) {
        final ingredients = filters['includeIngredients']
            .toString()
            .split(',')
            .map((ingredient) => ingredient.trim())
            .where((ingredient) => ingredient.isNotEmpty)
            .toList();
        filters['includeIngredients'] = ingredients;
      }
    }
    // If neither query nor ingredients are provided, just use the filters
    else {
      filters['type'] = 'query';
      filters['query'] = ''; // Empty query to search with just filters
    }

    // Log the final filters being passed
    _logger.d("Final filters being applied: $filters");

    // Navigate to RecipeResultsScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeResultsScreen(filters: filters),
      ),
    );
  }

  void _openSavedFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedFiltersScreen(
          onFilterSelected: (selectedFilters) {
            setState(() {
              filters.clear();
              filters.addAll(selectedFilters);
              print('Applied filters: $filters');
            });
          },
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openFilterScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDE8E3F),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Filters",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openSavedFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDE8E3F),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Saved Filters",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}