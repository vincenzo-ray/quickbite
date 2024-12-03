class SavedFilter {
  final String name;
  final Map<String, dynamic> filters;

  SavedFilter({
    required this.name,
    required this.filters,
  });

  // Convert to json
  Map<String, dynamic> toJson() => {
    'name': name,
    'filters': filters,
  };

  factory SavedFilter.fromJson(Map<String, dynamic> json) {
    return SavedFilter(
      name: json['name'] as String,
      filters: Map<String, dynamic>.from(json['filters'] as Map),
    );
  }
} 