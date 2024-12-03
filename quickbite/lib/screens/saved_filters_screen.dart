import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/saved_filter.dart';
import 'filter_screen.dart';

class SavedFiltersScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterSelected;

  const SavedFiltersScreen({
    super.key,
    required this.onFilterSelected,
  });

  @override
  State<SavedFiltersScreen> createState() => _SavedFiltersScreenState();
}


class _SavedFiltersScreenState extends State<SavedFiltersScreen> {
  List<SavedFilter> _savedFilters = [];

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedFiltersJson = prefs.getString('saved_filters');
    
    if (savedFiltersJson != null) {
      final List<dynamic> decoded = jsonDecode(savedFiltersJson);
      setState(() {
        _savedFilters = decoded
            .map((item) => SavedFilter.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _deleteFilter(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedFilters.removeAt(index);
    });
    await prefs.setString('saved_filters', 
      jsonEncode(_savedFilters.map((f) => f.toJson()).toList()));
  }

  void _applyFilter(SavedFilter filter) {
    final Map<String, dynamic> appliedFilters = Map<String, dynamic>.from(filter.filters);
    
    print('Original filters: ${filter.filters}');
    
    if (filter.filters['includeIngredients'] != null) {
      if (filter.filters['includeIngredients'] is String) {
        appliedFilters['includeIngredients'] = 
            filter.filters['includeIngredients'].toString().split(',')
            .where((ingredient) => ingredient.isNotEmpty)
            .toList();
      } else if (filter.filters['includeIngredients'] is List) {
        appliedFilters['includeIngredients'] = 
            List<String>.from(filter.filters['includeIngredients'])
            .where((ingredient) => ingredient.isNotEmpty)
            .toList();
      } else {
        appliedFilters['includeIngredients'] = <String>[];
      }
    } else {
      appliedFilters['includeIngredients'] = <String>[];
    }
    
    print('Applied filters after processing: $appliedFilters');

    widget.onFilterSelected(appliedFilters);
    
    Navigator.pop(context);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          onFiltersApplied: widget.onFilterSelected,
          initialFilters: appliedFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Saved Filters'),
      ),
      body: _savedFilters.isEmpty
          ? const Center(
              child: Text('No saved filters'),
            )
          : ListView.builder(
              itemCount: _savedFilters.length,
              itemBuilder: (context, index) {
                final filter = _savedFilters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  color: const Color(0xFF657D5D),
                  child: ListTile(
                    title: Text(
                      filter.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _getFilterSummary(filter),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _deleteFilter(index),
                    ),
                    onTap: () => _applyFilter(filter),
                  ),
                );
              },
            ),
    );
  }

  String _getFilterSummary(SavedFilter filter) {
    final List<String> summary = [];
    
    if (filter.filters['includeIngredients'] != null) {
      if (filter.filters['includeIngredients'] is String) {
        summary.add('Include Ingredients: ${filter.filters['includeIngredients']}');
      } else if (filter.filters['includeIngredients'] is List) {
        summary.add('Include Ingredients: ${filter.filters['includeIngredients'].join(', ')}');
      }
    }

    return summary.join('\n');
  }
} 