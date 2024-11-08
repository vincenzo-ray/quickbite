// ingredient_search_bar.dart
import 'package:flutter/material.dart';

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

  // Sample list of ingredient suggestions
  final List<String> _suggestions = [
    'Chicken', 'Chicken Breast', 'Rice', 'Beans', 'Beef', 'Carrot', 'Tomato', 'Broccoli'
  ];

  // List of suggestions filtered based on user input
  List<String> _filteredSuggestions = [];

  // Function to filter suggestions as user types
  void _onTextChanged(String input) {
    setState(() {
      // Filter suggestions based on the input, ignoring case
      _filteredSuggestions = _suggestions
          .where((ingredient) => ingredient.toLowerCase().contains(input.toLowerCase()))
          .toList();
    });
  }

  // Function called when a suggestion is tapped
  void _onSuggestionSelected(String suggestion) {
    // Call the callback to pass the selected ingredient to the parent widget
    widget.onIngredientAdded(suggestion);
    _controller.clear(); // Clear the input field after selection
    setState(() {
      _filteredSuggestions = []; // Reset suggestions after selection
    });
  }

  // Function called when user presses enter to manually submit an ingredient
  void _onSubmitManualEntry(String input) {
    if (input.isNotEmpty) {
      // Call the callback to pass the manual entry to the parent widget
      widget.onIngredientAdded(input);
      _controller.clear(); // Clear the input field after submission
      setState(() {
        _filteredSuggestions = []; // Reset suggestions after submission
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
        if (_filteredSuggestions.isNotEmpty)
          Column(
            children: _filteredSuggestions.map((suggestion) {
              return ListTile(
                title: Text(suggestion),
                onTap: () => _onSuggestionSelected(suggestion), // Add ingredient on tap
              );
            }).toList(),
          ),
      ],
    );
  }
}