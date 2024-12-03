import 'package:flutter/material.dart';
import '../widgets/saved_filter.dart';
import 'barcode_scanner_screen.dart';
import '../services/api_services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FilterScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;
  final Map<String, dynamic> initialFilters;

  const FilterScreen({
    super.key,
    required this.onFiltersApplied,
    required this.initialFilters,
  });

  @override
  FilterScreenState createState() => FilterScreenState();
}

class FilterScreenState extends State<FilterScreen> {
  late Map<String, dynamic> _filters;
  final _controllers = <String, TextEditingController>{};
  final List<String> _includeIngredientsList = []; // Store ingredients dynamically

  @override
  void initState() {
    super.initState();

    // Ensure _filters is initialized properly
    _filters = Map<String, dynamic>.from(widget.initialFilters);

    // Ensure includeIngredients is initialized
    _filters['includeIngredients'] = _filters['includeIngredients'] ?? '';

    // Initialize controllers for text fields
    _controllers['equipment'] = TextEditingController(text: _filters['equipment']);
    _controllers['excludeIngredients'] = TextEditingController(text: _filters['excludeIngredients']);
    _controllers['includeIngredients'] = TextEditingController(); // For dynamic ingredient entry
    _controllers['minCalories'] = TextEditingController(text: _filters['minCalories']?.toString());
    _controllers['maxCalories'] = TextEditingController(text: _filters['maxCalories']?.toString());
    _controllers['minCarbs'] = TextEditingController(text: _filters['minCarbs']?.toString());
    _controllers['maxCarbs'] = TextEditingController(text: _filters['maxCarbs']?.toString());
    _controllers['minProtein'] = TextEditingController(text: _filters['minProtein']?.toString());
    _controllers['maxProtein'] = TextEditingController(text: _filters['maxProtein']?.toString());
    _controllers['minFat'] = TextEditingController(text: _filters['minFat']?.toString());
    _controllers['maxFat'] = TextEditingController(text: _filters['maxFat']?.toString());
  }

