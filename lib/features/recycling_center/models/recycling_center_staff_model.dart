import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';

class RecyclingCenterStaff extends RoleModel {
  final String centerId;
  final String? gender;
  final DateTime joinDate;
  final DateTime? lastPasswordResetTime;

  RecyclingCenterStaff({
    required super.userId,
    required super.username,
    required super.email,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.isBanned,
    super.phoneNo,
    super.profileImg,
    required this.centerId,
    this.gender,
    required this.joinDate,
    this.lastPasswordResetTime,
  });

  /// 用于 UI 显示的性别（为空时显示 N/A）
  String get displayGender {
    if (gender == null || gender!.trim().isEmpty) {
      return 'N/A';
    }
    return gender!;
  }

  factory RecyclingCenterStaff.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    // 先用 RoleModel 处理通用字段（包括 phoneNo 的格式逻辑）
    final roleModel = RoleModel.fromSnapshot(doc);

    return RecyclingCenterStaff(
      // RoleModel fields
      userId: roleModel.userId,
      username: roleModel.username,
      email: roleModel.email,
      phoneNo: roleModel.phoneNo,
      profileImg: roleModel.profileImg,
      role: roleModel.role,
      isVerified: roleModel.isVerified,
      isActive: roleModel.isActive,
      isBanned: roleModel.isBanned,

      // RecyclingCenterStaff 自己的字段
      centerId: data['centerId'],
      gender: data['gender'],
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : DateTime.now(),
      lastPasswordResetTime: data['lastPasswordResetTime'] != null
          ? (data['lastPasswordResetTime'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // 先拿父类的 JSON（包含已格式化的 phoneNo）
    final baseJson = super.toJson();

    return {
      ...baseJson,
      'centerId': centerId,
      'gender': gender,
      'joinDate': Timestamp.fromDate(joinDate),
      'lastPasswordResetTime': lastPasswordResetTime != null
          ? Timestamp.fromDate(lastPasswordResetTime!)
          : null,
    };
  }

  @override
  RecyclingCenterStaff copyWith({
    String? centerId,
    String? gender,
    DateTime? joinDate,
    DateTime? lastPasswordResetTime,
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
    return RecyclingCenterStaff(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImg: profileImg ?? this.profileImg,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      centerId: centerId ?? this.centerId,
      gender: gender ?? this.gender,
      joinDate: joinDate ?? this.joinDate,
      lastPasswordResetTime:
      lastPasswordResetTime ?? this.lastPasswordResetTime,
    );
  }

  static RecyclingCenterStaff empty() => RecyclingCenterStaff(
    userId: '',
    username: '',
    email: '',
    role: '',
    isVerified: false,
    isActive: false,
    isBanned: false,
    centerId: '',
    joinDate: DateTime.now(),
  );

  /// Check if password reset link can be sent (10 minutes cooldown)
  bool canSendPasswordResetLink() {
    if (lastPasswordResetTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastPasswordResetTime!);
    return difference.inMinutes >= 10;
  }

  /// Get remaining time until next password reset link can be sent
  Duration? getRemainingResetCooldown() {
    if (lastPasswordResetTime == null) return null;

    final now = DateTime.now();
    final nextAvailableTime =
    lastPasswordResetTime!.add(const Duration(minutes: 10));

    if (now.isAfter(nextAvailableTime)) return null;

    return nextAvailableTime.difference(now);
  }

  /// Get formatted remaining time string
  String getFormattedRemainingResetTime() {
    final remaining = getRemainingResetCooldown();
    if (remaining == null) return '0m';

    if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m';
    } else {
      return '${remaining.inSeconds}s';
    }
  }
}
