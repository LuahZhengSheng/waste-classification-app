import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/services/google_places/google_places_service.dart';
import '../../../utils/constants/google_maps_config.dart';
import '../../../config/google_maps_config.dart';
import '../../event/models/address_model.dart';
import '../../event/models/geopoint_model.dart';
import '../../event/models/location_model.dart';

enum OpeningHoursFilter { anyTime, openNow, open24Hours }

class DropoffLocationsController extends GetxController {
  static DropoffLocationsController get instance => Get.find();

  final centerRepository = Get.put(RecyclingCenterRepository());
  final wasteCategoryRepository = Get.put(WasteCategoryRepository());
  final googlePlacesService = GooglePlacesService();

  // Observables
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> searchedLocation = Rx<LatLng?>(null);
  final RxList<PartnerRecyclingCenter> allCenters = <PartnerRecyclingCenter>[].obs;
  final RxList<PartnerRecyclingCenter> filteredCenters = <PartnerRecyclingCenter>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rx<PartnerRecyclingCenter?> selectedCenter = Rx<PartnerRecyclingCenter?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isMapReady = false.obs;
  final RxString searchQuery = ''.obs;
  final RxDouble currentRadius = (GoogleMapsConfig.defaultSearchRadiusKm * 1000).obs;
  final RxBool showPartnerOnly = false.obs;
  final RxDouble minRating = 0.0.obs;
  final RxList<String> selectedMaterials = <String>[].obs;
  final RxBool isSearchMode = false.obs;
  final Rx<OpeningHoursFilter> openingHoursFilter = OpeningHoursFilter.anyTime.obs;
  final RxList<String> availableMaterials = <String>[].obs;

