import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../utils/constants/colors.dart';

class AdminDashboardController extends GetxController {
  static AdminDashboardController get instance => Get.find();

  // Observable variables for dashboard data
  final _isLoading = false.obs;
  final _totalUsers = 0.obs;
  final _totalEvents = 0.obs;
  final _totalPosts = 0.obs;
  final _activeUsers = 0.obs;
  final _registeredEvents = 0.obs;
  final _monthlyGrowth = 0.0.obs;

  // Chart data - Fixed initialization
  final RxList<FlSpot> _userGrowthData = <FlSpot>[].obs;
  final RxList<PieChartSectionData> _eventParticipationData = <PieChartSectionData>[].obs;
  final RxList<FlSpot> _monthlyActivityData = <FlSpot>[].obs;

  // Recent activity data - Fixed initialization
  final RxList<Map<String, dynamic>> _recentUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _recentEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _recentPosts = <Map<String, dynamic>>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  int get totalUsers => _totalUsers.value;
  int get totalEvents => _totalEvents.value;
  int get totalPosts => _totalPosts.value;
  int get activeUsers => _activeUsers.value;
  int get registeredEvents => _registeredEvents.value;
  double get monthlyGrowth => _monthlyGrowth.value;

  RxList<FlSpot> get userGrowthData => _userGrowthData;
  RxList<PieChartSectionData> get eventParticipationData => _eventParticipationData;
  RxList<FlSpot> get monthlyActivityData => _monthlyActivityData;

  RxList<Map<String, dynamic>> get recentUsers => _recentUsers;
  RxList<Map<String, dynamic>> get recentEvents => _recentEvents;
  RxList<Map<String, dynamic>> get recentPosts => _recentPosts;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;

      await Future.wait([
        _loadStatistics(),
        _loadChartData(),
        _loadRecentActivity(),
      ]);
    } catch (e) {
      // Handle error - could use your FLoaders here
      print('Error loading dashboard data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load basic statistics
  Future<void> _loadStatistics() async {
    // Simulate API call - replace with actual Firebase queries
    await Future.delayed(const Duration(milliseconds: 500));

    _totalUsers.value = 1250;
    _totalEvents.value = 45;
    _totalPosts.value = 320;
    _activeUsers.value = 890;
    _registeredEvents.value = 230;
    _monthlyGrowth.value = 15.3;
  }

  /// Load chart data
  Future<void> _loadChartData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // User growth data (last 7 days) - Fixed initialization
    _userGrowthData.assignAll([
      const FlSpot(0, 100),
      const FlSpot(1, 120),
      const FlSpot(2, 140),
      const FlSpot(3, 160),
      const FlSpot(4, 180),
      const FlSpot(5, 200),
      const FlSpot(6, 220),
    ]);

    // Event participation pie chart data - Fixed initialization
    _eventParticipationData.assignAll([
      PieChartSectionData(
        color: FColors.adminLightPrimary,
        value: 40,
        title: 'Registered',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: FColors.adminLightSecondary,
        value: 30,
        title: 'Attended',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: FColors.adminLightWarning,
        value: 20,
        title: 'No Show',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: FColors.adminLightError,
        value: 10,
        title: 'Cancelled',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ]);

    // Monthly activity data - Fixed initialization
    _monthlyActivityData.assignAll([
      const FlSpot(1, 30),
      const FlSpot(2, 50),
      const FlSpot(3, 40),
      const FlSpot(4, 70),
      const FlSpot(5, 60),
      const FlSpot(6, 80),
      const FlSpot(7, 90),
      const FlSpot(8, 85),
      const FlSpot(9, 100),
      const FlSpot(10, 110),
      const FlSpot(11, 95),
      const FlSpot(12, 120),
    ]);
  }

  /// Load recent activity data
  Future<void> _loadRecentActivity() async {
    await Future.delayed(const Duration(milliseconds: 200));

    _recentUsers.assignAll([
      {'name': 'John Doe', 'email': 'john@example.com', 'joinDate': '2024-01-15', 'status': 'Active'},
      {'name': 'Jane Smith', 'email': 'jane@example.com', 'joinDate': '2024-01-14', 'status': 'Active'},
      {'name': 'Bob Johnson', 'email': 'bob@example.com', 'joinDate': '2024-01-13', 'status': 'Inactive'},
      {'name': 'Alice Brown', 'email': 'alice@example.com', 'joinDate': '2024-01-12', 'status': 'Active'},
      {'name': 'Charlie Wilson', 'email': 'charlie@example.com', 'joinDate': '2024-01-11', 'status': 'Active'},
    ]);

    _recentEvents.assignAll([
      {'title': 'Beach Cleanup Drive', 'date': '2024-01-20', 'participants': 45, 'status': 'Upcoming'},
      {'title': 'Recycling Workshop', 'date': '2024-01-18', 'participants': 32, 'status': 'Completed'},
      {'title': 'Tree Planting Event', 'date': '2024-01-15', 'participants': 28, 'status': 'Completed'},
      {'title': 'Waste Sorting Training', 'date': '2024-01-22', 'participants': 15, 'status': 'Upcoming'},
    ]);

    _recentPosts.assignAll([
      {'title': 'How to Reduce Plastic Waste', 'author': 'Sarah Connor', 'likes': 124, 'comments': 23, 'date': '2024-01-15'},
      {'title': 'DIY Compost Bin Tutorial', 'author': 'Mike Johnson', 'likes': 98, 'comments': 17, 'date': '2024-01-14'},
      {'title': 'Top 10 Eco-Friendly Products', 'author': 'Emma Davis', 'likes': 156, 'comments': 31, 'date': '2024-01-13'},
      {'title': 'Ocean Conservation Tips', 'author': 'David Lee', 'likes': 87, 'comments': 12, 'date': '2024-01-12'},
    ]);
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Get statistics card data
  List<Map<String, dynamic>> getStatisticsCards() {
    return [
      {
        'title': 'Total Users',
        'value': totalUsers.toString(),
        'change': '+${monthlyGrowth.toStringAsFixed(1)}%',
        'isPositive': true,
        'icon': 'users',
        'color': FColors.adminLightPrimary,
      },
      {
        'title': 'Active Users',
        'value': activeUsers.toString(),
        'change': '+12.5%',
        'isPositive': true,
        'icon': 'user_check',
        'color': FColors.adminLightSecondary,
      },
      {
        'title': 'Total Events',
        'value': totalEvents.toString(),
        'change': '+8.3%',
        'isPositive': true,
        'icon': 'calendar',
        'color': FColors.adminLightInfo,
      },
      {
        'title': 'Community Posts',
        'value': totalPosts.toString(),
        'change': '+18.7%',
        'isPositive': true,
        'icon': 'message',
        'color': FColors.adminLightWarning,
      },
    ];
  }

  /// Calculate user engagement rate
  double get userEngagementRate {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  /// Get quick actions for admin
  List<Map<String, dynamic>> getQuickActions() {
    return [
      {'title': 'Add New Event', 'icon': 'calendar_plus', 'route': '/admin/events/create'},
      {'title': 'Manage Users', 'icon': 'users_manage', 'route': '/admin/users'},
      {'title': 'View Reports', 'icon': 'chart', 'route': '/admin/reports'},
      {'title': 'System Settings', 'icon': 'settings', 'route': '/admin/settings'},
    ];
  }
}