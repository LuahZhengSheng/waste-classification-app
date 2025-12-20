import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';

class UserModel extends RoleModel {
  final String? gender;
  final DateTime? dob;
  final DateTime joinDate;
  final int rewardPoint; // 用户当前剩余积分（可消费）
  final int monthlyRewardPoint; // 月度累计积分（用于排行榜）
  final int totalRewardPoint; // 历史总积分（用于排行榜）
  final double totalWeightRecycled; // 总回收重量
  final int totalRecyclingActivities; // 总回收活动次数
  final double totalEmissionReduced; // 总减少的碳排放
  final List<NotificationModel> notifications;

  UserModel({
    // RoleModel fields
    required super.userId,
    required super.username,
    required super.email,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.isBanned,
    super.phoneNo,
    super.profileImg,

    // UserModel fields
    this.gender,
    this.dob,
    required this.joinDate,
    this.rewardPoint = 0,
    this.monthlyRewardPoint = 0,
    this.totalRewardPoint = 0,
    this.totalWeightRecycled = 0.0,
    this.totalRecyclingActivities = 0,
    this.totalEmissionReduced = 0.0,
    this.notifications = const [],
  });
  
  /// Firestore 转换
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // 先创建 RoleModel 来处理父类属性
    final roleModel = RoleModel.fromSnapshot(doc);

