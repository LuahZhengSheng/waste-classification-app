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
  final Map<String, dynamic>? openingHours;
  final List<String> acceptedMaterials;
  final int numberOfStaff;
  final DateTime createdAt;
  final String status;
  final double? rating;
  final int? userRatingsTotal;
  final double? drivingDistance; // 实际驾驶距离（km）

  PartnerRecyclingCenter({
    required this.centerId,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.website,
    required this.centerLocation,
    required this.image,
    this.openingHours,
    this.acceptedMaterials = const [],
    required this.numberOfStaff,
    required this.createdAt,
    required this.status,
    this.rating,
    this.userRatingsTotal,
    this.drivingDistance,
  });

  static PartnerRecyclingCenter empty() => PartnerRecyclingCenter(
    centerId: '',
    name: '',
    email: '',
    phoneNo: '',
    website: '',
    centerLocation: Location.empty(),
    image: '',
    openingHours: null,
    acceptedMaterials: [],
    numberOfStaff: 0,
    createdAt: DateTime.now().toUtc(),
    status: 'inactive',
  );

  /// 用于创建新回收中心的工厂方法
  static PartnerRecyclingCenter createNew({
    required String name,
    required String email,
    required String phoneNo,
    required String website,
    required Location centerLocation,
    required String image,
    required Map<String, dynamic> openingHours,
    required List<String> acceptedMaterials,
    required int numberOfStaff,
    String status = 'active',
  }) {
    return PartnerRecyclingCenter(
      centerId: '', // 由 Firestore 自动生成
      name: name,
      email: email,
      phoneNo: phoneNo,
      website: website,
      centerLocation: centerLocation,
      image: image,
      openingHours: openingHours,
      acceptedMaterials: acceptedMaterials,
      numberOfStaff: numberOfStaff,
      createdAt: DateTime.now().toUtc(), // 临时 UTC 时间，写入时会被 ServerTime 替换
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'centerId': centerId,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'website': website,
      'centerLocation': centerLocation.toJson(),
      'image': image,
      'openingHours': openingHours,
      'acceptedMaterials': acceptedMaterials,
      'numberOfStaff': numberOfStaff,
      'status': status,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
    };

    if (centerId.isEmpty) {
      json['createdAt'] = FieldValue.serverTimestamp();
    } else {
      json['createdAt'] = Timestamp.fromDate(createdAt);
    }

    return json;
  }

  factory PartnerRecyclingCenter.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      DateTime createdAt;
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else {
        createdAt = DateTime.now().toUtc();
      }

      // 安全地处理 openingHours
      Map<String, dynamic>? openingHours;
      if (data['openingHours'] != null) {
        try {
          openingHours = Map<String, dynamic>.from(data['openingHours']);
        } catch (e) {
          print('⚠️ Error parsing opening hours for ${data['name']}: $e');
          openingHours = null;
        }
      }

      return PartnerRecyclingCenter(
        centerId: document.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phoneNo: data['phoneNo'] ?? '',
        website: data['website'] ?? '',
        centerLocation: Location.fromJson(Map<String, dynamic>.from(data['centerLocation'] ?? {})),
        image: data['image'] ?? '',
        openingHours: openingHours,
        acceptedMaterials: List<String>.from(data['acceptedMaterials'] ?? []),
        numberOfStaff: (data['numberOfStaff'] as num?)?.toInt() ?? 0,
        createdAt: createdAt,
        status: data['status'] ?? 'inactive',
        rating: data['rating']?.toDouble(),
        userRatingsTotal: data['userRatingsTotal'],
      );
    } else {
      return PartnerRecyclingCenter.empty();
    }
  }

  DateTime get displayTime {
    return createdAt.add(const Duration(hours: 8));
  }

  static DateTime _getCurrentMalaysiaTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 8));
  }

  bool isValid() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phoneNo.isNotEmpty &&
        website.isNotEmpty &&
        status.isNotEmpty;
  }

  bool get hasValidEmail {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool get hasValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNo.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  bool get hasValidWebsite {
    final websiteRegex = RegExp(r'^(http|https):\/\/[^ "]+$');
    return websiteRegex.hasMatch(website);
  }

  String get formattedCreatedAt {
    return FFormatter.formatDate(displayTime);
  }

  String get formattedPhoneNo {
    if (phoneNo.length == 10) {
      return '${phoneNo.substring(0, 3)}-${phoneNo.substring(3, 6)}-${phoneNo.substring(6)}';
    }
    return phoneNo;
  }

  String get displayNameWithId {
    return '$name (ID: ${centerId.substring(0, 8)})';
  }

  bool get isActive {
    return status == 'active';
  }

  bool get isOpenNow {
    if (openingHours == null || openingHours!.isEmpty) {
      print('⚠️ No opening hours data for $name');
      return false;
    }
    return _isOpenAtTime(_getCurrentMalaysiaTime());
  }

  bool _isOpenAtTime(DateTime time) {
    if (openingHours == null) return false;

    // Check Google Places API format first
    if (openingHours!.containsKey('periods') || openingHours!.containsKey('open_now')) {
      return _isOpenAtTimeGoogleFormat(time);
    }

    // Otherwise use Firestore format (day names as keys)
    return _isOpenAtTimeFirestoreFormat(time);
  }

  /// Check opening hours using Google Places API format
  bool _isOpenAtTimeGoogleFormat(DateTime time) {
    // Check if it's open 24 hours
    if (openingHours!['open_now'] != null) {
      return openingHours!['open_now'] as bool;
    }

    final weekday = time.weekday; // 1 = Monday, 7 = Sunday

    final periods = openingHours!['periods'];
    if (periods == null || periods is! List) {
      return false;
    }

    for (var period in periods) {
      if (period == null || period is! Map) continue;

      final open = period['open'];
      if (open == null || open is! Map) continue;

      // Google Places API: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
      // Dart weekday: 1 = Monday, ..., 7 = Sunday
      final googleDay = weekday == 7 ? 0 : weekday;

      if (open['day'] == googleDay) {
        final openTime = open['time'] as String?;
        final close = period['close'];
        final closeTime = close != null ? close['time'] as String? : null;

        if (openTime != null) {
          final currentTimeStr = '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}';

          if (closeTime == null) {
            return true; // Open 24 hours
          }

          // Handle overnight closing
          if (closeTime.compareTo(openTime) < 0) {
            return currentTimeStr.compareTo(openTime) >= 0 || currentTimeStr.compareTo(closeTime) < 0;
          }

          return currentTimeStr.compareTo(openTime) >= 0 && currentTimeStr.compareTo(closeTime) < 0;
        }
      }
    }
    return false;
  }

  /// Check opening hours using Firestore format (day names as keys)
  bool _isOpenAtTimeFirestoreFormat(DateTime time) {
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final weekday = time.weekday; // 1 = Monday, 7 = Sunday
    final dayName = dayNames[weekday - 1];

    if (!openingHours!.containsKey(dayName)) {
      return false; // Closed on this day
    }

    final daySchedule = openingHours![dayName];
    if (daySchedule == null || daySchedule is! Map) {
      return false;
    }

    final openTime = daySchedule['open'] as String?;
    final closeTime = daySchedule['close'] as String?;

    if (openTime == null || closeTime == null) {
      return false;
    }

    // Convert HH:MM to HHMM for comparison
    final currentTimeStr = '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}';
    final openTimeStr = openTime.replaceAll(':', '');
    final closeTimeStr = closeTime.replaceAll(':', '');

    // Handle overnight closing
    if (closeTimeStr.compareTo(openTimeStr) < 0) {
      return currentTimeStr.compareTo(openTimeStr) >= 0 || currentTimeStr.compareTo(closeTimeStr) < 0;
    }

    return currentTimeStr.compareTo(openTimeStr) >= 0 && currentTimeStr.compareTo(closeTimeStr) < 0;
  }

  List<String> get weekdayText {
    if (openingHours != null && openingHours!['weekday_text'] is List) {
      return List<String>.from(openingHours!['weekday_text']);
    }

    // Try to generate from Google Places format
    if (openingHours != null && openingHours!['periods'] is List) {
      return _generateWeekdayTextFromGooglePeriods();
    }

    // Try to generate from Firestore format
    if (openingHours != null && _isFirestoreFormat()) {
      return _generateWeekdayTextFromFirestore();
    }

    return [
      'Monday: Unknown',
      'Tuesday: Unknown',
      'Wednesday: Unknown',
      'Thursday: Unknown',
      'Friday: Unknown',
      'Saturday: Unknown',
      'Sunday: Unknown'
    ];
  }

  /// Check if opening hours is in Firestore format
  bool _isFirestoreFormat() {
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return dayNames.any((day) => openingHours!.containsKey(day));
  }

  /// Generate weekday text from Firestore format
  List<String> _generateWeekdayTextFromFirestore() {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final result = <String>[];

    for (var i = 0; i < dayKeys.length; i++) {
      final dayKey = dayKeys[i];
      final dayName = dayNames[i];

      if (openingHours!.containsKey(dayKey)) {
        final schedule = openingHours![dayKey];
        if (schedule is Map && schedule.containsKey('open') && schedule.containsKey('close')) {
          final open = schedule['open'] as String;
          final close = schedule['close'] as String;
          result.add('$dayName: $open – $close');
        } else {
          result.add('$dayName: Closed');
        }
      } else {
        result.add('$dayName: Closed');
      }
    }

    return result;
  }

  /// Generate weekday text from Google Places periods
  List<String> _generateWeekdayTextFromGooglePeriods() {
    final periods = openingHours!['periods'] as List;
    final Map<int, String> dayTexts = {};

    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    for (var period in periods) {
      if (period == null || period is! Map) continue;

      final open = period['open'];
      final close = period['close'];

      if (open != null && open is Map) {
        final day = open['day'] as int;
        final openTime = open['time'] as String?;

        if (openTime != null) {
          final openFormatted = '${openTime.substring(0, 2)}:${openTime.substring(2)}';

          if (close != null && close is Map) {
            final closeTime = close['time'] as String?;
            if (closeTime != null) {
              final closeFormatted = '${closeTime.substring(0, 2)}:${closeTime.substring(2)}';
              dayTexts[day] = '${dayNames[day]}: $openFormatted – $closeFormatted';
            } else {
              dayTexts[day] = '${dayNames[day]}: Open 24 hours';
            }
          } else {
            dayTexts[day] = '${dayNames[day]}: Open 24 hours';
          }
        }
      }
    }

    // Fill in missing days and reorder (Monday first)
    final result = <String>[];
    for (var i = 0; i < 7; i++) {
      final displayDay = (i + 1) % 7; // Convert to Monday-first order
      result.add(dayTexts[displayDay] ?? '${dayNames[displayDay]}: Closed');
    }

    return result;
  }

  bool get hasPhotos => image.isNotEmpty;

  bool acceptsMaterial(String material) {
    return acceptedMaterials.any((m) => m.toLowerCase().contains(material.toLowerCase()));
  }

  String get formattedDistance {
    if (drivingDistance == null) return 'Unknown distance';
    if (drivingDistance! < 1) {
      return '${(drivingDistance! * 1000).toStringAsFixed(0)} m';
    }
    return '${drivingDistance!.toStringAsFixed(1)} km';
  }

  PartnerRecyclingCenter copyWith({
    String? centerId,
    String? name,
    String? email,
    String? phoneNo,
    String? website,
    Location? centerLocation,
    String? image,
    Map<String, dynamic>? openingHours,
    List<String>? acceptedMaterials,
    int? numberOfStaff,
    DateTime? createdAt,
    String? status,
    double? rating,
    int? userRatingsTotal,
    double? drivingDistance,
  }) {
    return PartnerRecyclingCenter(
      centerId: centerId ?? this.centerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      website: website ?? this.website,
      centerLocation: centerLocation ?? this.centerLocation,
      image: image ?? this.image,
      openingHours: openingHours ?? this.openingHours,
      acceptedMaterials: acceptedMaterials ?? this.acceptedMaterials,
      numberOfStaff: numberOfStaff ?? this.numberOfStaff,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      drivingDistance: drivingDistance ?? this.drivingDistance,
    );
  }

  @override
  String toString() {
    return 'PartnerRecyclingCenter(centerId: $centerId, name: $name, isActive: $isActive, rating: $rating, distance: ${formattedDistance})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PartnerRecyclingCenter &&
              runtimeType == other.runtimeType &&
              centerId == other.centerId;

  @override
  int get hashCode => centerId.hashCode;
}