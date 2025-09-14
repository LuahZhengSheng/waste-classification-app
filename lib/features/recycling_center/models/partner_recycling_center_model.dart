import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';

import '../../event/models/location_model.dart';

class PartnerRecyclingCenter {
  final String centerId;
  final String name;
  final String email;
  final String phoneNo;
  final String website;
  final Location centerLocation;
  final String image;
  final Map<String, Map<String, DateTime>> operatingHours;
  final int numberOfStaff;
  final DateTime createdAt;
  final String status;

  /// Constructor
  PartnerRecyclingCenter({
    required this.centerId,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.website,
    required this.centerLocation,
    required this.image,
    required this.operatingHours,
    required this.numberOfStaff,
    required this.createdAt,
    required this.status,
  });

  /// Static function to create empty center model
  static PartnerRecyclingCenter empty() => PartnerRecyclingCenter(
    centerId: '',
    name: '',
    email: '',
    phoneNo: '',
    website: '',
    centerLocation: Location.empty(),
    image: '',
    operatingHours: {},
    numberOfStaff: 0,
    createdAt: DateTime.now(),
    status: 'inactive', // 默认状态
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'website': website,
      'centerLocation': centerLocation,
      'image': image,
      'operatingHours': _operatingHoursToJson(operatingHours),
      'numberOfStaff': numberOfStaff,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  /// Helper method to convert operating hours to JSON
  Map<String, dynamic> _operatingHoursToJson(Map<String, Map<String, DateTime>> hours) {
    final Map<String, dynamic> result = {};
    hours.forEach((day, times) {
      result[day] = {
        'open': times['open']?.toIso8601String(),
        'close': times['close']?.toIso8601String(),
      };
    });
    return result;
  }

  /// Factory method to create from a Firebase document snapshot
  factory PartnerRecyclingCenter.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return PartnerRecyclingCenter(
        centerId: document.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phoneNo: data['phoneNo'] ?? '',
        website: data['website'] ?? '',
        centerLocation: Location.fromJson(Map<String, dynamic>.from(data['location'] ?? {})),
        image: data['image'] ?? '',
        operatingHours: _operatingHoursFromJson(data['operatingHours'] ?? {}),
        numberOfStaff: (data['numberOfStaff'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
        status: data['status'] ?? 'inactive',
      );
    } else {
      return PartnerRecyclingCenter.empty();
    }
  }

  /// Helper method to convert JSON to operating hours
  static Map<String, Map<String, DateTime>> _operatingHoursFromJson(dynamic json) {
    final Map<String, Map<String, DateTime>> result = {};
    if (json is Map<String, dynamic>) {
      json.forEach((day, times) {
        if (times is Map<String, dynamic>) {
          result[day] = {
            'open': times['open'] != null ? DateTime.parse(times['open']) : DateTime.now(),
            'close': times['close'] != null ? DateTime.parse(times['close']) : DateTime.now(),
          };
        }
      });
    }
    return result;
  }

  /// Factory method to create from a JSON map
  factory PartnerRecyclingCenter.fromJson(Map<String, dynamic> json) {
    return PartnerRecyclingCenter(
      centerId: json['centerId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      website: json['website'] ?? '',
      centerLocation: Location.fromJson(json['location'] ?? {}),
      image: json['image'] ?? '',
      operatingHours: _operatingHoursFromJson(json['operatingHours'] ?? {}),
      numberOfStaff: json['numberOfStaff']?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'inactive',
    );
  }

  /// Factory method to create a new center
  factory PartnerRecyclingCenter.createNew({
    required String name,
    required String email,
    required String phoneNo,
    required String website,
    required Location centerLocation, // 新增
    required String image, // 新增
    required Map<String, Map<String, DateTime>> operatingHours, // 新增
    required int numberOfStaff,
    required String status, // 新增
  }) {
    return PartnerRecyclingCenter(
      centerId: '', // Will be set by Firebase
      name: name,
      email: email,
      phoneNo: phoneNo,
      website: website,
      centerLocation: centerLocation,
      image: image,
      operatingHours: operatingHours,
      numberOfStaff: numberOfStaff,
      createdAt: DateTime.now(),
      status: status,
    );
  }

  /// Helper method to check if center data is valid
  bool isValid() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phoneNo.isNotEmpty &&
        website.isNotEmpty &&
        status.isNotEmpty; // 新增状态验证
  }

  /// Helper method to validate email format
  bool get hasValidEmail {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  /// Helper method to validate phone number format
  bool get hasValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNo.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  /// Helper method to validate website URL format
  bool get hasValidWebsite {
    final websiteRegex = RegExp(r'^(http|https):\/\/[^ "]+$');
    return websiteRegex.hasMatch(website);
  }

  /// Helper method to get formatted creation date
  String get formattedCreatedAt {
    return FFormatter.formatDate(createdAt);
  }

  /// Helper method to get formatted phone number
  String get formattedPhoneNo {
    if (phoneNo.length == 10) {
      return '${phoneNo.substring(0, 3)}-${phoneNo.substring(3, 6)}-${phoneNo.substring(6)}';
    }
    return phoneNo;
  }

  /// Helper method to get display name with ID
  String get displayNameWithId {
    return '$name (ID: ${centerId.substring(0, 8)})';
  }

  /// Override toString for debugging purposes
  @override
  String toString() {
    return 'PartnerRecyclingCenter(centerId: $centerId, name: $name, email: $email, phoneNo: $phoneNo, website: $website, status: $status)';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PartnerRecyclingCenter &&
              runtimeType == other.runtimeType &&
              centerId == other.centerId;

  /// Override hashCode
  @override
  int get hashCode => centerId.hashCode;

  /// Create a copy with updated fields
  PartnerRecyclingCenter copyWith({
    String? centerId,
    String? name,
    String? email,
    String? phoneNo,
    String? website,
    Location? centerLocation, // 新增
    String? image, // 新增
    Map<String, Map<String, DateTime>>? operatingHours, // 新增
    int? numberOfStaff,
    DateTime? createdAt,
    String? status, // 新增
  }) {
    return PartnerRecyclingCenter(
      centerId: centerId ?? this.centerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      website: website ?? this.website,
      centerLocation: centerLocation ?? this.centerLocation,
      image: image ?? this.image,
      operatingHours: operatingHours ?? this.operatingHours,
      numberOfStaff: numberOfStaff ?? this.numberOfStaff,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Helper method to get center age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Helper method to check if center is newly created (within 7 days)
  bool get isNewCenter {
    return ageInDays < 7;
  }

  /// Helper method to check if center is active
  bool get isActive {
    return status == 'active';
  }

  /// Helper method to check if center is open now
  bool get isOpenNow {
    final now = DateTime.now();
    final today = now.weekday;
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todaySchedule = operatingHours[days[today - 1]];

    if (todaySchedule == null) return false;

    final openTime = todaySchedule['open'];
    final closeTime = todaySchedule['close'];

    if (openTime == null || closeTime == null) return false;

    final currentTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final open = DateTime(now.year, now.month, now.day, openTime.hour, openTime.minute);
    final close = DateTime(now.year, now.month, now.day, closeTime.hour, closeTime.minute);

    return currentTime.isAfter(open) && currentTime.isBefore(close);
  }
}