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

  // 🆕 显示格式化的电话号码（用于 UI 显示）
  String get _formattedPhoneNo {
    if (phoneNo == null || phoneNo!.isEmpty) return '';
    return _formatForDisplay(phoneNo!);
  }

  /// 用于 UI 显示的手机号码（为空时显示 N/A）
  String get displayPhoneNo {
    if (phoneNo == null || phoneNo!.trim().isEmpty) {
      return 'N/A';
    }
    return _formattedPhoneNo; // 用你已经写好的格式化功能
  }

  // 🆕 国际格式（用于存储到数据库）
  String get internationalPhoneNo {
    if (phoneNo == null || phoneNo!.isEmpty) return '';
    return FFormatter.formatPhoneToInternational(phoneNo!);
  }

  // 🆕 格式化为显示格式的静态方法
  // 格式: 012-345 6789 或 011-1234 5678
  static String _formatForDisplay(String phoneNumber) {
    // 移除所有空格、连字符和加号
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\+]'), '');

    // 如果以 +60 或 60 开头，移除国家代码
    if (cleaned.startsWith('60')) {
      cleaned = '0${cleaned.substring(2)}';
    }

    // 确保以 0 开头
    if (!cleaned.startsWith('0')) {
      cleaned = '0$cleaned';
    }

    // 格式化为 01X-XXXX XXXX 或 01X-XXXXX XXXX
    if (cleaned.startsWith('011') || cleaned.startsWith('015')) {
      // 11位数字: 011-1234 5678
      if (cleaned.length == 11) {
        return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)} ${cleaned.substring(7)}';
      }
    } else if (cleaned.startsWith('01')) {
      // 10位数字: 012-345 6789
      if (cleaned.length == 10) {
        return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
      }
    }

    // 如果格式不正确，返回原始清理后的号码
    return cleaned;
  }

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
      'phoneNo': phoneNo != null && phoneNo!.isNotEmpty && phoneNo != 'N/A'
          ? FFormatter.formatPhoneToInternational(phoneNo!)
          : null, // 保存为国际格式
      'profileImg': profileImg,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'isBanned': isBanned,
    };
  }

  factory RoleModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return RoleModel(
        userId: document.id,
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        phoneNo: data['phoneNo'], // 保持国际格式存储
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
