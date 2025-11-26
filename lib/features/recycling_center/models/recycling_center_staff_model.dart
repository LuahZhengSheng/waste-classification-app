import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';

class RecyclingCenterStaff extends RoleModel {
  final String centerId;
  final String? gender;
  final DateTime joinDate;

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
  });

  factory RecyclingCenterStaff.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RecyclingCenterStaff(
      userId: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNo: data['phoneNo'],
      profileImg: data['profileImg'],
      role: data['role'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? false,
      isBanned: data['isBanned'] ?? false,
      centerId: data['centerId'],
      gender: data['gender'],
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory RecyclingCenterStaff.fromMap(Map<String, dynamic> map) {
    return RecyclingCenterStaff(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phoneNo'],
      profileImg: map['profileImg'],
      role: map['role'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? false,
      isBanned: map['isBanned'] ?? false,
      centerId: map['centerId'],
      gender: map['gender'],
      joinDate: DateTime.fromMillisecondsSinceEpoch(map['joinDate']),
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
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'isBanned': isBanned,
      'centerId': centerId,
      'gender': gender,
      'joinDate': Timestamp.fromDate(joinDate),
    };
  }

  @override
  RecyclingCenterStaff copyWith({
    String? centerId,
    String? gender,
    DateTime? joinDate,
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
}