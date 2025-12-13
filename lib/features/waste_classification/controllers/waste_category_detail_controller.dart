import 'package:get/get.dart';

import '../../../config/emission_config/recycling_waste.dart';

class WasteCategoryDetailController extends GetxController {
  final dynamic category;

  WasteCategoryDetailController(this.category);

  Map<String, dynamic>? get emissionConfig {
    final name = (category.name as String).trim();
    final map = RecyclingWasteEmissionConfig.recyclingWasteEmissionFactors;

    switch (name) {
      case 'Plastic':
        return map['mixed_plastics'];
      case 'Paper':
        return map['mixed_paper_residential'];
      case 'Glass':
        return map['glass'];
      case 'Aluminium':
        return map['aluminium_cans'];
      case 'Cardboard':
        return map['cardboard'];
      case 'Battery':
        return map['batteries_lithium_ion'];
      case 'Electronic Waste':
        return map['e_waste_mixed_electronics'];
      case 'Textile':
        return map['textiles'];
      default:
        return null;
    }
  }

  bool get hasEmission => emissionConfig != null;

  num? get efPerKg =>
      emissionConfig != null ? emissionConfig!['ef_per_kg'] as num : null;

  Map<String, dynamic>? get emissionMetadata =>
      emissionConfig != null
          ? emissionConfig!['metadata'] as Map<String, dynamic>
          : null;
}
