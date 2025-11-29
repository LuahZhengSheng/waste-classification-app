import '../../config/env_config.dart';

class GoogleMapsConfig {
  GoogleMapsConfig._();

  // 改为延迟初始化的变量
  static String? _apiKey;
  static bool _initialized = false;

  // 初始化方法
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Initializing GoogleMapsConfig...');

      // 确保 EnvConfig 已初始化
      if (!EnvConfig.isInitialized) {
        await EnvConfig.initialize();
      }

      _apiKey = EnvConfig.googlePlacesApiKey;
      _initialized = true;
      print('✅ GoogleMapsConfig initialized successfully');
    } catch (e) {
      print('❌ GoogleMapsConfig initialization failed: $e');
      rethrow;
    }
  }

  static String get apiKey {
    if (!_initialized) {
      throw Exception('GoogleMapsConfig not initialized. Call initialize() first.');
    }
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Google Maps API key not configured. Please add your API key.');
    }
    return _apiKey!;
  }

  // Google Maps API endpoints
  static const String placesApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String directionsApiBaseUrl = 'https://maps.googleapis.com/maps/api/directions';
  static const String distanceMatrixApiBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix';

  // Default map settings
  static const double defaultZoom = 14.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;

  // Search radius settings (in km)
  static const double defaultSearchRadiusKm = 5.0;
  static const double minSearchRadiusKm = 1.0;
  static const double maxSearchRadiusKm = 50.0;

  // Nearby search settings
  static const int nearbySearchResultsPerRequest = 20;
  static const int maxNearbySearchPages = 3;

  // Search types
  static const List<String> recyclingCenterTypes = [
    'recycling_center',
    'waste_management',
  ];

  static const String recyclingCenterKeyword = 'recycling';

  // Map pin colors (BitmapDescriptor hue values)
  static const double partnerPinHue = 180.0; // Cyan
  static const double otherPinHue = 0.0; // Red
  static const double userLocationPinHue = 120.0; // Green

  // 使用模式：确保在使用前已初始化
  static T ensureInitialized<T>(T Function() fn) {
    if (!_initialized) {
      throw Exception('GoogleMapsConfig not initialized. Call initialize() before use.');
    }
    return fn();
  }

  // 检查初始化状态
  static bool get isInitialized => _initialized;

  // 重新初始化方法（用于热重载等场景）
  static Future<void> reinitialize() async {
    _initialized = false;
    _apiKey = null;
    await initialize();
  }
}