import '../models/waste_category_model.dart';

class WasteDetectionMapper {
  // Map detected labels to category search criteria
  static Map<String, CategorySearchCriteria> labelMapping = {
    // Plastic - Recyclable
    'PET Bottle': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: true,
      keywords: ['PET', 'bottle'],
    ),
    'HDPE Plastic': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: true,
      keywords: ['HDPE'],
    ),
    'UHT-Box': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: true,
      keywords: ['UHT', 'carton'],
    ),
    'Single-layer Plastic': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: true,
      keywords: ['single-layer'],
    ),

    // Plastic - Not Recyclable
    'Multi-layer Plastic': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: false,
      keywords: ['multi-layer', 'composite'],
    ),
    'Single-Use Plastic': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: false,
      keywords: ['single-use', 'disposable'],
    ),
    'Squeeze Tube': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: false,
      keywords: ['tube', 'squeeze'],
    ),
    'Polystyrene': CategorySearchCriteria(
      categoryName: 'Plastic',
      isRecyclable: false,
      keywords: ['polystyrene', 'styrofoam', 'foam'],
    ),

    // Paper - Recyclable
    'Paper': CategorySearchCriteria(
      categoryName: 'Paper',
      isRecyclable: true,
      keywords: ['paper', 'newspaper'],
    ),

    // Paper - Not Recyclable
    'Paper Cup': CategorySearchCriteria(
      categoryName: 'Paper',
      isRecyclable: false,
      keywords: ['cup', 'composite'],
    ),

    // Glass - Recyclable
    'Glass Bottle': CategorySearchCriteria(
      categoryName: 'Glass',
      isRecyclable: true,
      keywords: ['bottle', 'jar'],
    ),

    // Glass - Not Recyclable
    'Light Bulb': CategorySearchCriteria(
      categoryName: 'Glass',
      isRecyclable: false,
      keywords: ['bulb', 'light'],
    ),
    'Fluorescent Lamp': CategorySearchCriteria(
      categoryName: 'Glass',
      isRecyclable: false,
      keywords: ['fluorescent', 'lamp', 'tube'],
    ),

    // Metal - Recyclable
    'Aluminium Can': CategorySearchCriteria(
      categoryName: 'Aluminium',
      isRecyclable: true,
      keywords: ['aluminium', 'aluminum', 'can'],
    ),

    // Cardboard - Recyclable
    'Cardboard': CategorySearchCriteria(
      categoryName: 'Cardboard',
      isRecyclable: true,
      keywords: ['cardboard', 'box'],
    ),

    // Battery - Not Recyclable (requires special handling)
    'Battery': CategorySearchCriteria(
      categoryName: 'Battery',
      isRecyclable: false,
      keywords: ['battery'],
    ),

    // E-waste - Recyclable (e-waste category)
    'Charger': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['charger', 'adapter'],
    ),
    'Smartphone': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['phone', 'smartphone', 'mobile'],
    ),
    'Laptop': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['laptop', 'computer'],
    ),
    'Monitor': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['monitor', 'screen', 'display'],
    ),
    'Printer': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['printer'],
    ),
    'Computer Mouse': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['mouse'],
    ),
    'Computer Keyboard': CategorySearchCriteria(
      categoryName: 'Electronic Waste',
      isRecyclable: true,
      keywords: ['keyboard'],
    ),
  };

  /// Find matching category from Firestore categories
  static WasteCategory? findMatchingCategory(
      String detectedLabel,
      List<WasteCategory> allCategories,
      ) {
    final criteria = labelMapping[detectedLabel];
    if (criteria == null) return null;

    // First, filter by recyclability
    final filteredByRecyclability = allCategories.where(
          (cat) => cat.isRecyclable == criteria.isRecyclable,
    ).toList();

    // Then search by category name and keywords
    for (final category in filteredByRecyclability) {
      // Check if category name matches
      if (category.name.toLowerCase().contains(
        criteria.categoryName.toLowerCase(),
      )) {
        // Check if any keyword matches in category name or examples
        for (final keyword in criteria.keywords) {
          final keywordLower = keyword.toLowerCase();

          // Check in category name
          if (category.name.toLowerCase().contains(keywordLower)) {
            return category;
          }

          // Check in examples
          for (final example in category.examples) {
            if (example.toLowerCase().contains(keywordLower)) {
              return category;
            }
          }

          // Check in description
          if (category.description.toLowerCase().contains(keywordLower)) {
            return category;
          }
        }
      }
    }

    // Fallback: return any category matching the base category name
    try {
      return filteredByRecyclability.firstWhere(
            (cat) => cat.name.toLowerCase().contains(
          criteria.categoryName.toLowerCase(),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}

class CategorySearchCriteria {
  final String categoryName;
  final bool isRecyclable;
  final List<String> keywords;

  CategorySearchCriteria({
    required this.categoryName,
    required this.isRecyclable,
    required this.keywords,
  });
}