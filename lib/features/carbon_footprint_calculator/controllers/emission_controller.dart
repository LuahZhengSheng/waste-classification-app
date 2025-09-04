import 'dart:ui';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission_profile/emission_profile.dart';
import 'package:get/get.dart';

class EmissionsController extends GetxController {
  final hasCalculatedEmissions = false.obs;
  final userEmissions = <String, double>{}.obs;
  final avgEmissions = <String, double>{
    'Land Travel': 1.2,
    'Air Travel': 1.8,
    'Energy': 1.5,
    'Food': 1.3,
    'Stuff': 1.4,
  }.obs;
  final comparisonPercentage = 30.0.obs;
  final showTooltipOverlay = false.obs;
  final tooltipPosition = Offset.zero.obs;
  final tooltipData = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadEmissionsData();
  }

  void loadEmissionsData() {
    // Load user's emissions data from local storage or Firebase
    final emissions = {
      'Land Travel': 3.12,
      'Air Travel': 5.15,
      'Energy': 2.50,
      'Food': 3.52,
      'Stuff': 7.15,
    };

    if (emissions.isNotEmpty) {
      userEmissions.value = emissions;
      hasCalculatedEmissions.value = true;
      calculateComparison();
    }
  }

  void calculateComparison() {
    final userTotal = userEmissions.values.fold(0.0, (sum, value) => sum + value);
    final avgTotal = avgEmissions.values.fold(0.0, (sum, value) => sum + value);

    if (avgTotal > 0) {
      comparisonPercentage.value = ((userTotal - avgTotal) / avgTotal) * 100;
    }
  }

  void showTooltip(Offset position, Map<String, double> data) {
    tooltipPosition.value = position;
    tooltipData.value = data;
    showTooltipOverlay.value = true;

    // Hide tooltip after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      showTooltipOverlay.value = false;
    });
  }

  void navigateToEmissionsProfile() {
    Get.to(() => const EmissionsProfileScreen());
  }
}