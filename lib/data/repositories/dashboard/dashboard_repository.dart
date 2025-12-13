import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardRepository extends GetxController {
  static DashboardRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get total users count stream
  Stream<int> getTotalUsersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get total weight recycled stream (from all activities)
  Stream<double> getTotalWeightRecycledStream() {
    return _db
        .collection('recyclingActivities')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final weight = doc.data()['weight'] as num?;
        total += weight?.toDouble() ?? 0.0;
      }
      return total;
    });
  }

  /// Get active recycling centers count stream
  Stream<int> getActiveCentersStream() {
    return _db
        .collection('recyclingCenters')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get total points issued stream (from all users)
  Stream<int> getTotalPointsIssuedStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final points = doc.data()['totalRewardPoint'] as num?;
        total += points?.toInt() ?? 0;
      }
      return total;
    });
  }

  /// Get recycling trend data (last 30 days)
  Stream<Map<String, double>> getRecyclingTrendStream() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return _db
        .collection('recyclingActivities')
        .where('status', isEqualTo: 'completed')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
        .snapshots()
        .map((snapshot) {
      Map<String, double> trendData = {};

      for (var doc in snapshot.docs) {
        final createdAt = (doc.data()['createdAt'] as Timestamp).toDate();
        final dateKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        final weight = doc.data()['weight'] as num?;

        trendData[dateKey] = (trendData[dateKey] ?? 0.0) + (weight?.toDouble() ?? 0.0);
      }

      return trendData;
    });
  }

  /// 🆕 Get waste category distribution with category names
  Stream<Map<String, double>> getWasteCategoryDistributionStream() {
    return _db
        .collection('recyclingActivities')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .asyncMap((snapshot) async {
      // First, group by category ID
      Map<String, double> distributionById = {};

      for (var doc in snapshot.docs) {
        final categoryId = doc.data()['wasteCategoryId'] as String?;
        final weight = doc.data()['weight'] as num?;

        if (categoryId != null) {
          distributionById[categoryId] = (distributionById[categoryId] ?? 0.0) + (weight?.toDouble() ?? 0.0);
        }
      }

      // Then, fetch category names and create final distribution
      Map<String, double> distributionByName = {};

      for (var entry in distributionById.entries) {
        try {
          final categoryDoc = await _db.collection('wasteCategories').doc(entry.key).get();

          if (categoryDoc.exists) {
            final categoryName = categoryDoc.data()?['name'] as String? ?? 'Unknown Category';
            distributionByName[categoryName] = entry.value;
          } else {
            // Fallback to default name mapping if document doesn't exist
            final fallbackName = _getCategoryNameFallback(entry.key);
            distributionByName[fallbackName] = entry.value;
          }
        } catch (e) {
          print('Error fetching category ${entry.key}: $e');
          // Use fallback name if error occurs
          final fallbackName = _getCategoryNameFallback(entry.key);
          distributionByName[fallbackName] = entry.value;
        }
      }

      return distributionByName;
    });
  }

  /// Fallback method to get category name from ID
  String _getCategoryNameFallback(String categoryId) {
    final categoryMap = {
      'paper': 'Paper',
      'plastic': 'Plastic',
      'glass': 'Glass',
      'aluminium': 'Aluminium',
      'ewaste': 'E-waste',
    };
    return categoryMap[categoryId.toLowerCase()] ?? categoryId;
  }

  /// Get user growth data (last 6 months)
  Stream<Map<String, int>> getUserGrowthStream() {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

    return _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
        .snapshots()
        .map((snapshot) {
      Map<String, int> growthData = {};

      for (var doc in snapshot.docs) {
        final createdAt = (doc.data()['createdAt'] as Timestamp).toDate();
        final monthKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';

        growthData[monthKey] = (growthData[monthKey] ?? 0) + 1;
      }

      return growthData;
    });
  }

  /// Get top recycling centers by activity count
  Stream<List<Map<String, dynamic>>> getTopCentersStream() {
    return _db
        .collection('recyclingActivities')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .asyncMap((snapshot) async {
      // Count activities per center staff
      Map<String, int> centerCounts = {};

      for (var doc in snapshot.docs) {
        final centerStaffId = doc.data()['centerStaffId'] as String?;
        if (centerStaffId != null) {
          centerCounts[centerStaffId] = (centerCounts[centerStaffId] ?? 0) + 1;
        }
      }

      // Get center names
      List<Map<String, dynamic>> centerData = [];

      for (var entry in centerCounts.entries) {
        try {
          final staffDoc = await _db.collection('users').doc(entry.key).get();
          final centerId = staffDoc.data()?['centerId'] as String?;

          if (centerId != null) {
            final centerDoc = await _db.collection('partnerRecyclingCenters').doc(centerId).get();
            final centerName = centerDoc.data()?['name'] as String? ?? 'Unknown';

            centerData.add({
              'centerName': centerName,
              'activityCount': entry.value,
            });
          }
        } catch (e) {
          print('Error fetching center data: $e');
        }
      }

      // Sort by activity count and take top 10
      centerData.sort((a, b) => (b['activityCount'] as int).compareTo(a['activityCount'] as int));
      return centerData.take(10).toList();
    });
  }

  /// Get previous month stats for comparison
  Future<Map<String, dynamic>> getPreviousMonthStats() async {
    final now = DateTime.now();
    final firstDayThisMonth = DateTime(now.year, now.month, 1);
    final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);

    try {
      // Previous month users
      final prevUsersSnapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'user')
          .where('createdAt', isLessThan: Timestamp.fromDate(firstDayThisMonth))
          .get();

      // Previous month weight
      final prevActivitiesSnapshot = await _db
          .collection('recyclingActivities')
          .where('status', isEqualTo: 'completed')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayLastMonth))
          .where('createdAt', isLessThan: Timestamp.fromDate(firstDayThisMonth))
          .get();

      double prevWeight = 0.0;
      for (var doc in prevActivitiesSnapshot.docs) {
        prevWeight += (doc.data()['weight'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'prevUsers': prevUsersSnapshot.docs.length,
        'prevWeight': prevWeight,
      };
    } catch (e) {
      print('Error getting previous month stats: $e');
      return {
        'prevUsers': 0,
        'prevWeight': 0.0,
      };
    }
  }
}
