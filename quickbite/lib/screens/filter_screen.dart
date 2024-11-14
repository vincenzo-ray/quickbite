import 'package:flutter/material.dart';

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

  // initialize all filter boxes
  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
    _controllers['equipment'] =
        TextEditingController(text: _filters['equipment']);
    _controllers['includeIngredients'] =
        TextEditingController(text: _filters['includeIngredients']);
    _controllers['excludeIngredients'] =
        TextEditingController(text: _filters['excludeIngredients']);
    _controllers['minCalories'] =
        TextEditingController(text: _filters['minCalories']?.toString());
    _controllers['maxCalories'] =
        TextEditingController(text: _filters['maxCalories']?.toString());
    _controllers['minCarbs'] =
        TextEditingController(text: _filters['minCarbs']?.toString());
    _controllers['maxCarbs'] =
        TextEditingController(text: _filters['maxCarbs']?.toString());
    _controllers['minProtein'] =
        TextEditingController(text: _filters['minProtein']?.toString());
    _controllers['maxProtein'] =
        TextEditingController(text: _filters['maxProtein']?.toString());
    _controllers['minFat'] =
        TextEditingController(text: _filters['minFat']?.toString());
    _controllers['maxFat'] =
        TextEditingController(text: _filters['maxFat']?.toString());
  }

  // apply filters on button press
  void _applyFilters() {
    _filters['equipment'] = _controllers['equipment']?.text;
    _filters['includeIngredients'] = _controllers['includeIngredients']?.text;
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
    Navigator.pop(context); // close
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _filters.clear();
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

  // Box values
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Vietnamese'
              ]
          ),
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
                'Wheat'
              ]
          ),
          _buildTextField('Equipment', 'equipment'),
          _buildTextField('Include Ingredients', 'includeIngredients'),
          _buildTextField('Exclude Ingredients', 'excludeIngredients'),
          _buildDropdown(
              'Type', 'type', [
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
            'Drink'
          ]

          ),
          // number field for numbers only
          _buildNumberField('Min Calories', 'minCalories'),
          _buildNumberField('Max Calories', 'maxCalories'),
          _buildNumberField('Min Carbs', 'minCarbs'),
          _buildNumberField('Max Carbs', 'maxCarbs'),
          _buildNumberField('Min Protein', 'minProtein'),
          _buildNumberField('Max Protein', 'maxProtein'),
          _buildNumberField('Min Fat', 'minFat'),
          _buildNumberField('Max Fat', 'maxFat'),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
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
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
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
        ],
      ),
    );
  }

  // Text fields
  Widget _buildTextField(String label, String key) {
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

  // Number fields
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

  // Drop downs
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
}
