import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'dart:math';

class RedemptionModel {
  String redemptionId;
  String userId;
  String rewardId;
  String pinCode;
  DateTime createdAt;
  String status; // 'pending', 'used', 'expired'

  /// Constructor
  RedemptionModel({
    required this.redemptionId,
    required this.userId,
    required this.rewardId,
    required this.pinCode,
    required this.createdAt,
    this.status = 'pending',
  });

  /// Static function to create empty redemption model
  static RedemptionModel empty() => RedemptionModel(
    redemptionId: '',
    userId: '',
    rewardId: '',
    pinCode: '',
    createdAt: DateTime.now(),
    status: 'pending',
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'redemptionId': redemptionId,
      'userId': userId,
      'rewardId': rewardId,
      'pinCode': pinCode,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  /// Factory method to create a RedemptionModel from a Firebase document snapshot
  factory RedemptionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return RedemptionModel(
        redemptionId: document.id,
        userId: data['userId'] ?? '',
        rewardId: data['rewardId'] ?? '',
        pinCode: data['pinCode'] ?? '',
        createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
        status: data['status'] ?? 'pending',
      );
    } else {
      return RedemptionModel.empty();
    }
  }

  /// Factory method to create a RedemptionModel from a JSON map
  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      redemptionId: json['redemptionId'] ?? '',
      userId: json['userId'] ?? '',
      rewardId: json['rewardId'] ?? '',
      pinCode: json['pinCode'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
    );
  }

  /// Factory method to create a new redemption with auto-generated PIN
  factory RedemptionModel.createNew({
    required String userId,
    required String rewardId,
    String? customPinCode,
  }) {
    return RedemptionModel(
      redemptionId: '', // Will be set by Firebase
      userId: userId,
      rewardId: rewardId,
      pinCode: customPinCode ?? _generatePinCode(),
      createdAt: DateTime.now(),
      status: 'pending',
    );
  }

  /// Private method to generate a random 6-digit PIN code
  static String _generatePinCode() {
    final random = Random();
    final pinCode = random.nextInt(900000) + 100000; // Generates 6-digit number
    return pinCode.toString();
  }

  /// Helper method to check if redemption is still valid/pending
  bool get isPending {
    return status == 'pending';
  }

  /// Helper method to check if redemption has been used
  bool get isUsed {
    return status == 'used';
  }

  /// Helper method to check if redemption has expired
  bool get isExpired {
    return status == 'expired';
  }

  /// Helper method to get formatted creation date
  String get formattedCreatedAt {
    return FFormatter.formatDate(createdAt);
  }

  /// Helper method to get status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'used':
        return 'Used';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Helper method to get formatted PIN code (with spaces for better readability)
  String get formattedPinCode {
    if (pinCode.length == 6) {
      return '${pinCode.substring(0, 3)} ${pinCode.substring(3)}';
    }
    return pinCode;
  }

  /// Helper method to mark redemption as used
  void markAsUsed() {
    status = 'used';
  }

  /// Helper method to mark redemption as expired
  void markAsExpired() {
    status = 'expired';
  }

  /// Helper method to cancel redemption
  void cancel() {
    status = 'cancelled';
  }

  /// Helper method to validate redemption data
  bool isValid() {
    return userId.isNotEmpty &&
        rewardId.isNotEmpty &&
        pinCode.isNotEmpty &&
        pinCode.length == 6;
  }

  /// Helper method to check if PIN code matches
  bool isPinCodeValid(String inputPin) {
    return pinCode == inputPin.replaceAll(' ', '');
  }

  /// Helper method to get days since redemption
  int get daysSinceRedemption {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Helper method to get hours since redemption
  int get hoursSinceRedemption {
    return DateTime.now().difference(createdAt).inHours;
  }

  /// Helper method to check if redemption is recent (within last 24 hours)
  bool get isRecent {
    return hoursSinceRedemption < 24;
  }

  /// Override toString for debugging purposes
  @override
  String toString() {
    return 'RedemptionModel(redemptionId: $redemptionId, userId: $userId, rewardId: $rewardId, pinCode: $pinCode, status: $status)';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RedemptionModel &&
              runtimeType == other.runtimeType &&
              redemptionId == other.redemptionId;

  /// Override hashCode
  @override
  int get hashCode => redemptionId.hashCode;

  /// Create a copy of the redemption with updated fields
  RedemptionModel copyWith({
    String? redemptionId,
    String? userId,
    String? rewardId,
    String? pinCode,
    DateTime? createdAt,
    String? status,
  }) {
    return RedemptionModel(
      redemptionId: redemptionId ?? this.redemptionId,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Helper method to generate a new PIN code
  void generateNewPinCode() {
    pinCode = _generatePinCode();
  }

  /// Helper method to check if redemption should be expired based on time
  bool shouldExpire({Duration? expiryDuration}) {
    final expiry = expiryDuration ?? const Duration(days: 30); // Default 30 days
    return DateTime.now().difference(createdAt) > expiry && status == 'pending';
  }

  /// Helper method to auto-expire if needed
  void autoExpireIfNeeded({Duration? expiryDuration}) {
    if (shouldExpire(expiryDuration: expiryDuration)) {
      markAsExpired();
    }
  }
}