    return UserModel(
      // 使用 RoleModel 的属性（已经格式化好的）
      userId: roleModel.userId,
      username: roleModel.username,
      email: roleModel.email,
      phoneNo: roleModel.phoneNo, // 已经是国际格式
      profileImg: roleModel.profileImg,
      role: roleModel.role,
      isVerified: roleModel.isVerified,
      isActive: roleModel.isActive,
      isBanned: roleModel.isBanned,

      // UserModel 独有的属性
      gender: data['gender'],
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : DateTime.now(),
      rewardPoint: data['rewardPoint'] ?? 0,
      monthlyRewardPoint: data['monthlyRewardPoint'] ?? 0,
      totalRewardPoint: data['totalRewardPoint'] ?? 0,
      totalWeightRecycled: (data['totalWeightRecycled'] ?? 0.0).toDouble(),
      totalRecyclingActivities: data['totalRecyclingActivities'] ?? 0,
      totalEmissionReduced: (data['totalEmissionReduced'] ?? 0.0).toDouble(),
      notifications: data['notifications'] != null
          ? List<NotificationModel>.from(
          (data['notifications'] as List<dynamic>)
              .map((n) => NotificationModel.fromMap(n)))
          : [],
    );
  }

  /// 转 Firestore JSON
  @override
  Map<String, dynamic> toJson() {
    // 获取父类的 JSON（已经包含格式化的 phoneNo）
    final baseJson = super.toJson();

    // 添加 UserModel 独有的字段
    return {
      ...baseJson, // 包含所有父类字段（phoneNo 已经是 +60 格式）
      'gender': gender,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'joinDate': FieldValue.serverTimestamp(),
      'rewardPoint': rewardPoint,
      'monthlyRewardPoint': monthlyRewardPoint,
      'totalRewardPoint': totalRewardPoint,
      'totalWeightRecycled': totalWeightRecycled,
      'totalRecyclingActivities': totalRecyclingActivities,
      'totalEmissionReduced': totalEmissionReduced,
      'notifications': notifications.map((n) => n.toMap()).toList(),
    };
  }

  @override
  UserModel copyWith({
    String? gender,
    DateTime? dob,
    DateTime? joinDate,
    int? rewardPoint,
    int? monthlyRewardPoint,
    int? totalRewardPoint,
    double? totalWeightRecycled,
    int? totalRecyclingActivities,
    double? totalEmissionReduced,
    List<NotificationModel>? notifications,
    String? email,
    bool? isActive,
    bool? isVerified,
    bool? isBanned,
    String? phoneNo,
    String? profileImg,
    String? role,
    String? userId,
    String? username,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImg: profileImg ?? this.profileImg,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      joinDate: joinDate ?? this.joinDate,
      rewardPoint: rewardPoint ?? this.rewardPoint,
      monthlyRewardPoint: monthlyRewardPoint ?? this.monthlyRewardPoint,
      totalRewardPoint: totalRewardPoint ?? this.totalRewardPoint,
      totalWeightRecycled: totalWeightRecycled ?? this.totalWeightRecycled,
      totalRecyclingActivities: totalRecyclingActivities ?? this.totalRecyclingActivities,
      totalEmissionReduced: totalEmissionReduced ?? this.totalEmissionReduced,
      notifications: notifications ?? this.notifications,
    );
  }

  /// Empty User
  static UserModel empty() => UserModel(
    userId: '',
    username: '',
    email: '',
    role: '',
    isVerified: false,
    isActive: false,
    isBanned: false,
    joinDate: DateTime.now(),
    totalWeightRecycled: 0.0,
    totalRecyclingActivities: 0,
    totalEmissionReduced: 0.0,
  );


  /// 用于 UI 显示的性别（为空时显示 N/A）
  String get displayGender {
    if (gender == null || gender!.trim().isEmpty) {
      return 'N/A';
    }
    return gender!;
  }

  String get displayDob {
    if (dob == null) {
      return 'N/A';
    }

    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = dob!.day.toString(); // 不补 0，5 就显示 5
    final monthName = monthNames[dob!.month - 1];
    final year = dob!.year.toString();

    return '$day $monthName $year'; // e.g. 5 December 2025
  }

  /// 添加积分（当回收活动被批准时调用）
  UserModel addPoints(int points) {
    return copyWith(
      rewardPoint: rewardPoint + points,
      monthlyRewardPoint: monthlyRewardPoint + points,
      totalRewardPoint: totalRewardPoint + points,
    );
  }

  /// 添加回收活动统计（当回收活动完成时调用）
  UserModel addRecyclingActivity({
    required int points,
    required double weight,
    required double emission,
  }) {
    return copyWith(
      rewardPoint: rewardPoint + points,
      monthlyRewardPoint: monthlyRewardPoint + points,
      totalRewardPoint: totalRewardPoint + points,
      totalWeightRecycled: totalWeightRecycled + weight,
      totalRecyclingActivities: totalRecyclingActivities + 1,
      totalEmissionReduced: totalEmissionReduced + emission,
    );
  }

  /// 消费积分（当用户兑换奖励时调用）
  UserModel consumePoints(int points) {
    return copyWith(
      rewardPoint: rewardPoint - points,
    );
  }

  /// 重置月度积分（每月初调用）
  UserModel resetMonthlyPoints() {
    return copyWith(
      monthlyRewardPoint: 0,
    );
  }

  /// 获取当前月份（用于排行榜标识）
  String get currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// 获取积分统计信息
  Map<String, int> get pointsSummary {
    return {
      'current': rewardPoint,
      'monthly': monthlyRewardPoint,
      'total': totalRewardPoint,
    };
  }

  /// 获取回收统计信息
  Map<String, dynamic> get recyclingSummary {
    return {
      'totalWeight': totalWeightRecycled,
      'totalActivities': totalRecyclingActivities,
      'totalEmission': totalEmissionReduced,
      'avgWeightPerActivity': totalRecyclingActivities > 0
          ? totalWeightRecycled / totalRecyclingActivities
          : 0.0,
      'avgEmissionPerActivity': totalRecyclingActivities > 0
          ? totalEmissionReduced / totalRecyclingActivities
          : 0.0,
    };
  }

  /// 检查是否有足够积分消费
  bool canConsume(int points) => rewardPoint >= points;

  /// 格式化回收重量显示
  String get formattedWeight {
    if (totalWeightRecycled >= 1000) {
      return '${(totalWeightRecycled / 1000).toStringAsFixed(2)} tonnes';
    }
    return '${totalWeightRecycled.toStringAsFixed(2)} kg';
  }

  /// 格式化排放量显示
  String get formattedEmission {
    if (totalEmissionReduced >= 1000) {
      return '${(totalEmissionReduced / 1000).toStringAsFixed(2)} tonnes CO₂e';
    }
    return '${totalEmissionReduced.toStringAsFixed(2)} kg CO₂e';
  }
}