  // Add an ingredient to the list and clear the input field
  void _addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty) {
      setState(() {
        if (!_includeIngredientsList.contains(ingredient.trim())) {
          _includeIngredientsList.add(ingredient.trim());
          print('Added ingredient: $ingredient');
          // Show SnackBar for feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "$ingredient" to ingredients list.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Show SnackBar if ingredient is already in the list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$ingredient" is already in the list.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
      _controllers['includeIngredients']?.clear(); // Clear the input field
    }
  }

  // Remove an ingredient from the list
void _removeIngredient(String ingredient) {
  setState(() {
    _includeIngredientsList.remove(ingredient);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$ingredient" from the list.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}

  // Apply filters on button press
  void _applyFilters() {
    _filters['equipment'] = _controllers['equipment']?.text;
    _filters['includeIngredients'] =
        _includeIngredientsList.join(','); // Join the list as a comma-separated string
    _filters['excludeIngredients'] = _controllers['excludeIngredients']?.text;
    _filters['minCalories'] =
        double.tryParse(_controllers['minCalories']?.text ?? '');
    _filters['maxCalories'] =
        double.tryParse(_controllers['maxCalories']?.text ?? '');
    _filters['minCarbs'] =
        double.tryParse(_controllers['minCarbs']?.text ?? '');
    _filters['maxCarbs'] =
        double.tryParse(_controllers['maxCarbs']?.text ?? '');
    _filters['minProtein'] =
        double.tryParse(_controllers['minProtein']?.text ?? '');
    _filters['maxProtein'] =
        double.tryParse(_controllers['maxProtein']?.text ?? '');
    _filters['minFat'] = double.tryParse(_controllers['minFat']?.text ?? '');
    _filters['maxFat'] = double.tryParse(_controllers['maxFat']?.text ?? '');

    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _filters.clear();
      _includeIngredientsList.clear();
      _controllers.forEach((key, controller) => controller.clear());
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Apply Filters'),
      ),
      body: ListView(
        children: [
          _buildDropdown('Cuisine', 'cuisine', [
            'African',
            'Asian',
            'American',
            'British',
            'Cajun',
            'Caribbean',
            'Chinese',
            'Eastern European',
            'European',
            'French',
            'German',
            'Greek',
            'Indian',
            'Irish',
            'Italian',
            'Japanese',
            'Jewish',
            'Korean',
            'Latin American',
            'Mediterranean',
            'Mexican',
            'Middle Eastern',
            'Nordic',
            'Southern',
            'Spanish',
            'Thai',
            'Vietnamese',
          ]),
          _buildDropdown('Diet', 'diet', [
            'Gluten Free',
            'Ketogenic',
            'Vegetarian',
            'Lacto-Vegetarian',
            'Ovo-Vegetarian',
            'Vegan',
            'Pescetarian',
            'Paleo',
            'Primal',
            'Low FODMAP',
            'Whole30',
          ]),
          _buildDropdown('Intolerances', 'intolerances', [
            'Dairy',
            'Egg',
            'Gluten',
            'Grain',
            'Peanut',
            'Seafood',
            'Sesame',
            'Shellfish',
            'Soy',
            'Sulfite',
            'Tree Nut',
            'Wheat',
          ]),
          _buildTextField('Equipment', 'equipment'),

          // Use the Include Ingredients TextField with Add Button
          _buildTextFieldWithAddButton(
            'Ingredients you have',
            'includeIngredients',
          ),
          const SizedBox(height: 16),

          _buildTextField('Exclude these ingredients', 'excludeIngredients'),
          _buildDropdown('Type', 'type', [
            'Main Course',
            'Side Dish',
            'Dessert',
            'Appetizer',
            'Salad',
            'Bread',
            'Breakfast',
            'Soup',
            'Beverage',
            'Sauce',
            'Marinade',
            'Fingerfood',
            'Snack',
            'Drink',
          ]),
          _buildNumberField('Min Calories', 'minCalories'),
          _buildNumberField('Max Calories', 'maxCalories'),
          _buildNumberField('Min Carbs', 'minCarbs'),
          _buildNumberField('Max Carbs', 'maxCarbs'),
          _buildNumberField('Min Protein', 'minProtein'),
          _buildNumberField('Max Protein', 'maxProtein'),
          _buildNumberField('Min Fat', 'minFat'),
          _buildNumberField('Max Fat', 'maxFat'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF657D5D),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDE8E3F),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _showSaveFilterDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF657D5D),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Filter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithAddButton(String label, String key) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
                controller: _controllers[key],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () => _scanBarcode(key),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                final ingredient = _controllers[key]?.text.trim() ?? '';
                if (ingredient.isNotEmpty) {
                  print('Button pressed with ingredient: $ingredient');
                  _addIngredient(ingredient);
                }
              },
            ),
          ],
        ),
      ),
      // Display added ingredients as Chips
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _includeIngredientsList.map((ingredient) {
            return Chip(
              label: Text(ingredient),
              onDeleted: () => _removeIngredient(ingredient),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

  Widget _buildTextField(String label, String key) {
    if (key == 'excludeIngredients') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
                controller: _controllers[key],
                onChanged: (value) {
                  _filters[key] = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () => _scanBarcode(key),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: _controllers[key],
        onChanged: (value) {
          _filters[key] = value;
        },
      ),
    );
  }

  Widget _buildNumberField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        controller: _controllers[key],
        onChanged: (value) {
          _filters[key] = double.tryParse(value) ?? 0;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String key, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: _filters[key],
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _filters[key] = value;
          });
        },
      ),
    );
  }

  Future<void> _scanBarcode(String key) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (result != null) {
      final productName = await ApiService.fetchProductNameByUPC(result);
      if (productName != null) {
        setState(() {
          if (key == 'includeIngredients') {
            _addIngredient(productName);
          } else {
            _controllers[key]?.text = productName;
            _filters[key] = productName;
          }
        });
      } else {
        // Handle the case where the product name could not be fetched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    }
  }

  Future<void> _showSaveFilterDialog() async {
    final nameController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Filter'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Filter Name',
              hintText: 'Enter a name for this filter',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _saveFilter(nameController.text);
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filter "${nameController.text}" saved'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveFilter(String name) async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? savedFiltersJson = prefs.getString('saved_filters');
    final List<Map<String, dynamic>> savedFilters = savedFiltersJson != null 
      ? List<Map<String, dynamic>>.from(jsonDecode(savedFiltersJson))
      : [];
    
    final Map<String, dynamic> filtersToSave = Map<String, dynamic>.from(_filters);
    
    filtersToSave['includeIngredients'] = _includeIngredientsList.toList();
    
    final newFilter = SavedFilter(
      name: name,
      filters: filtersToSave,
    );
    
    savedFilters.add(newFilter.toJson());
    
    await prefs.setString('saved_filters', jsonEncode(savedFilters));
  }
}