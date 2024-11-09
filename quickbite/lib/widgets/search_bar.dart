// ingredient_search_bar.dart
import 'package:flutter/material.dart';
import '../services/api_services.dart';

class IngredientSearchBar extends StatefulWidget {
  // Callback function to notify the parent widget when an ingredient is added
  final Function(String) onIngredientAdded;

  // Constructor with required callback function and key parameter as super
  const IngredientSearchBar({super.key, required this.onIngredientAdded});

  @override
  IngredientSearchBarState createState() => IngredientSearchBarState();
}

class IngredientSearchBarState extends State<IngredientSearchBar> {
  // Text controller to capture input from the user
  final TextEditingController _controller = TextEditingController();

  // List of suggestions fetched from the API based on user input
  List<String> _suggestions = [];

  // Function to fetch suggestions from the API
  Future<void> _fetchSuggestions(String input) async {
    try {
      // Fetch suggestions from the ApiService and update the state with the results
      final suggestions = await ApiService.fetchIngredientSuggestions(input);
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  // Handle text changes and fetch new suggestions
  void _onTextChanged(String input) {
    if (input.isNotEmpty) {
      _fetchSuggestions(input); // Fetch suggestions when there is input
    } else {
      setState(() {
        _suggestions = []; // Clear suggestions when the input is empty
      });
    }
  }

  // Function called when a suggestion is tapped
  void _onSuggestionSelected(String suggestion) {
    // Call the callback to pass the selected ingredient to the parent widget
    widget.onIngredientAdded(suggestion);
    _controller.clear(); // Clear the input field after selection
    setState(() {
      _suggestions = []; // Reset suggestions after selection
    });
  }

  // Function called when user presses enter to manually submit an ingredient
  void _onSubmitManualEntry(String input) {
    if (input.isNotEmpty) {
      // Call the callback to pass the manual entry to the parent widget
      widget.onIngredientAdded(input);
      _controller.clear(); // Clear the input field after submission
      setState(() {
        _suggestions = []; // Reset suggestions after submission
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field for ingredient entry, with filtering and submission handling
        TextField(
          controller: _controller,
          onChanged: _onTextChanged, // Filter suggestions as user types
          onSubmitted: _onSubmitManualEntry, // Handle manual entry on enter key
          decoration: const InputDecoration(
            labelText: 'Enter your ingredients here', // Placeholder text
            border: OutlineInputBorder(),
          ),
        ),

        // Display filtered suggestions below the text field if any
        if (_suggestions.isNotEmpty)
          Container(
            height: 200.0, // Set height for the suggestions box
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2.0), // Add border color and width
              borderRadius: BorderRadius.circular(10.0), // rounded corners
            ),
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () => _onSuggestionSelected(_suggestions[index]), // Add ingredient on tap
                );
              },
            ),
          ),
      ],
    );
  }
}

