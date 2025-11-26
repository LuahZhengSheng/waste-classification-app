import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';

class RoleModel {
  final String userId;
  final String username;
  final String email;
  String? phoneNo;
  String? profileImg;
  final String role;
  final bool isVerified;
  final bool isActive;
  final bool isBanned;

  RoleModel({
    required this.userId,
    required this.username,
    required this.email,
    this.phoneNo,
    this.profileImg,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.isBanned,
  });

  RoleModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? phoneNo,
    String? profileImg,
    String? role,
    bool? isVerified,
    bool? isActive,
    bool? isBanned,
  }) {
    return RoleModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImg: profileImg ?? this.profileImg,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isBanned: isBanned ?? this.isBanned,
    );
  }

  String get formattedPhoneNo => phoneNo != null ? FFormatter.formatPhoneNumber(phoneNo!) : '';

  static RoleModel empty() => RoleModel(
    userId: '',
    username: '',
    email: '',
    role: '',
    isVerified: false,
    isActive: false,
    isBanned: false,
  );

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
    };
  }

  factory RoleModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return RoleModel(
        userId: document.id,
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        phoneNo: data['phoneNo'],
        profileImg: data['profileImg'],
        role: data['role'] ?? '',
        isVerified: data['isVerified'] ?? false,
        isActive: data['isActive'] ?? false,
        isBanned: data['isBanned'] ?? false,
      );
    } else {
      throw Exception("Document data is null for document ID: ${document.id}");
    }
  }
}