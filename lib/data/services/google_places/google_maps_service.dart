import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/google_places_config.dart';

class GoogleMapsService {
  /// Search for location by address in Malaysia
  Future<Map<String, dynamic>?> searchLocation(String address) async {
    try {
      final url = GooglePlacesConfig.buildGeocodeUrl(address);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];

          // Check if location is in Malaysia
          final addressComponents = result['address_components'] as List;
          bool isInMalaysia = addressComponents.any((component) =>
          (component['types'] as List).contains('country') &&
              component['short_name'] == 'MY');

          if (!isInMalaysia) {
            return null;
          }

          return {
            'placeId': result['place_id'],
            'formattedAddress': result['formatted_address'],
            'latitude': result['geometry']['location']['lat'],
            'longitude': result['geometry']['location']['lng'],
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error searching location: $e');
      return null;
    }
  }

  /// Search for location by coordinates (reverse geocoding)
  Future<Map<String, dynamic>?> searchLocationByCoordinates(double latitude, double longitude) async {
    try {
      final url = GooglePlacesConfig.buildReverseGeocodeUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];

          // Check if location is in Malaysia
          final addressComponents = result['address_components'] as List;
          bool isInMalaysia = addressComponents.any((component) =>
          (component['types'] as List).contains('country') &&
              component['short_name'] == 'MY');

          if (!isInMalaysia) {
            return null;
          }

          return {
            'placeId': result['place_id'],
            'formattedAddress': result['formatted_address'],
            'latitude': latitude,
            'longitude': longitude,
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error searching location by coordinates: $e');
      return null;
    }
  }

  /// Verify if coordinates are within Malaysia
  Future<bool> isWithinMalaysia(double latitude, double longitude) async {
    try {
      final url = GooglePlacesConfig.buildReverseGeocodeUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final addressComponents = data['results'][0]['address_components'] as List;
          return addressComponents.any((component) =>
          (component['types'] as List).contains('country') &&
              component['short_name'] == 'MY');
        }
      }
      return false;
    } catch (e) {
      print('❌ Error verifying location: $e');
      return false;
    }
  }

  /// Get place details by place ID
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = GooglePlacesConfig.buildPlaceDetailsUrl(placeId);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting place details: $e');
      return null;
    }
  }
}