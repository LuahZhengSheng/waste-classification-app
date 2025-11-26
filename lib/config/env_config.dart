import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _initialized = false;
  static bool _usingFallback = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Loading environment configuration...');
      await _loadEnvFile();
      _initialized = true;
      print('✅ Environment configuration loaded successfully');

    } catch (e) {
      print('❌ Environment configuration failed: $e');
      _usingFallback = true;
      _initialized = true;
      print('🔄 Using fallback values');
    }
  }

  static Future<void> _loadEnvFile() async {
    try {
      // 从 assets 加载
      await dotenv.load(fileName: "../../.env");
      print('✅ .env file loaded');

      // 验证必需变量
      _validateRequiredVariables();

    } catch (e) {
      print('❌ Failed to load .env: $e');
      rethrow;
    }
  }

  static void _validateRequiredVariables() {
    final requiredVars = [
      'JWT_SECRET_KEY',
      'BASE_URL',
      'API_KEY',
      'API_SECRET',
      'GOOGLE_PLACES_API_KEY',
      'SENDGRID_API_KEY',
      'FCM_SERVER_KEY',
      'FCM_PRIVATE_KEY',
      'FCM_PRIVATE_KEY_ID',
      'FCM_CLIENT_EMAIL',
      'FCM_CLIENT_ID',
      'FCM_PROJECT_ID',
    ];

    for (final key in requiredVars) {
      try {
        var value = dotenv.get(key);

        // 如果值为空，抛出异常
        if (value.isEmpty) {
          throw Exception('$key is empty');
        } else {
          // 清理值（移除空格等）
          value = value.trim();
          if (key != 'FCM_PRIVATE_KEY' && value.contains(' ')) {
            // FCM_PRIVATE_KEY 可能包含空格，其他密钥不应该包含空格
            throw Exception('$key contains spaces');
          } else {
            // 对于敏感信息，只显示前几个字符
            final displayLength = _getDisplayLength(key, value.length);
            print('✅ $key: ${value.substring(0, displayLength)}...');
          }
        }
      } catch (e) {
        print('❌ $key validation failed: $e');
        throw Exception('Required environment variable $key is invalid');
      }
    }
  }

  // 根据密钥类型确定显示长度
  static int _getDisplayLength(String key, int maxLength) {
    switch (key) {
      case 'FCM_PRIVATE_KEY':
        return 20; // 私钥显示前20个字符
      case 'JWT_SECRET_KEY':
      case 'API_SECRET':
      case 'SENDGRID_API_KEY':
      case 'FCM_SERVER_KEY':
        return 8; // 敏感密钥显示前8个字符
      default:
        return min.clamp(0, maxLength);
    }
  }

  static int get min => 4;

  // Getter 方法 - 原有密钥
  static String get jwtSecretKey => _getKey('JWT_SECRET_KEY');
  static String get baseUrl => _getKey('BASE_URL');
  static String get apiKey => _getKey('API_KEY');
  static String get apiSecret => _getKey('API_SECRET');
  static String get googlePlacesApiKey => _getKey('GOOGLE_PLACES_API_KEY');
  static String get sendGridApiKey => _getKey('SENDGRID_API_KEY');
  static String get fcmServerKey => _getKey('FCM_SERVER_KEY');
  static bool get debug => _getBool('DEBUG', true);

  // Getter 方法 - 新增 FCM 服务账户密钥
  static String get fcmPrivateKey => _getKey('FCM_PRIVATE_KEY');
  static String get fcmPrivateKeyId => _getKey('FCM_PRIVATE_KEY_ID');
  static String get fcmClientEmail => _getKey('FCM_CLIENT_EMAIL');
  static String get fcmClientId => _getKey('FCM_CLIENT_ID');
  static String get fcmProjectId => _getKey('FCM_PROJECT_ID');

  static String _getKey(String key) {
    if (!_initialized) {
      throw Exception('EnvConfig not initialized. Call initialize() first.');
    }

    try {
      final value = dotenv.get(key);
      if (value.isEmpty) {
        throw Exception('$key is empty');
      }
      return value;
    } catch (e) {
      print('❌ Error getting $key: $e');
      throw Exception('Failed to get environment variable: $key');
    }
  }

  static bool _getBool(String key, bool fallback) {
    try {
      if (!_initialized) return fallback;
      final value = dotenv.get(key, fallback: fallback.toString());
      return value.toLowerCase() == 'true';
    } catch (e) {
      return fallback;
    }
  }

  // 新增：验证 FCM 配置的方法
  static void validateFCMConfig() {
    if (!_initialized) {
      throw Exception('EnvConfig not initialized. Call initialize() first.');
    }

    try {
      print('🔧 Validating FCM configuration...');

      // 检查 FCM 服务器密钥格式
      final serverKey = fcmServerKey;
      if (!serverKey.startsWith('AAAA')) {
        print('⚠️ FCM_SERVER_KEY may be invalid - should start with AAAA');
      }

      // 检查私钥格式
      final privateKey = fcmPrivateKey;
      if (!privateKey.contains('BEGIN PRIVATE KEY') || !privateKey.contains('END PRIVATE KEY')) {
        print('⚠️ FCM_PRIVATE_KEY format may be invalid');
      }

      // 检查客户端邮箱格式
      final clientEmail = fcmClientEmail;
      if (!clientEmail.contains('@') || !clientEmail.endsWith('.gserviceaccount.com')) {
        print('⚠️ FCM_CLIENT_EMAIL format may be invalid');
      }

      print('✅ FCM configuration validation completed');
    } catch (e) {
      print('❌ FCM configuration validation failed: $e');
      rethrow;
    }
  }

  // 新增：获取 FCM 服务账户 JSON（用于直接使用）
  static Map<String, dynamic> get fcmServiceAccountJson {
    return {
      'type': 'service_account',
      'project_id': fcmProjectId,
      'private_key_id': fcmPrivateKeyId,
      'private_key': fcmPrivateKey,
      'client_email': fcmClientEmail,
      'client_id': fcmClientId,
      'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
      'token_uri': 'https://oauth2.googleapis.com/token',
    };
  }
}

class AppConfig {
  static String get appName => 'SaveEarth App';
  static String get version => '1.0.0';
}