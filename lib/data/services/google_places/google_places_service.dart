import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/google_maps_config.dart';

enum PlaceType {
  region, // 区域（如 George Town, Putrajaya）
  specificLocation, // 具体地点（如完整地址）
}

class PlaceInfo {
  final PlaceType type;
  final String placeId;
  final double latitude;
  final double longitude;
  final String name;
  final List<String> types;

  PlaceInfo({
    required this.type,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.types,
  });
}

class GooglePlacesService {
  /// Determine place type from Google Places API response
  PlaceType _determinePlaceType(List<dynamic> types) {
    // Region types
    const regionTypes = [
      'locality',
      'sublocality',
      'administrative_area_level_1',
      'administrative_area_level_2',
      'administrative_area_level_3',
      'political',
    ];

    // Specific location types (including recycling centers)
    const specificTypes = [
      'street_address',
      'premise',
      'establishment',
      'point_of_interest',
      'route',
      'recycling_center',
      'waste_management',
    ];

    final typesList = types.map((t) => t.toString()).toList();

    // Check for specific location first
    if (typesList.any((t) => specificTypes.contains(t))) {
      return PlaceType.specificLocation;
    }

    // Check for region
    if (typesList.any((t) => regionTypes.contains(t))) {
      return PlaceType.region;
    }

    // Default to region for ambiguous cases
    return PlaceType.region;
  }

  /// Check if a place is a recycling center
  // bool isRecyclingCenter(List<dynamic> types) {
  //   const recyclingTypes = [
  //     'recycling_center',
  //     'waste_management',
  //   ];
  //
  //   final typesList = types.map((t) => t.toString()).toList();
  //   return typesList.any((t) => GooglePlacesConfig.recyclingCenterTypes.contains(t));
  // }

  /// Analyze search query to determine place type
  Future<PlaceInfo?> analyzePlaceQuery(String query) async {
    try {
      final url = GooglePlacesConfig.buildTextSearchUrl(
        query: query,
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final types = List<String>.from(result['types'] ?? []);
          final geometry = result['geometry'] ?? {};
          final location = geometry['location'] ?? {};

          return PlaceInfo(
            type: _determinePlaceType(types),
            placeId: result['place_id'] ?? '',
            latitude: location['lat']?.toDouble() ?? 0.0,
            longitude: location['lng']?.toDouble() ?? 0.0,
            name: result['name'] ?? result['formatted_address'] ?? '',
            types: types,
          );
        }
      }
      return null;
    } catch (e) {
      print('❌ Error analyzing place query: $e');
      return null;
    }
  }

  /// Search nearby recycling centers with pagination
  Future<List<Map<String, dynamic>>> searchNearbyRecyclingCenters({
    required double latitude,
    required double longitude,
    required int radius,
    bool includeDetails = true,
  }) async {
    try {
      List<Map<String, dynamic>> allResults = [];
      String? nextPageToken;
      int pageCount = 0;

      do {
        String url = GooglePlacesConfig.buildNearbySearchUrl(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          nextPageToken: nextPageToken,
        );

        if (nextPageToken != null) {
          await Future.delayed(GooglePlacesConfig.nextPageDelay);
        }

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
            final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
            allResults.addAll(results);

            nextPageToken = data['next_page_token'];
            pageCount++;

            print('📄 Fetched page $pageCount: ${results.length} centers');
          } else {
            print('⚠️ Search status: ${data['status']}');
            break;
          }
        } else {
          print('❌ HTTP error: ${response.statusCode}');
          break;
        }
      } while (nextPageToken != null && pageCount < GooglePlacesConfig.maxNearbySearchPages);

      print('✅ Total centers found: ${allResults.length}');

      if (includeDetails && allResults.isNotEmpty) {
        final detailedResults = <Map<String, dynamic>>[];
        for (final place in allResults) {
          try {
            final details = await getPlaceDetails(place['place_id']);
            detailedResults.add({...place, ...details});
          } catch (e) {
            print('⚠️ Error getting details for ${place['name']}: $e');
            detailedResults.add(place);
          }
        }
        return detailedResults;
      }

      return allResults;
    } catch (e) {
      print('❌ Error searching nearby recycling centers: $e');
      return [];
    }
  }

  /// Calculate driving distance using Distance Matrix API
  Future<double?> calculateDrivingDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = GooglePlacesConfig.buildDistanceMatrixUrl(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          if (element['status'] == 'OK') {
            return (element['distance']['value'] as int) / 1000.0;
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Error calculating driving distance: $e');
      return null;
    }
  }

  /// Batch calculate distances for multiple destinations
  Future<Map<String, double>> batchCalculateDistances({
    required double originLat,
    required double originLng,
    required List<Map<String, double>> destinations, // List of {lat, lng}
  }) async {
    try {
      final Map<String, double> distances = {};

      // Distance Matrix API supports up to 25 destinations per request
      const batchSize = 25;

      for (var i = 0; i < destinations.length; i += batchSize) {
        final batch = destinations.skip(i).take(batchSize).toList();
        final destString = batch.map((d) => '${d['lat']},${d['lng']}').join('|');

        final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
            '?origins=$originLat,$originLng'
            '&destinations=$destString'
            '&key=${GooglePlacesConfig.apiKey}';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final elements = data['rows'][0]['elements'] as List;
            for (var j = 0; j < elements.length; j++) {
              final element = elements[j];
              if (element['status'] == 'OK') {
                final destIndex = i + j;
                final key = '${destinations[destIndex]['lat']},${destinations[destIndex]['lng']}';
                distances[key] = (element['distance']['value'] as int) / 1000.0;
              }
            }
          }
        }

        // Avoid hitting rate limits
        if (i + batchSize < destinations.length) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      return distances;
    } catch (e) {
      print('❌ Error batch calculating distances: $e');
      return {};
    }
  }

  /// Get place details by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = GooglePlacesConfig.buildPlaceDetailsUrl(placeId);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return {};
    } catch (e) {
      print('❌ Error getting place details: $e');
      return {};
    }
  }

  /// Search for specific recycling center
  Future<List<Map<String, dynamic>>> searchRecyclingCenterByName({
    required String name,
    required double latitude,
    required double longitude,
    int radius = GooglePlacesConfig.defaultRadiusMeters,
  }) async {
    try {
      final url = GooglePlacesConfig.buildTextSearchUrl(
        query: '$name recycling center',
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);

          final detailedResults = <Map<String, dynamic>>[];
          for (final place in results) {
            try {
              final details = await getPlaceDetails(place['place_id']);
              detailedResults.add({...place, ...details});
            } catch (e) {
              detailedResults.add(place);
            }
          }
          return detailedResults;
        }
      }
      return [];
    } catch (e) {
      print('❌ Error searching recycling center by name: $e');
      return [];
    }
  }

  /// Get photo URL from photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = GooglePlacesConfig.defaultPhotoMaxWidth}) {
    return GooglePlacesConfig.buildPhotoUrl(photoReference, maxWidth: maxWidth);
  }

  /// Geocode address
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final url = GooglePlacesConfig.buildGeocodeUrl(address);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'latitude': location['lat'].toDouble(),
            'longitude': location['lng'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error geocoding address: $e');
      return null;
    }
  }

  /// Reverse geocode
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = GooglePlacesConfig.buildReverseGeocodeUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error reverse geocoding: $e');
      return null;
    }
  }
}