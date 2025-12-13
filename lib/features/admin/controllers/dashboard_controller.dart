// dashboard_controller.dart
import 'package:get/get.dart';

import '../../../data/repositories/dashboard/dashboard_repository.dart';

class DashboardController extends GetxController {
  final _dashboardRepo = Get.put(DashboardRepository());

  // Observables for stats
  final RxInt totalUsers = 0.obs;
  final RxDouble totalWeightRecycled = 0.0.obs;
  final RxInt activeCenters = 0.obs;
  final RxInt totalPointsIssued = 0.obs;

  // Trends
  final RxString userTrend = '+0%'.obs;
  final RxString weightTrend = '+0%'.obs;
  final RxString centerTrend = '+0'.obs;
  final RxString pointsTrend = '+0%'.obs;

  // 🆕 Chart data - 改为直接用 Rx 包装，不用 RxMap
  final Rx<Map<String, double>> recyclingTrend = Rx<Map<String, double>>({});
  final Rx<Map<String, double>> wasteCategoryDistribution = Rx<Map<String, double>>({});
  final Rx<Map<String, int>> userGrowth = Rx<Map<String, int>>({});
  final Rx<List<Map<String, dynamic>>> topCenters = Rx<List<Map<String, dynamic>>>([]);

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _setupStreams();
    _calculateTrends();
  }

  /// Setup all data streams
  void _setupStreams() {
    // Total users stream
    _dashboardRepo.getTotalUsersStream().listen((count) {
      totalUsers.value = count;
    });

    // Total weight recycled stream
    _dashboardRepo.getTotalWeightRecycledStream().listen((weight) {
      totalWeightRecycled.value = weight;
      isLoading.value = false;
    });

    // Active centers stream
    _dashboardRepo.getActiveCentersStream().listen((count) {
      activeCenters.value = count;
    });

    // Total points issued stream
    _dashboardRepo.getTotalPointsIssuedStream().listen((points) {
      totalPointsIssued.value = points;
    });

    // 🆕 Recycling trend stream - 更新整个对象
    _dashboardRepo.getRecyclingTrendStream().listen((data) {
      recyclingTrend.value = Map<String, double>.from(data);
    });

    // 🆕 Waste category distribution stream
    _dashboardRepo.getWasteCategoryDistributionStream().listen((data) {
      wasteCategoryDistribution.value = Map<String, double>.from(data);
    });

    // 🆕 User growth stream
    _dashboardRepo.getUserGrowthStream().listen((data) {
      userGrowth.value = Map<String, int>.from(data);
    });

    // 🆕 Top centers stream
    _dashboardRepo.getTopCentersStream().listen((data) {
      topCenters.value = List<Map<String, dynamic>>.from(data);
    });
  }

  /// Calculate trends compared to previous month
  Future<void> _calculateTrends() async {
    try {
      final prevStats = await _dashboardRepo.getPreviousMonthStats();
      final prevUsers = prevStats['prevUsers'] as int;
      final prevWeight = prevStats['prevWeight'] as double;

      // Calculate user trend
      if (prevUsers > 0) {
        final userGrowthPercent = ((totalUsers.value - prevUsers) / prevUsers * 100);
        userTrend.value = '${userGrowthPercent >= 0 ? '+' : ''}${userGrowthPercent.toStringAsFixed(1)}%';
      }

      // Calculate weight trend
      if (prevWeight > 0) {
        final weightGrowthPercent = ((totalWeightRecycled.value - prevWeight) / prevWeight * 100);
        weightTrend.value = '${weightGrowthPercent >= 0 ? '+' : ''}${weightGrowthPercent.toStringAsFixed(1)}%';
      }
    } catch (e) {
      print('Error calculating trends: $e');
    }
  }

  /// Format large numbers
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Get waste category name
  String getCategoryName(String categoryId) {
    final categoryMap = {
      'paper': 'Paper',
      'plastic': 'Plastic',
      'glass': 'Glass',
      'aluminium': 'Aluminium',
      'ewaste': 'E-waste',
    };
    return categoryMap[categoryId.toLowerCase()] ?? categoryId;
  }
}
