import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';

class AdminModel extends RoleModel {
  final int loginAttemptCount;
  final DateTime? lastFailedLogin;
  final DateTime? lastPasswordResetTime;

  AdminModel({
    required super.userId,
    required super.username,
    required super.email,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.isBanned,
    super.phoneNo,
    super.profileImg,
    required this.loginAttemptCount,
    this.lastFailedLogin,
    this.lastPasswordResetTime,
  });

  factory AdminModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AdminModel(
      userId: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNo: data['phoneNo'],
      profileImg: data['profileImg'],
      role: data['role'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? false,
      isBanned: data['isBanned'] ?? false,
      loginAttemptCount: data['loginAttemptCount'] ?? 0,
      lastFailedLogin: data['lastFailedLogin'] != null
          ? (data['lastFailedLogin'] as Timestamp).toDate()
          : null,
      lastPasswordResetTime: data['lastPasswordResetTime'] != null
          ? (data['lastPasswordResetTime'] as Timestamp).toDate()
          : null,
    );
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phoneNo'],
      profileImg: map['profileImg'],
      role: map['role'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? false,
      isBanned: map['isBanned'] ?? false,
      loginAttemptCount: map['loginAttemptCount'] ?? 0,
      lastFailedLogin: map['lastFailedLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastFailedLogin'])
          : null,
      lastPasswordResetTime: map['lastPasswordResetTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastPasswordResetTime'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'phoneNo': phoneNo,
      'profileImg': profileImg,
      'loginAttemptCount': loginAttemptCount,
      'lastFailedLogin': lastFailedLogin != null ? Timestamp.fromDate(lastFailedLogin!) : null,
      'lastPasswordResetTime': lastPasswordResetTime != null ? Timestamp.fromDate(lastPasswordResetTime!) : null,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'isBanned': isBanned,
    };
  }

  @override
  AdminModel copyWith({
    int? loginAttemptCount,
    DateTime? lastFailedLogin,
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
    return AdminModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImg: profileImg ?? this.profileImg,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      loginAttemptCount: loginAttemptCount ?? this.loginAttemptCount,
      lastFailedLogin: lastFailedLogin ?? this.lastFailedLogin,
      lastPasswordResetTime: lastPasswordResetTime ?? this.lastPasswordResetTime,
    );
  }

  static AdminModel empty() => AdminModel(
    userId: '',
    username: '',
    email: '',
    role: '',
    isVerified: false,
    isActive: false,
    isBanned: false,
    loginAttemptCount: 0,
  );

  /// Check if account is currently blocked
  bool isCurrentlyBlocked() {
    if (lastFailedLogin == null || loginAttemptCount < 5) return false;

    final now = DateTime.now();
    final blockEndTime = lastFailedLogin!.add(const Duration(minutes: 10));

    return now.isBefore(blockEndTime);
  }

  /// Get remaining block time
  Duration? getRemainingBlockTime() {
    if (!isCurrentlyBlocked()) return null;

    final now = DateTime.now();
    final blockEndTime = lastFailedLogin!.add(const Duration(minutes: 10));

    return blockEndTime.difference(now);
  }

  /// Check if attempts should be reset (more than 5 minutes since last failed login)
  bool shouldResetAttempts() {
    if (lastFailedLogin == null) return false;

    final now = DateTime.now();
    final timeSinceLastFail = now.difference(lastFailedLogin!);

    return timeSinceLastFail.inMinutes >= 5;
  }

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
    final nextAvailableTime = lastPasswordResetTime!.add(const Duration(minutes: 10));

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