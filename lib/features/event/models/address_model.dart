/// Model representing a physical address
class Address {
  final String unitNo;
  final String area;
  final String postcode;
  final String city;
  final String state;
  final String? fullAddress;
  final String? placeId; // ✅ 新增 Google Place ID

  const Address({
    required this.unitNo,
    required this.area,
    required this.postcode,
    required this.city,
    required this.state,
    this.fullAddress,
    this.placeId, // ✅ 新增
  });

  /// Creates an empty Address instance
  static Address empty() => const Address(
    unitNo: '',
    area: '',
    postcode: '',
    city: '',
    state: '',
  );

  /// Creates Address instance from JSON map
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      unitNo: json['unitNo'] ?? '',
      area: json['area'] ?? '',
      postcode: json['postcode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      fullAddress: json['fullAddress'],
      placeId: json['placeId'], // ✅ 新增
    );
  }

  /// Converts Address instance to JSON map
  Map<String, dynamic> toJson() {
    final json = {
      'unitNo': unitNo,
      'area': area,
      'postcode': postcode,
      'city': city,
      'state': state,
    };

    if (fullAddress != null && fullAddress!.isNotEmpty) {
      json['fullAddress'] = fullAddress!;
    }

    if (placeId != null && placeId!.isNotEmpty) {
      json['placeId'] = placeId!; // ✅ 新增
    }

    return json;
  }

  /// Returns formatted address string
  String get formattedAddress {
    return fullAddress ?? '$unitNo, $area, $postcode $city, $state';
  }

  /// Returns short address format (area, city, state)
  String get shortAddress {
    return '$area, $city, $state';
  }

  /// 专门获取 Google 地址的方法（如果有）
  String? get googleAddress => fullAddress;

  /// 检查是否有 Google Place ID
  bool get hasPlaceId => placeId != null && placeId!.isNotEmpty;

  /// Creates a copy of Address with updated fields
  Address copyWith({
    String? unitNo,
    String? area,
    String? postcode,
    String? city,
    String? state,
    String? fullAddress,
    String? placeId, // ✅ 新增
  }) {
    return Address(
      unitNo: unitNo ?? this.unitNo,
      area: area ?? this.area,
      postcode: postcode ?? this.postcode,
      city: city ?? this.city,
      state: state ?? this.state,
      fullAddress: fullAddress ?? this.fullAddress,
      placeId: placeId ?? this.placeId, // ✅ 新增
    );
  }

  @override
  String toString() {
    return formattedAddress;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.unitNo == unitNo &&
        other.area == area &&
        other.postcode == postcode &&
        other.city == city &&
        other.state == state &&
        other.fullAddress == fullAddress &&
        other.placeId == placeId; // ✅ 新增
  }

  @override
  int get hashCode {
    return unitNo.hashCode ^
    area.hashCode ^
    postcode.hashCode ^
    city.hashCode ^
    state.hashCode ^
    fullAddress.hashCode ^
    placeId.hashCode; // ✅ 新增
  }
}