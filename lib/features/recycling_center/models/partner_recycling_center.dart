import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';

class PartnerRecyclingCenter {
  String centerId;
  String name;
  String email;
  String phoneNo;
  String website;
  DateTime createdAt;

  /// Constructor
  PartnerRecyclingCenter({
    required this.centerId,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.website,
    required this.createdAt,
  });

  /// Static function to create empty center model
  static PartnerRecyclingCenter empty() => PartnerRecyclingCenter(
    centerId: '',
    name: '',
    email: '',
    phoneNo: '',
    website: '',
    createdAt: DateTime.now(),
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
    };
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
        createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      );
    } else {
      return PartnerRecyclingCenter.empty();
    }
  }

  /// Factory method to create from a JSON map
  factory PartnerRecyclingCenter.fromJson(Map<String, dynamic> json) {
    return PartnerRecyclingCenter(
      centerId: json['centerId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      website: json['website'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Factory method to create a new center
  factory PartnerRecyclingCenter.createNew({
    required String name,
    required String email,
    required String phoneNo,
    required String website,
  }) {
    return PartnerRecyclingCenter(
      centerId: '', // Will be set by Firebase
      name: name,
      email: email,
      phoneNo: phoneNo,
      website: website,
      createdAt: DateTime.now(),
    );
  }

  /// Helper method to check if center data is valid
  bool isValid() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phoneNo.isNotEmpty &&
        website.isNotEmpty;
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
    return 'PartnerRecyclingCenter(centerId: $centerId, name: $name, email: $email, phoneNo: $phoneNo, website: $website)';
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
    DateTime? createdAt,
  }) {
    return PartnerRecyclingCenter(
      centerId: centerId ?? this.centerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
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
}