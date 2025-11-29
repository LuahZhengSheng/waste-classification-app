import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';

class RedemptionModel {
  String redemptionId;
  String userId;
  String rewardId;
  String pinCode;
  DateTime createdAt;
  DateTime validUntil;
  String status; // 'active', 'expired'
  int points;

  RedemptionModel({
    required this.redemptionId,
    required this.userId,
    required this.rewardId,
    required this.pinCode,
    required this.createdAt,
    required this.validUntil,
    required this.points,
    this.status = 'active',
  });

  static RedemptionModel empty() => RedemptionModel(
    redemptionId: '',
    userId: '',
    rewardId: '',
    pinCode: '',
    createdAt: DateTime.now(),
    validUntil: DateTime.now().add(const Duration(days: 30)),
    points: 0,
  );

  /// 写入 Firestore：时间字段用 Timestamp
  Map<String, dynamic> toJson() {
    return {
      'redemptionId': redemptionId,
      'userId': userId,
      'rewardId': rewardId,
      'pinCode': pinCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': status,
      'points': points,
    };
  }

  /// 从 Firestore DocumentSnapshot 读取（createdAt / validUntil 为 Timestamp）
  factory RedemptionModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return RedemptionModel.empty();

    final createdTs = data['createdAt'] as Timestamp?;
    final validTs = data['validUntil'] as Timestamp?;

    return RedemptionModel(
      redemptionId: document.id,
      userId: data['userId'] ?? '',
      rewardId: data['rewardId'] ?? '',
      pinCode: data['pinCode'] ?? '',
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      validUntil:
      validTs?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      points: (data['points'] ?? 0) as int,
      status: data['status'] ?? 'active',
    );
  }

  /// 从 JSON map（如果你本地反序列化时用）
  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    final createdTs = json['createdAt'] as Timestamp?;
    final validTs = json['validUntil'] as Timestamp?;
    return RedemptionModel(
      redemptionId: json['redemptionId'] ?? '',
      userId: json['userId'] ?? '',
      rewardId: json['rewardId'] ?? '',
      pinCode: json['pinCode'] ?? '',
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      validUntil:
      validTs?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      points: (json['points'] ?? 0) as int,
      status: json['status'] ?? 'active',
    );
  }

  /// 创建新 redemption，自动生成 12 位 PIN
  factory RedemptionModel.createNew({
    required String userId,
    required String rewardId,
    required int points,
    required DateTime validUntil,
    String? customPinCode,
    Duration validityDuration = const Duration(days: 30),
  }) {
    final now = DateTime.now();
    return RedemptionModel(
      redemptionId: '',
      userId: userId,
      rewardId: rewardId,
      pinCode: customPinCode ?? _generatePinCode(),
      createdAt: now,
      validUntil: validUntil,
      points: points,
      status: 'active',
    );
  }

  /// 生成 12 位数字 PIN
  static String _generatePinCode() {
    final buffer = StringBuffer();
    final now = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 12; i++) {
      final digit = (now >> (i * 3)) % 10;
      buffer.write(digit);
    }
    return buffer.toString();
  }

  bool get isActive => status == 'active';

  bool get isExpired =>
      status == 'expired' || DateTime.now().isAfter(validUntil);

  String get formattedCreatedAt => FFormatter.formatDate(createdAt);

  String get formattedValidUntil => FFormatter.formatDate(validUntil);

  String get statusDisplayText {
    if (DateTime.now().isAfter(validUntil) && status == 'active') {
      return 'Expired';
    }
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  /// 4-4-4 显示 12 位 PIN
  String get formattedPinCode {
    if (pinCode.length == 12) {
      return '${pinCode.substring(0, 4)} '
          '${pinCode.substring(4, 8)} '
          '${pinCode.substring(8, 12)}';
    }
    return pinCode;
  }

  void markAsUsed() {
    status = 'expired';
  }

  void markAsExpired() {
    status = 'expired';
  }

  bool isValid() {
    return userId.isNotEmpty &&
        rewardId.isNotEmpty &&
        pinCode.isNotEmpty &&
        pinCode.length == 12 &&
        points > 0 &&
        validUntil.isAfter(createdAt);
  }

  bool isPinCodeValid(String inputPin) {
    return pinCode == inputPin.replaceAll(' ', '');
  }

  int get daysSinceRedemption =>
      DateTime.now().difference(createdAt).inDays;

  int get hoursSinceRedemption =>
      DateTime.now().difference(createdAt).inHours;

  bool get isRecent => hoursSinceRedemption < 24;

  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(validUntil)) return 0;
    return validUntil.difference(now).inDays;
  }

  bool get isValidNow =>
      status == 'active' && DateTime.now().isBefore(validUntil);

  @override
  String toString() {
    return 'RedemptionModel(redemptionId: $redemptionId, userId: $userId, rewardId: $rewardId, pinCode: $pinCode, points: $points, validUntil: $validUntil, status: $status)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RedemptionModel &&
              runtimeType == other.runtimeType &&
              redemptionId == other.redemptionId;

  @override
  int get hashCode => redemptionId.hashCode;

  RedemptionModel copyWith({
    String? redemptionId,
    String? userId,
    String? rewardId,
    String? pinCode,
    DateTime? createdAt,
    DateTime? validUntil,
    int? points,
    String? status,
  }) {
    return RedemptionModel(
      redemptionId: redemptionId ?? this.redemptionId,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      points: points ?? this.points,
      status: status ?? this.status,
    );
  }

  void generateNewPinCode() {
    pinCode = _generatePinCode();
  }

  bool shouldExpire({Duration? expiryDuration}) {
    final expiry = expiryDuration ?? const Duration(days: 30);
    return DateTime.now().difference(createdAt) > expiry &&
        status == 'active';
  }

  void autoExpireIfNeeded({Duration? expiryDuration}) {
    if (shouldExpire(expiryDuration: expiryDuration) ||
        DateTime.now().isAfter(validUntil)) {
      markAsExpired();
    }
  }

  void extendValidity(Duration extension) {
    validUntil = validUntil.add(extension);
  }

  void setValidUntil(DateTime newValidUntil) {
    if (newValidUntil.isAfter(createdAt)) {
      validUntil = newValidUntil;
    }
  }
}
