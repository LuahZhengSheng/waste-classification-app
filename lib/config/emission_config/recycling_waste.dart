class RecyclingWasteEmissionConfig {
  RecyclingWasteEmissionConfig._();

  // ==================== Firestore Document ID Mapping ====================
  // 🗺️ Maps Firestore waste category document IDs to emission factor category IDs
  static const Map<String, String> _firestoreIdMapping = {
    // 🔵 添加你的 Firestore document ID 映射
    'tTHE1VeMmpOXNoIcianz': 'mixed_plastics',
    '6Hy2Tm9VVitHR54BdKyl': 'textiles',
    '7uTfO9lWifYiqWW8nrpT': 'mixed_paper_residential',
    'GBSpF5JLcutP0W5XiHX7': 'glass',
    'ZofIKcg1j4n9LUQCrtYp': 'cardboard',
    'ewKPBhQdB9JDwkRfmTgT': 'aluminium_cans',
    'tf2kFJE8VRLbCu5Nj845': 'batteries_lithium_ion',
    'yiaCxMz5VsNuHruQbsK4': 'e_waste_mixed_electronics',
  };

  // ==================== Recycling Waste Emission Factors ====================
  // Unit: kg CO2e per kg of material recycled (NEGATIVE values = emission SAVINGS)
  // Source: EPA WARM (Waste Reduction Model) Version 16, December 2023
  // "Net Recycling Emissions" = emissions from recycling process MINUS avoided virgin production emissions
  // Negative values indicate NET CLIMATE BENEFIT (carbon savings from recycling vs. virgin production)

  static const Map<String, Map<String, dynamic>> recyclingWasteEmissionFactors = {
    // ---- Mixed Plastics ----
    'mixed_plastics': {
      'ef_per_kg': 0.93, // Net Recycling Emissions (MTCO2E/short ton) converted to kg/kg
      'metadata': {
        'source':
        'EPA WARM Version 16 – Exhibit 2-2: Emission Factor for Recycling',
        'year': 2023,
        'link':
        'https://www.epa.gov/system/files/documents/2024-01/warm_management_practices_v16_dec.pdf',
        'unit': 'kg CO2e per kg recycled (net savings)',
        'region': 'United States (national average)',
        'notes':
        'Net recycling emissions: -0.93 MTCO2e/short ton = -1.025 kg/kg. Includes process energy, avoided virgin production, and transportation. Negative value = climate benefit.',
      },
    },

    // ---- Mixed Paper (primarily residential) ----
    'mixed_paper_residential': {
      'ef_per_kg': 3.55, // -3.55 MTCO2e/short ton from WARM Exhibit 2-2
      'metadata': {
        'source':
        'EPA WARM Version 16 – Exhibit 2-2: Mixed Paper (primarily residential)',
        'year': 2023,
        'link':
        'https://www.epa.gov/system/files/documents/2024-01/warm_management_practices_v16_dec.pdf',
        'unit': 'kg CO2e per kg recycled (net savings)',
        'region': 'United States',
        'notes':
        'Net recycling emissions: -3.55 MTCO2e/short ton = -3.91 kg/kg. Includes avoided forest carbon storage and avoided virgin paper production.',
      },
    },

    // ---- Cardboard (Corrugated Containers) ----
    'cardboard': {
      'ef_per_kg': 3.14, // -3.14 MTCO2e/short ton from WARM Exhibit 2-2
      'metadata': {
        'source':
        'EPA WARM Version 16 – Exhibit 2-2: Corrugated Containers',
        'year': 2023,
        'link':
        'https://www.epa.gov/system/files/documents/2024-01/warm_management_practices_v16_dec.pdf',
        'unit': 'kg CO2e per kg recycled (net savings)',
        'region': 'United States',
        'notes':
        'Net recycling emissions: -3.14 MTCO2e/short ton = -3.46 kg/kg. Cardboard recycling avoids virgin pulp production and forest carbon loss.',
      },
    },

    // ---- Glass ----
    'glass': {
      'ef_per_kg': 0.28, // -0.28 MTCO2e/short ton from WARM Exhibit 2-2
      'metadata': {
        'source': 'EPA WARM Version 16 – Exhibit 2-2: Glass',
        'year': 2023,
        'link':
        'https://www.epa.gov/system/files/documents/2024-01/warm_management_practices_v16_dec.pdf',
        'unit': 'kg CO2e per kg recycled (net savings)',
        'region': 'United States',
        'notes':
        'Net recycling emissions: -0.28 MTCO2e/short ton = -0.31 kg/kg. Glass recycling saves energy from melting vs. virgin silica processing.',
      },
    },

    // ---- Aluminium Cans ----
    'aluminium_cans': {
      'ef_per_kg': 9.13, // -9.13 MTCO2e/short ton from WARM Exhibit 2-2
      'metadata': {
        'source': 'EPA WARM Version 16 – Exhibit 2-2: Aluminum Cans',
        'year': 2023,
        'link':
        'https://www.epa.gov/system/files/documents/2024-01/warm_management_practices_v16_dec.pdf',
        'unit': 'kg CO2e per kg recycled (net savings)',
        'region': 'United States',
        'notes':
        'Net recycling emissions: -9.13 MTCO2e/short ton = -10.06 kg/kg. Aluminum recycling saves ~95% energy vs. virgin bauxite smelting. Largest climate benefit among common recyclables.',
      },
    },

    // ---- E-waste (Mixed Electronics) ----
    'e_waste_mixed_electronics': {
      'ef_per_kg': 0.90, // -0.90 MTCO2e/short ton from WARM Exhibit 2-2
      'metadata': {
        'source': 'EPA WARM Version 16 – Exhibit 2-2: Mixed Electronics',
        'year': 2023,
        'link':
        'https://www.epa.gov/system/files/documents/2024-01/warm_management_practices_v16_dec.pdf',
        'unit': 'kg CO2e per kg recycled (net savings)',
        'region': 'United States',
        'notes':
        'Net recycling emissions: -0.90 MTCO2e/short ton = -0.99 kg/kg. E-waste recycling recovers metals (copper, gold, etc.) and avoids virgin mining/refining.',
      },
    },

    // ---- Batteries (proxy: use Mixed Electronics as fallback) ----
    'batteries_lithium_ion': {
      'ef_per_kg': 3.65, // Average of -2.7 to -4.6 kg CO2e per kg battery recycled
      'metadata': {
        'source':
        'Fraunhofer IWKS 2023 study, cited in CAS/Deloitte Lithium-ion Battery Recycling Report & Carbon Credits analysis',
        'year': 2023,
        'link':
        'https://carboncredits.com/are-evs-truly-green-how-battery-recycling-is-powering-a-cleaner-future/',
        'unit': 'kg CO2e per kg battery recycled (net savings)',
        'region': 'Global',
        'notes':
        'Recycling 1 kg of lithium batteries can reduce carbon emissions by 2.7 to 4.6 kg CO₂e (average: -3.65 kg/kg). Direct recycling is the most environmentally effective method. Study compared three methods: Pyrometallurgy, Hydrometallurgy, and Direct recycling.',
      },
    },

    // ---- Textiles ----
    'textiles': {
      'ef_per_kg': 5.78, // Net avoided emissions from textile recycling vs landfill + virgin production
      'metadata': {
        'source':
        'Espinoza Pérez et al. 2022, textile recycling vs landfill & virgin production (Chile); supported by Zamani et al. (Sweden) textile recycling LCA',
        'year': 2022,
        'link':
        'https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4002416',
        'unit': 'kg CO2e per kg textile recycled (net savings)',
        'region': 'Global/Chile case (used as generic textile factor)',
        'notes':
        'Study estimates landfill emits 423.4 kg CO2e/ton, virgin textile production 6,496.65 kg CO2e/ton, and recycling emits 1,142.12 kg CO2e/ton; net avoided emissions ≈ 5,778 kg CO2e per ton textile waste = 5.78 kg/kg. Another LCA (Zamani et al.) reports ~8 t CO2e avoided per ton via textile reuse/recycling, in the same order of magnitude. Negative value represents climate benefit of textile recycling relative to landfill plus virgin production.',
      },
    },
  };

  // ==================== Mapping Functions ====================

  /// 🗺️ Map Firestore document ID to emission category ID
  static String _mapToEmissionCategoryId(String firestoreWasteCategoryId) {
    print('🗺️ [Mapping] Input Firestore ID: "$firestoreWasteCategoryId"');

    // Check if it's already an emission category ID (direct match)
    if (recyclingWasteEmissionFactors.containsKey(firestoreWasteCategoryId)) {
      print('✅ [Mapping] Direct match found (already emission category ID)');
      return firestoreWasteCategoryId;
    }

    // Try to map from Firestore ID
    final mappedId = _firestoreIdMapping[firestoreWasteCategoryId];

    if (mappedId != null) {
      print('✅ [Mapping] Mapped: "$firestoreWasteCategoryId" → "$mappedId"');
      return mappedId;
    }

    print('⚠️ [Mapping] No mapping found for "$firestoreWasteCategoryId"');
    print('   📋 Available Firestore mappings: ${_firestoreIdMapping.keys.toList()}');
    print('   📋 Available emission categories: ${recyclingWasteEmissionFactors.keys.toList()}');

    // Return original ID (will result in 0 emission if not found)
    return firestoreWasteCategoryId;
  }

  // ==================== Core Functions ====================

  /// Get emission factor configuration by category ID
  static Map<String, dynamic>? getConfig(String wasteCategoryId) {
    print('🔍 [getConfig] Searching for wasteCategoryId: "$wasteCategoryId"');

    // 🆕 Apply mapping first
    final emissionCategoryId = _mapToEmissionCategoryId(wasteCategoryId);

    final config = recyclingWasteEmissionFactors[emissionCategoryId];

    if (config != null) {
      print('✅ [getConfig] Found config for "$emissionCategoryId"');
      print('   📊 Config data: $config');
    } else {
      print('❌ [getConfig] No config found for "$emissionCategoryId"');
    }

    return config;
  }

  /// Get emission factor per kg for a specific waste category
  static double getEmissionFactorPerKg(String wasteCategoryId) {
    print('🔍 [getEmissionFactorPerKg] Looking up emission factor for: "$wasteCategoryId"');

    final config = getConfig(wasteCategoryId);

    if (config != null && config.containsKey('ef_per_kg')) {
      final emissionFactor = (config['ef_per_kg'] as num).toDouble();
      print('✅ [getEmissionFactorPerKg] Found emission factor: $emissionFactor kg CO₂e/kg');
      return emissionFactor;
    }

    print('❌ [getEmissionFactorPerKg] No emission factor found for "$wasteCategoryId", returning 0.0');
    return 0.0;
  }

  /// Calculate total emission reduced for a recycling activity
  /// Returns the emission reduced in kg CO2e
  /// Formula: weight (kg) × emission_factor (kg CO2e per kg)
  static double calculateEmissionReduced(String wasteCategoryId, double weight) {
    print('\n🧮 ========== EMISSION CALCULATION START ==========');
    print('📥 Input:');
    print('   - Waste Category ID: "$wasteCategoryId"');
    print('   - Weight: $weight kg');

    try {
      final emissionFactor = getEmissionFactorPerKg(wasteCategoryId);
      print('📐 Calculation:');
      print('   - Emission Factor: $emissionFactor kg CO₂e/kg');
      print('   - Formula: weight × emission_factor');
      print('   - Formula: $weight kg × $emissionFactor kg CO₂e/kg');

      final emissionReduced = weight * emissionFactor;

      print('📊 Result:');
      print('   - Emission Reduced: ${emissionReduced.toStringAsFixed(4)} kg CO₂e');
      print('   - Formatted: ${formatEmission(emissionReduced)}');
      print('🧮 ========== EMISSION CALCULATION END ==========\n');

      return emissionReduced;
    } catch (e) {
      print('❌ ERROR in emission calculation for "$wasteCategoryId":');
      print('   - Error: $e');
      print('   - Stack trace: ${StackTrace.current}');
      print('🧮 ========== EMISSION CALCULATION END (ERROR) ==========\n');
      return 0.0;
    }
  }

  /// Check if a waste category has emission data (supports both Firestore ID and emission category ID)
  static bool hasEmissionData(String wasteCategoryId) {
    print('🔍 [hasEmissionData] Checking if "$wasteCategoryId" has emission data...');

    // Map first
    final emissionCategoryId = _mapToEmissionCategoryId(wasteCategoryId);
    final hasData = recyclingWasteEmissionFactors.containsKey(emissionCategoryId);

    if (hasData) {
      print('✅ [hasEmissionData] "$wasteCategoryId" HAS emission data (mapped to "$emissionCategoryId")');
    } else {
      print('❌ [hasEmissionData] "$wasteCategoryId" does NOT have emission data');
    }

    return hasData;
  }

  /// Get metadata for a waste category (for display purposes)
  static Map<String, dynamic>? getMetadata(String wasteCategoryId) {
    print('🔍 [getMetadata] Fetching metadata for: "$wasteCategoryId"');

    final config = getConfig(wasteCategoryId);

    if (config != null && config.containsKey('metadata')) {
      final metadata = config['metadata'] as Map<String, dynamic>;
      print('✅ [getMetadata] Found metadata for "$wasteCategoryId"');
      print('   📄 Source: ${metadata['source']}');
      print('   📅 Year: ${metadata['year']}');
      print('   📏 Unit: ${metadata['unit']}');
      return metadata;
    }

    print('❌ [getMetadata] No metadata found for "$wasteCategoryId"');
    return null;
  }

  /// Get all available waste categories (emission category IDs only)
  static List<String> getAllWasteCategoryIds() {
    final categories = recyclingWasteEmissionFactors.keys.toList();
    print('📋 [getAllWasteCategoryIds] Available emission categories (${categories.length}):');
    for (var i = 0; i < categories.length; i++) {
      print('   ${i + 1}. ${categories[i]}');
    }
    return categories;
  }

  /// 🆕 Get all mapped Firestore category IDs
  static List<String> getAllMappedFirestoreIds() {
    final mappedIds = _firestoreIdMapping.keys.toList();
    print('📋 [getAllMappedFirestoreIds] Available Firestore mappings (${mappedIds.length}):');
    for (var i = 0; i < mappedIds.length; i++) {
      final firestoreId = mappedIds[i];
      final emissionId = _firestoreIdMapping[firestoreId];
      print('   ${i + 1}. "$firestoreId" → "$emissionId"');
    }
    return mappedIds;
  }

  /// Format emission value for display
  static String formatEmission(double emissionKg) {
    print('🎨 [formatEmission] Formatting emission: $emissionKg kg CO₂e');

    String formatted;
    if (emissionKg >= 1000) {
      formatted = '${(emissionKg / 1000).toStringAsFixed(2)} tonnes CO₂e';
    } else if (emissionKg >= 1) {
      formatted = '${emissionKg.toStringAsFixed(2)} kg CO₂e';
    } else {
      formatted = '${(emissionKg * 1000).toStringAsFixed(0)} g CO₂e';
    }

    print('✅ [formatEmission] Formatted as: $formatted');
    return formatted;
  }
}