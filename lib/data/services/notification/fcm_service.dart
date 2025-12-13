import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

import '../../../config/env_config.dart';
import '../../../features/event/models/event_model.dart';
import '../../../features/event/screens/event_detail/event_detail.dart';
import '../../repositories/event/event_repository.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin _localNotifications;

  static const String _lastUserIdKey = 'last_known_user_id';

  /// Deep Link 相关属性
  static const String _appScheme = 'saveearth'; // 替换为你的 app scheme
  static const String _deepLinkHost = 'event';
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      await _initializeLocalNotifications();

      // Request notification permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      print('Notification permission granted: ${settings.authorizationStatus}');

      // Get and save FCM token
      await _getAndSaveFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Setup auth state listener
      _setupAuthStateListener();

      // Initialize Deep Links
      await _initializeAppLinks();

      print('FCM Service initialized successfully');
    } catch (e) {
      print('Error initializing FCM Service: $e');
    }
  }

  /// Initialize App Links
  Future<void> _initializeAppLinks() async {
    try {
      _appLinks = AppLinks();

      // 处理冷启动时的初始链接 - 使用正确的 API
      final initialLink = await getInitialAppLink();
      if (initialLink != null) {
        print('Initial app link: $initialLink');
        _handleDeepLink(initialLink);
      }

      // 设置链接监听器
      _setupAppLinkHandlers();

      print('App Links initialized successfully');
    } catch (e) {
      print('Error initializing App Links: $e');
    }
  }

  /// 获取初始 App Link - 使用正确的 API
  Future<String?> getInitialAppLink() async {
    try {
      // 尝试获取 URI
      final uri = await _appLinks.getInitialLink();
      return uri?.toString();
    } catch (e) {
      print('Error getting initial app link: $e');
      return null;
    }
  }

  /// 设置 App Link 监听器
  void _setupAppLinkHandlers() {
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      print('Received app link: $uri');
      _handleDeepLink(uri.toString());
    }, onError: (err) {
      print('Error in app link stream: $err');
    });
  }

  /// 处理 Deep Link
  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);

      // 验证 scheme 和 host
      if (uri.scheme == _appScheme && uri.host == _deepLinkHost) {
        final pathSegments = uri.pathSegments;

        if (pathSegments.isNotEmpty) {
          final eventId = pathSegments.first;
          if (eventId.isNotEmpty) {
            print('Deep link navigating to event: $eventId');
            _navigateToEventDetails(eventId);
          }
        }
      } else {
        print('Invalid deep link format: $link');
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }

  /// 生成 Event 的 Deep Link URL
  String generateEventDeepLink(String eventId) {
    return '$_appScheme://$_deepLinkHost/$eventId';
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response);
      },
    );

    await _createNotificationChannels();
  }

  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel eventRemindersChannel =
    AndroidNotificationChannel(
      'event_reminders',
      'Event Reminders',
      description: 'Notifications for upcoming event reminders',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventRemindersChannel);
  }

  /// Handle notification response
  void _handleNotificationResponse(NotificationResponse response) {
    Map<String, dynamic>? payloadMap;
    if (response.payload != null) {
      try {
        payloadMap = json.decode(response.payload!) as Map<String, dynamic>;
      } catch (e) {
        print('Failed to parse notification payload: $e');
      }
    }
    _handleNotificationClick(payloadMap);
  }

  /// Get and save FCM token
  Future<void> _getAndSaveFCMToken() async {
    try {
      String? token = await _messaging.getToken();

      if (token != null) {
        await _saveTokenToFirestore(token);
        print('FCM Token obtained: $token');
      } else {
        print('Failed to get FCM token');
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
        print('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Save token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      String? userId = _getCurrentUserId();

      if (userId == null) {
        print('⚠️ No user logged in, token not saved to Firestore');
        return;
      }

      // 🆕 Step 1: 检查用户文档是否存在
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('⚠️ User document does not exist yet, skipping FCM token save');
        print('💡 Token will be saved when user record is created');
        return;
      }

      // 🆕 Step 2: 验证文档是否包含完整数据
      final data = userDoc.data();

      if (data == null) {
        print('⚠️ User document data is null, skipping FCM token save');
        return;
      }

      // 🆕 Step 3: 检查必需字段
      final hasUsername = data.containsKey('username');
      final hasEmail = data.containsKey('email');
      final hasRole = data.containsKey('role');

      if (!hasUsername || !hasEmail || !hasRole) {
        print('⚠️ User document incomplete:');
        print('   - username: $hasUsername');
        print('   - email: $hasEmail');
        print('   - role: $hasRole');
        print('   - Available fields: ${data.keys.toList()}');
        print('💡 Skipping FCM token save until user record is complete');
        return;
      }

      // ✅ Step 4: 用户记录完整，保存 FCM Token
      // 🆕 使用 update 而不是 set，避免创建新文档
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });

      print('✅ FCM token saved successfully for user $userId');
      print('🔔 Token: ${token.substring(0, 20)}...');

      await _saveUserId(userId);

    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        print('⚠️ User document not found (expected for new users)');
      } else {
        print('⚠️ Firebase error saving FCM token: ${e.code} - ${e.message}');
      }
    } catch (e) {
      print('⚠️ Error saving FCM token to Firestore: $e');
    }
  }

  /// Get current user ID
  String? _getCurrentUserId() {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        _handleNotificationClick(message.data);
      }
    });
  }

  /// Setup auth state listener
  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        print('User logged in, refreshing FCM token for user: ${user.uid}');
        await _saveUserId(user.uid);
        await _getAndSaveFCMToken();
      } else {
        print('User logged out, clearing local user data');
        await _clearTokensOnLogout();
      }
    });
  }

  /// Save user ID to local storage
  Future<void> _saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUserIdKey, userId);
      print('User ID saved to local storage: $userId');
    } catch (e) {
      print('Error saving user ID: $e');
    }
  }

  /// Get last known user ID
  Future<String?> _getLastKnownUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUserIdKey);
    } catch (e) {
      print('Error getting last user ID: $e');
      return null;
    }
  }

  /// Clear tokens on logout
  Future<void> _clearTokensOnLogout() async {
    try {
      final lastKnownUserId = await _getLastKnownUserId();

      if (lastKnownUserId != null) {
        await _firestore.collection('users').doc(lastKnownUserId).update({
          'fcmTokens': FieldValue.delete(),
          'lastLogout': FieldValue.serverTimestamp(),
        });
        print('FCM tokens cleared for user $lastKnownUserId on logout');
      } else {
        print('No known user ID to clear tokens');
      }
    } catch (e) {
      print('Error clearing tokens on logout: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for event reminders',
      importance: Importance.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 准备通知数据，包含 deep link
    final notificationData = Map<String, dynamic>.from(message.data);

    // 如果没有 deep_link，自动生成一个
    if (notificationData['eventId'] != null && notificationData['deep_link'] == null) {
      final eventId = notificationData['eventId'];
      notificationData['deep_link'] = generateEventDeepLink(eventId);
    }

    try {
      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'Event Reminder',
        message.notification?.body ?? 'You have an upcoming event!',
        details,
        payload: jsonEncode(notificationData), // 使用包含 deep link 的数据
      );
      print('Local notification shown with deep link');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  /// Handle notification click - 修改为支持 Deep Link
  void _handleNotificationClick(Map<String, dynamic>? data) {
    if (data != null) {
      final type = data['type'];
      final eventId = data['eventId'];
      final userId = data['userId'];
      final deepLink = data['deep_link']; // 新增 deep_link 字段

      print('Notification clicked - Type: $type, Event ID: $eventId, User ID: $userId, Deep Link: $deepLink');

      final currentUserId = _getCurrentUserId();
      if (userId != null && currentUserId != null && userId != currentUserId) {
        print('Notification does not belong to current user. Expected: $currentUserId, Got: $userId');
        return;
      }

      // 优先使用 deep_link
      if (deepLink != null && deepLink is String) {
        _handleDeepLink(deepLink);
      } else if (type == 'event_reminder' && eventId != null) {
        _navigateToEventDetails(eventId);
      } else {
        print('Unknown notification type or missing data: $type');
      }
    } else {
      print('Notification clicked but no data provided');
    }
  }

  /// Navigate to event details
  void _navigateToEventDetails(String eventId) {
    try {
      Get.to(() => _EventDetailScreenWrapper(eventId: eventId));
      print('Navigated to event details for event: $eventId');
    } catch (e) {
      print('Error navigating to event details: $e');
    }
  }

  // ==================== Public Methods ====================

  /// Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting current token: $e');
      return null;
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Clear all tokens (manual clear)
  Future<void> clearTokens() async {
    try {
      String? userId = _getCurrentUserId();
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.delete(),
        });
        print('FCM tokens cleared for user $userId');
      }
    } catch (e) {
      print('Error clearing FCM tokens: $e');
    }
  }

  /// 生成测试用的 Deep Link（用于开发测试）
  String generateTestDeepLink(String eventId) {
    return generateEventDeepLink(eventId);
  }

  /// 手动触发 Deep Link（用于测试）
  void triggerTestDeepLink(String eventId) {
    final deepLink = generateEventDeepLink(eventId);
    _handleDeepLink(deepLink);
  }

  Future<void> sendBulkNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String eventId,
    required String type,
  }) async {
    try {
      if (userIds.isEmpty) {
        print('No users to send notification to');
        return;
      }

      print('🚀 Starting bulk notification to ${userIds.length} users');
      print('📢 Title: $title');
      print('📝 Body: $body');
      print('🎯 Event ID: $eventId');
      print('🔔 Type: $type');

      // 1. 获取所有用户的 FCM tokens
      final tokens = await _getUserFCMTokens(userIds);

      if (tokens.isEmpty) {
        print('❌ No FCM tokens found for users: $userIds');
        return;
      }

      print('✅ Found ${tokens.length} FCM tokens');

      // 2. 使用 v1 API 发送通知
      await _sendBulkFCMNotification(
        tokens: tokens,
        title: title,
        body: body,
        data: {
          'type': type,
          'eventId': eventId,
          'title': title,
          'body': body,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'deep_link': generateEventDeepLink(eventId),
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      print('🎉 Successfully sent bulk notification to ${tokens.length} devices');

    } catch (e) {
      print('❌ Error in sendBulkNotificationToUsersV1: $e');
      rethrow;
    }
  }

  Future<void> _sendBulkFCMNotification({
    required List<String> tokens,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // 获取访问令牌
      final accessToken = await _getAccessToken();

      final List<Future<void>> sendFutures = [];

      for (final token in tokens) {
        final future = _sendSingleFCM(
          token: token,
          title: title,
          body: body,
          data: data,
          accessToken: accessToken,
        );
        sendFutures.add(future);

        // 添加延迟避免速率限制
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await Future.wait(sendFutures);
    } catch (e) {
      print('Error in _sendBulkFCMNotificationV1: $e');
      rethrow;
    }
  }

  /// 获取 Google OAuth2 访问令牌
  Future<String> _getAccessToken() async {
    try {
      // 直接使用 EnvConfig 中的值构建服务账户信息，避免字符串插值问题
      final serviceAccountInfo = {
        "type": "service_account",
        "project_id": EnvConfig.fcmProjectId,
        "private_key_id": EnvConfig.fcmPrivateKeyId,
        "private_key": EnvConfig.fcmPrivateKey,
        "client_email": EnvConfig.fcmClientEmail,
        "client_id": EnvConfig.fcmClientId,
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "token_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
      };

      final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccountInfo);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final authClient = await auth.clientViaServiceAccount(credentials, scopes);

      // 获取访问令牌字符串
      final accessToken = authClient.credentials.accessToken.data;
      authClient.close();

      return accessToken;
    } catch (e) {
      print('❌ Error getting access token: $e');
      rethrow;
    }
  }

  /// 发送单个 FCM v1 通知
  Future<void> _sendSingleFCM({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String accessToken,
  }) async {
    try {
      final projectId = EnvConfig.fcmProjectId;
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data.map((key, value) => MapEntry(key, value.toString())),
          'android': {
            'priority': 'HIGH',
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
            },
            'payload': {
              'aps': {
                'badge': 1,
                'sound': 'default',
                'content-available': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('✅ FCM v1 sent to token: ${token.substring(0, 10)}...');
      } else {
        print('❌ FCM v1 failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ FCM v1 error for token ${token.substring(0, 10)}...: $e');
    }
  }

  /// 获取多个用户的 FCM tokens
  Future<List<String>> _getUserFCMTokens(List<String> userIds) async {
    try {
      final tokens = <String>[];

      // 分批获取用户数据（避免 Firestore 查询限制）
      const batchSize = 10;
      for (var i = 0; i < userIds.length; i += batchSize) {
        final batchUserIds = userIds.sublist(
            i,
            i + batchSize > userIds.length ? userIds.length : i + batchSize
        );

        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batchUserIds)
            .get();

        for (final userDoc in usersSnapshot.docs) {
          final data = userDoc.data();
          final userTokens = data['fcmTokens'] as List<dynamic>?;

          if (userTokens != null && userTokens.isNotEmpty) {
            tokens.addAll(userTokens.cast<String>());
          }
        }
      }

      // 去重
      return tokens.toSet().toList();
    } catch (e) {
      print('Error getting user FCM tokens: $e');
      return [];
    }
  }

  /// 通过 HTTP 请求发送 FCM 通知
  Future<void> _sendFCMViaHttp({
    required List<String> tokens,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // FCM 服务器密钥 - 需要从 Firebase Console 获取
      final String serverKey = EnvConfig.fcmServerKey;

      if (serverKey == 'YOUR_FCM_SERVER_KEY') {
        print('⚠️ Please set FCM_SERVER_KEY');
        return;
      }

      final List<Future<void>> sendFutures = [];

      // 为每个 token 发送单独的通知
      for (final token in tokens) {
        final future = _sendSingleFCMNotification(
          token: token,
          title: title,
          body: body,
          data: data,
          serverKey: serverKey,
        );
        sendFutures.add(future);

        // 添加小延迟避免速率限制
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // 并行发送所有通知
      await Future.wait(sendFutures);

    } catch (e) {
      print('Error sending FCM via HTTP: $e');
      rethrow;
    }
  }

  /// 发送单个 FCM 通知 - 使用 HTTP 请求
  Future<void> _sendSingleFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String serverKey,
  }) async {
    try {
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final message = {
        'to': token,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'badge': '1',
        },
        'data': data,
        'android': {
          'priority': 'high',
        },
        'apns': {
          'payload': {
            'aps': {
              'contentAvailable': true,
              'badge': 1,
              'sound': 'default',
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == 1) {
          print('✅ FCM sent to token: ${token.substring(0, 10)}... - Success');
        } else {
          print('❌ FCM failed for token: ${token.substring(0, 10)}... - ${responseData['results']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} for token: ${token.substring(0, 10)}...');
      }
    } catch (e) {
      print('❌ Failed to send FCM to token: ${token.substring(0, 10)}... - Error: $e');
      // 不抛出异常，继续发送其他通知
    }
  }

  /// 清理资源
  void dispose() {
    _linkSubscription?.cancel();
    print('FCM Service disposed');
  }
}

/// Wrapper widget for event details screen
class _EventDetailScreenWrapper extends StatelessWidget {
  final String eventId;

  const _EventDetailScreenWrapper({required this.eventId});

  @override
  Widget build(BuildContext context) {
    final eventRepository = Get.put(EventRepository());

    return StreamBuilder<Event>(
      stream: eventRepository.getEventById(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading event: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Event not found')),
          );
        }

        final event = snapshot.data!;
        return EventDetailsScreen(event: event);
      },
    );
  }
}