  // Map controller
  Completer<GoogleMapController> mapController = Completer();

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
    _loadAvailableMaterials();
  }

  @override
  void onClose() {
    try {
      mapController.future.then((controller) => controller.dispose());
    } catch (e) {
      print('Error disposing map controller: $e');
    }
    super.onClose();
  }

  /// Load available materials from waste categories
  Future<void> _loadAvailableMaterials() async {
    try {
      final categories = await wasteCategoryRepository.getAllWasteCategories();
      final materials = categories
          .where((cat) => cat.isRecyclable)
          .map((cat) => cat.name)
          .toSet()
          .toList();
      availableMaterials.value = materials;
      print('✅ Loaded ${materials.length} available materials');
    } catch (e) {
      print('❌ Error loading materials: $e');
      // Fallback to default materials
      availableMaterials.value = [
        'Plastic',
        'Paper',
        'Glass',
        'Metal',
        'Electronics',
        'Cardboard',
        'Aluminum',
        'Batteries',
      ];
    }
  }

  /// Initialize user location and load nearby centers
  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      print('🚀 Initializing location...');

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied, using default location');
        FLoaders.errorSnackBar(
          title: 'Location Permission Required',
          message: 'Please enable location to view nearby recycling centers.',
        );
        currentLocation.value = LatLng(
          GooglePlacesConfig.defaultLocation['lat']!,
          GooglePlacesConfig.defaultLocation['lng']!,
        );
      } else {
        print('📍 Getting current location...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        currentLocation.value = LatLng(position.latitude, position.longitude);
        print('✅ Current location: ${currentLocation.value}');
      }

      await _searchAndFilterCenters();

      if (currentLocation.value != null && isMapReady.value) {
        try {
          final controller = await mapController.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation.value!,
                zoom: GoogleMapsConfig.defaultZoom,
              ),
            ),
          );
        } catch (e) {
          print('❌ Error moving camera: $e');
        }
      }
    } catch (e) {
      print('💥 Error initializing location: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to get location: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Main search and filter method
  Future<void> _searchAndFilterCenters() async {
    try {
      print('🔍 Starting search and filter...');
      isLoading.value = true;

      final targetLocation = isSearchMode.value ? searchedLocation.value : currentLocation.value;
      if (targetLocation == null) {
        print('❌ No target location available');
        return;
      }

      // Step 1: Get centers from Google Places API
      print('📥 Fetching from Google Places API...');
      final googleCenters = await googlePlacesService.searchNearbyRecyclingCenters(
        latitude: targetLocation.latitude,
        longitude: targetLocation.longitude,
        radius: GooglePlacesConfig.validateRadius(currentRadius.value.toInt()),
        includeDetails: true,
      );

      print('✅ Found ${googleCenters.length} centers from Google Places');

      // Step 2: Get partner centers from Firestore
      print('📥 Fetching partner centers from Firestore...');
      final partnerCenters = await centerRepository.getAllActiveCenters();
      print('✅ Found ${partnerCenters.length} partner centers from Firestore');

      // Step 3: Batch calculate distances
      print('📏 Calculating driving distances...');
      final allLocations = <Map<String, double>>[];
      final locationToCenterMap = <String, dynamic>{};

      // Collect all locations
      for (final googlePlace in googleCenters) {
        final geometry = googlePlace['geometry'] ?? {};
        final location = geometry['location'] ?? {};
        final lat = location['lat']?.toDouble() ?? 0.0;
        final lng = location['lng']?.toDouble() ?? 0.0;
        final key = '$lat,$lng';

        allLocations.add({'lat': lat, 'lng': lng});
        locationToCenterMap[key] = {'type': 'google', 'data': googlePlace};
      }

      for (final partner in partnerCenters) {
        final lat = partner.centerLocation.geoPoint.latitude;
        final lng = partner.centerLocation.geoPoint.longitude;
        final key = '$lat,$lng';

        if (!locationToCenterMap.containsKey(key)) {
          allLocations.add({'lat': lat, 'lng': lng});
          locationToCenterMap[key] = {'type': 'partner', 'data': partner};
        }
      }

      // Batch calculate distances
      final distances = await googlePlacesService.batchCalculateDistances(
        originLat: targetLocation.latitude,
        originLng: targetLocation.longitude,
        destinations: allLocations,
      );

      print('✅ Calculated ${distances.length} distances');

      // Step 4: Merge results with distances
      final mergedCenters = await _mergeCentersWithDistances(
        googleCenters,
        partnerCenters,
        distances,
        targetLocation,
      );

      print('✅ Merged to ${mergedCenters.length} total centers');

      allCenters.value = mergedCenters;
      applyFilters();

    } catch (e) {
      print('❌ Error in search and filter: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load centers',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Merge Google Places centers with Partner centers and distances
  Future<List<PartnerRecyclingCenter>> _mergeCentersWithDistances(
      List<Map<String, dynamic>> googleCenters,
      List<PartnerRecyclingCenter> partnerCenters,
      Map<String, double> distances,
      LatLng targetLocation,
      ) async {
    final Map<String, PartnerRecyclingCenter> centerMap = {};
    final Map<String, Map<String, dynamic>> googleDataByPlaceId = {};

    // Build Google data lookup map
    for (final googlePlace in googleCenters) {
      final placeId = googlePlace['place_id'] as String?;
      if (placeId != null) {
        googleDataByPlaceId[placeId] = googlePlace;
      }
    }

    // Process partner centers first
    for (final partner in partnerCenters) {
      final placeId = partner.centerLocation.address.placeId;

      // Get distance for this partner center
      final lat = partner.centerLocation.geoPoint.latitude;
      final lng = partner.centerLocation.geoPoint.longitude;
      final key = '$lat,$lng';
      final distance = distances[key];

      // Only include if within radius
      if (distance != null && distance <= currentRadius.value / 1000) {
        // Check if we have Google data for this partner center
        Map<String, dynamic>? googleData;
        if (placeId != null && googleDataByPlaceId.containsKey(placeId)) {
          googleData = googleDataByPlaceId[placeId];
        }

        // Update partner with Google data (especially rating) if available
        if (googleData != null) {
          centerMap[placeId!] = partner.copyWith(
            rating: googleData['rating']?.toDouble() ?? partner.rating,
            userRatingsTotal: googleData['user_ratings_total'] ?? partner.userRatingsTotal,
            openingHours: googleData['opening_hours'] ?? partner.openingHours,
            drivingDistance: distance,
          );
        } else {
          // No Google data, but still include the partner center
          centerMap[placeId ?? partner.centerId] = partner.copyWith(
            drivingDistance: distance,
          );
        }
      }
    }

    // Process Google Places results (non-partner centers)
    for (final googlePlace in googleCenters) {
      final placeId = googlePlace['place_id'] as String?;
      if (placeId == null) continue;

      // Skip if already added as partner center
      if (centerMap.containsKey(placeId)) continue;

      final geometry = googlePlace['geometry'] ?? {};
      final location = geometry['location'] ?? {};
      final lat = location['lat']?.toDouble() ?? 0.0;
      final lng = location['lng']?.toDouble() ?? 0.0;
      final key = '$lat,$lng';
      final distance = distances[key];

      // Only include if within radius
      if (distance != null && distance <= currentRadius.value / 1000) {
        final center = _convertToNonPartnerCenter(googlePlace, distance);
        centerMap[placeId] = center;
      }
    }

    // For partner centers without placeId, check by location
    for (final partner in partnerCenters) {
      final placeId = partner.centerLocation.address.placeId;

      // Skip if already processed
      if (placeId != null && centerMap.containsKey(placeId)) continue;

      // Check by location
      final lat = partner.centerLocation.geoPoint.latitude;
      final lng = partner.centerLocation.geoPoint.longitude;
      final key = '$lat,$lng';
      final distance = distances[key];

      if (distance != null && distance <= currentRadius.value / 1000) {
        final mapKey = placeId ?? partner.centerId;

        // Try to find matching Google data by location
        Map<String, dynamic>? matchingGoogleData;
        for (final googlePlace in googleCenters) {
          final googleGeometry = googlePlace['geometry'] ?? {};
          final googleLocation = googleGeometry['location'] ?? {};
          final googleLat = googleLocation['lat']?.toDouble() ?? 0.0;
          final googleLng = googleLocation['lng']?.toDouble() ?? 0.0;

          // Check if coordinates match (within 100m)
          final distanceBetween = _calculateStraightDistance(lat, lng, googleLat, googleLng);
          if (distanceBetween < 0.1) { // Less than 100m
            matchingGoogleData = googlePlace;
            break;
          }
        }

        if (matchingGoogleData != null) {
          centerMap[mapKey] = partner.copyWith(
            rating: matchingGoogleData['rating']?.toDouble() ?? partner.rating,
            userRatingsTotal: matchingGoogleData['user_ratings_total'] ?? partner.userRatingsTotal,
            openingHours: matchingGoogleData['opening_hours'] ?? partner.openingHours,
            drivingDistance: distance,
          );
        } else {
          centerMap[mapKey] = partner.copyWith(
            drivingDistance: distance,
          );
        }
      }
    }

    return centerMap.values.toList();
  }

  /// Calculate straight-line distance in km (for matching nearby locations)
  double _calculateStraightDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Convert Google Places data to non-partner center
  PartnerRecyclingCenter _convertToNonPartnerCenter(Map<String, dynamic> place, double distance) {
    final geometry = place['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    String imageUrl = '';
    final photos = place['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final photoReference = photos.first['photo_reference'] as String?;
      if (photoReference != null) {
        imageUrl = GooglePlacesConfig.buildPhotoUrl(
          photoReference,
          maxWidth: GooglePlacesConfig.highResPhotoMaxWidth,
        );
      }
    }

    return PartnerRecyclingCenter(
      centerId: place['place_id'] ?? '',
      name: place['name'] ?? '',
      email: '',
      phoneNo: place['formatted_phone_number'] ?? '',
      website: place['website'] ?? '',
      centerLocation: Location(
        address: Address(
          unitNo: '',
          area: '',
          postcode: '',
          city: '',
          state: '',
          fullAddress: place['formatted_address'],
          placeId: place['place_id'],
        ),
        geoPoint: GeoPointModel(
          latitude: location['lat']?.toDouble() ?? 0.0,
          longitude: location['lng']?.toDouble() ?? 0.0,
        ),
      ),
      image: imageUrl,
      openingHours: place['opening_hours'],
      acceptedMaterials: [],
      numberOfStaff: 0,
      createdAt: DateTime.now(),
      status: 'non-partner',
      rating: place['rating']?.toDouble(),
      userRatingsTotal: place['user_ratings_total'],
      drivingDistance: distance,
    );
  }

  /// Handle location permission
  Future<bool> _handleLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;
      return true;
    } catch (e) {
      print('❌ Error handling location permission: $e');
      return false;
    }
  }

  /// Apply filters
  void applyFilters() {
    try {
      print('🎯 Applying filters...');
      List<PartnerRecyclingCenter> filtered = List.from(allCenters);

      // Partner filter
      if (showPartnerOnly.value) {
        filtered = filtered.where((c) => c.status == 'active').toList();
      }

      // Rating filter
      if (minRating.value > 0) {
        filtered = filtered.where((c) => (c.rating ?? 0) >= minRating.value).toList();
      }

      // Material filter (only for partner centers)
      if (selectedMaterials.isNotEmpty && showPartnerOnly.value) {
        filtered = filtered.where((center) {
          return selectedMaterials.any((material) => center.acceptsMaterial(material));
        }).toList();
      }

      // Opening hours filter
      if (openingHoursFilter.value == OpeningHoursFilter.openNow) {
        filtered = filtered.where((c) => c.isOpenNow).toList();
      } else if (openingHoursFilter.value == OpeningHoursFilter.open24Hours) {
        filtered = filtered.where((c) => _isOpen24Hours(c)).toList();
      }

      filteredCenters.value = filtered;
      print('✅ Filtered to ${filtered.length} centers');
      updateMarkers();
    } catch (e) {
      print('❌ Error applying filters: $e');
    }
  }

  /// Check if center is open 24 hours
  bool _isOpen24Hours(PartnerRecyclingCenter center) {
    if (center.openingHours == null) return false;
    final periods = center.openingHours!['periods'] as List<dynamic>?;
    if (periods == null || periods.isEmpty) return false;
    return periods.length == 1 && periods[0]['open']?['time'] == '0000';
  }

  /// Update map markers
  void updateMarkers() {
    try {
      print('📍 Updating markers...');
      final Set<Marker> newMarkers = {};

      for (var center in filteredCenters) {
        final bool isPartner = center.status == 'active';
        final BitmapDescriptor markerIcon = isPartner
            ? BitmapDescriptor.defaultMarkerWithHue(GoogleMapsConfig.partnerPinHue)
            : BitmapDescriptor.defaultMarkerWithHue(GoogleMapsConfig.otherPinHue);

        newMarkers.add(
          Marker(
            markerId: MarkerId(center.centerId),
            position: LatLng(
              center.centerLocation.geoPoint.latitude,
              center.centerLocation.geoPoint.longitude,
            ),
            icon: markerIcon,
            onTap: () => selectCenter(center),
            infoWindow: InfoWindow(
              title: center.name,
              snippet: '${isPartner ? '🤝 Partner' : '📍 Center'} • ${center.formattedDistance}${center.rating != null ? ' • ⭐${center.rating}' : ''}',
            ),
          ),
        );
      }

      markers.value = newMarkers;
      print('✅ Updated ${newMarkers.length} markers');
    } catch (e) {
      print('❌ Error updating markers: $e');
    }
  }

  /// Calculate distance
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Format distance
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Select center
  void selectCenter(PartnerRecyclingCenter center) {
    selectedCenter.value = center;
  }

  /// Deselect center
  void deselectCenter() {
    selectedCenter.value = null;
  }

  /// Open navigation
  Future<void> openGoogleMapsNavigation(PartnerRecyclingCenter center) async {
    try {
      await FLoaders.showMapNavigationDialog(
        onConfirm: () async {
          final url = 'https://www.google.com/maps/dir/?api=1&destination=${center.centerLocation.geoPoint.latitude},${center.centerLocation.geoPoint.longitude}&travelmode=driving';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            FLoaders.errorSnackBar(
              title: 'Error',
              message: 'Could not open Google Maps',
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error opening navigation: $e');
    }
  }

  /// Search location
  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      returnToCurrentLocation();
      return;
    }

    try {
      isLoading.value = true;
      searchQuery.value = query;

      // Use API to determine place type
      print('🔍 Analyzing place query: $query');
      final placeInfo = await googlePlacesService.analyzePlaceQuery(query);

      if (placeInfo == null) {
        FLoaders.warningSnackBar(
          title: 'No Results',
          message: 'No locations found for "$query"',
        );
        return;
      }

      print('✅ Place type: ${placeInfo.type}');

      if (placeInfo.type == PlaceType.specificLocation) {
        // Specific location - show only this center
        await _handleSpecificLocationSearch(placeInfo);
      } else {
        // Region - show nearby centers
        await _handleRegionSearch(placeInfo);
      }
    } catch (e) {
      print('❌ Error searching location: $e');
      FLoaders.errorSnackBar(
        title: 'Search Error',
        message: 'Failed to search location',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle specific location search
  Future<void> _handleSpecificLocationSearch(PlaceInfo placeInfo) async {
    print('📍 Handling specific location search');

    searchedLocation.value = LatLng(placeInfo.latitude, placeInfo.longitude);
    isSearchMode.value = true;

    // Get place details
    final details = await googlePlacesService.getPlaceDetails(placeInfo.placeId);

    // IMPORTANT: Verify it's a recycling center
    // final types = List<String>.from(details['types'] ?? []);
    // if (!googlePlacesService.isRecyclingCenter(types)) {
    //   FLoaders.errorSnackBar(
    //     title: 'Not a Recycling Center',
    //     message: 'The location you searched is not a recycling center.',
    //   );
    //   isLoading.value = false;
    //   return;
    // }

    // Calculate driving distance
    final distance = await googlePlacesService.calculateDrivingDistance(
      originLat: currentLocation.value!.latitude,
      originLng: currentLocation.value!.longitude,
      destLat: placeInfo.latitude,
      destLng: placeInfo.longitude,
    );

    if (distance == null) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Could not calculate distance to this location.',
      );
      isLoading.value = false;
      return;
    }

    // Check if within search radius
    if (distance > currentRadius.value / 1000) {
      FLoaders.warningSnackBar(
        title: 'Outside Range',
        message: 'This center is ${distance.toStringAsFixed(1)} km away, which exceeds your search radius of ${(currentRadius.value / 1000).toStringAsFixed(1)} km.',
      );
    }

    // Check if it's a partner center
    final partnerCenters = await centerRepository.getAllActiveCenters();
    final matchingPartner = partnerCenters.firstWhereOrNull(
            (p) => p.centerLocation.address.placeId == placeInfo.placeId
    );

    PartnerRecyclingCenter center;
    if (matchingPartner != null) {
      // Use partner center with Google data
      center = matchingPartner.copyWith(
        rating: details['rating']?.toDouble(),
        userRatingsTotal: details['user_ratings_total'],
        openingHours: details['opening_hours'],
        drivingDistance: distance,
      );
    } else {
      // Create non-partner center with full details
      final geometry = details['geometry'] ?? {};
      final location = geometry['location'] ?? {};

      String imageUrl = '';
      final photos = details['photos'] as List<dynamic>?;
      if (photos != null && photos.isNotEmpty) {
        final photoReference = photos.first['photo_reference'] as String?;
        if (photoReference != null) {
          imageUrl = GooglePlacesConfig.buildPhotoUrl(
            photoReference,
            maxWidth: GooglePlacesConfig.highResPhotoMaxWidth,
          );
        }
      }

      center = PartnerRecyclingCenter(
        centerId: placeInfo.placeId,
        name: details['name'] ?? placeInfo.name,
        email: '',
        phoneNo: details['formatted_phone_number'] ?? '',
        website: details['website'] ?? '',
        centerLocation: Location(
          address: Address(
            unitNo: '',
            area: '',
            postcode: '',
            city: '',
            state: '',
            fullAddress: details['formatted_address'],
            placeId: placeInfo.placeId,
          ),
          geoPoint: GeoPointModel(
            latitude: location['lat']?.toDouble() ?? placeInfo.latitude,
            longitude: location['lng']?.toDouble() ?? placeInfo.longitude,
          ),
        ),
        image: imageUrl,
        openingHours: details['opening_hours'],
        acceptedMaterials: [],
        numberOfStaff: 0,
        createdAt: DateTime.now(),
        status: 'non-partner',
        rating: details['rating']?.toDouble(),
        userRatingsTotal: details['user_ratings_total'],
        drivingDistance: distance,
      );
    }

    // Show only this center
    allCenters.value = [center];
    applyFilters();

    // Move camera and auto-select
    final controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: searchedLocation.value!,
          zoom: GoogleMapsConfig.defaultZoom + 2,
        ),
      ),
    );

    // Auto-select center
    selectCenter(center);

    FLoaders.successSnackBar(
      title: 'Location Found',
      message: 'Showing: ${center.name} (${center.formattedDistance})',
    );
  }

  /// Handle region search
  Future<void> _handleRegionSearch(PlaceInfo placeInfo) async {
    print('📍 Handling region search');

    searchedLocation.value = LatLng(placeInfo.latitude, placeInfo.longitude);
    isSearchMode.value = true;

    await _searchAndFilterCenters();

    final controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: searchedLocation.value!,
          zoom: GoogleMapsConfig.defaultZoom,
        ),
      ),
    );

    FLoaders.successSnackBar(
      title: 'Location Found',
      message: 'Showing centers near ${placeInfo.name}',
    );
  }

  /// Return to current location
  Future<void> returnToCurrentLocation() async {
    try {
      if (currentLocation.value == null) return;

      isSearchMode.value = false;
      searchedLocation.value = null;
      searchQuery.value = '';

      await _searchAndFilterCenters();

      final controller = await mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation.value!,
            zoom: GoogleMapsConfig.defaultZoom,
          ),
        ),
      );

      FLoaders.successSnackBar(
        title: 'Returned',
        message: 'Showing centers near your location',
      );
    } catch (e) {
      print('❌ Error returning to current location: $e');
    }
  }

  /// Toggle partner filter
  void togglePartnerFilter() {
    showPartnerOnly.value = !showPartnerOnly.value;
    if (!showPartnerOnly.value) {
      selectedMaterials.clear();
    }
    applyFilters();
  }

  /// Update radius
  Future<void> updateRadius(double radiusKm) async {
    currentRadius.value = radiusKm * 1000;
    await _searchAndFilterCenters();
  }

  /// Update rating
  void updateMinRating(double rating) {
    minRating.value = rating;
    applyFilters();
  }

  /// Toggle material
  void toggleMaterialFilter(String material) {
    if (selectedMaterials.contains(material)) {
      selectedMaterials.remove(material);
    } else {
      selectedMaterials.add(material);
    }
    applyFilters();
  }

  /// Update opening hours filter
  void updateOpeningHoursFilter(OpeningHoursFilter filter) {
    openingHoursFilter.value = filter;
    applyFilters();
  }

  /// Clear filters
  void clearFilters() {
    searchQuery.value = '';
    showPartnerOnly.value = false;
    minRating.value = 0.0;
    currentRadius.value = GoogleMapsConfig.defaultSearchRadiusKm * 1000;
    selectedMaterials.clear();
    openingHoursFilter.value = OpeningHoursFilter.anyTime;
    applyFilters();
  }

  /// Get place count text
  String get placeCountText {
    final count = filteredCenters.length;
    final partnerCount = filteredCenters.where((c) => c.status == 'active').length;
    return '$count centers ($partnerCount partners)';
  }

  /// Refresh data
  Future<void> refreshData() async {
    await _searchAndFilterCenters();
    FLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Centers updated successfully',
    );
  }
}