import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_services.dart';

class QuerySearchBar extends StatefulWidget {
  final Function(String) onQueryAdded;

  const QuerySearchBar({
    super.key,
    required this.onQueryAdded,
  });

  @override
  QuerySearchBarState createState() => QuerySearchBarState();
}

class QuerySearchBarState extends State<QuerySearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  Timer? _debounce;

  Future<void> _fetchSuggestions(String input) async {
    try {
      final suggestions = await ApiService.fetchQuerySuggestions(input);
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  // debounce so API doen't get called too often
  void _onTextChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 425  ), () {
      if (input.isNotEmpty) {
        _fetchSuggestions(input);  // Fetch suggestions when there is input
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    widget.onQueryAdded(suggestion);
    setState(() {
      _suggestions = []; // Reset suggestions after selection
    });
  }

  // Function called when user presses enter to manually submit an ingredient
  void _onSubmitQuery(String query) {
    if (query.isNotEmpty) {
      widget.onQueryAdded(query);
      setState(() {
        _suggestions = []; // Reset suggestions after submission
      });
    }
  }

  String get query => _controller.text;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onTextChanged, // Filter suggestions as user types
          onSubmitted: _onSubmitQuery,
          decoration: const InputDecoration(
            labelText: 'Enter your query or use the filters!',
            border: OutlineInputBorder(),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            height: 200.0, // Set height for the suggestions box
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2.0), // Add border color and width
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
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
