import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/admin/screens/authentication/admin_login.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'utils/constants/colors.dart';

class AuthStateListener {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void startListening() {
    print('🟢 [AuthStateListener] Starting auth state listener...');

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('👤 [AuthStateListener] User logged in: ${user.uid}');
        _setupMetadataListener(user.uid);
      } else {
        print('🚪 [AuthStateListener] User logged out');
      }
    });
  }

  void _setupMetadataListener(String uid) {
    print('🔧 [AuthStateListener] Setting up Firestore metadata listener for user: $uid');

    final metadataRef = _firestore.collection('metadata').doc(uid);

    metadataRef.snapshots().listen((DocumentSnapshot snapshot) {
      print('📡 [AuthStateListener] Firestore metadata snapshot received');

      if (snapshot.exists) {
        final metadata = snapshot.data() as Map<String, dynamic>?;
        print('📊 [AuthStateListener] Metadata: $metadata');

        if (metadata != null && metadata['refreshTime'] != null) {
          print('🔄 [AuthStateListener] Token refresh requested by server');
          _checkUserBanStatus(metadata);
        }
      } else {
        print('ℹ️ [AuthStateListener] No metadata document found');
      }
    }, onError: (error) {
      print('❌ [AuthStateListener] Error in Firestore listener: $error');
    });

    print('✅ [AuthStateListener] Firestore metadata listener setup completed');
  }

  Future<void> _checkUserBanStatus(Map<String, dynamic> metadata) async {
    print('🔍 [AuthStateListener] Starting ban status check...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ [AuthStateListener] No current user, user already logged out');
        return;
      }

      print('👤 [AuthStateListener] Current user: ${user.uid}');

      // 直接从 metadata 获取封禁状态，避免刷新 token
      final isBanned = metadata['banned'] == true;
      print('🚫 [AuthStateListener] Banned status from metadata: $isBanned');

      if (isBanned) {
        print('🚫 [AuthStateListener] Account is BANNED! Logging out...');

        // 先显示消息，再登出
        _showBanMessageAndNavigate();

        // 延迟一下再登出，确保消息显示
        await Future.delayed(Duration(seconds: 1));
        await _auth.signOut();
        print('✅ [AuthStateListener] User signed out successfully');
      } else {
        print('✅ [AuthStateListener] User is NOT banned, forcing token refresh to sync claims');
        // 如果不是封禁状态，才强制刷新 token 来同步 claims
        await _forceTokenRefresh();
      }
    } catch (error) {
      print('❌ [AuthStateListener] Failed to check ban status: $error');
    }
  }

  Future<void> _forceTokenRefresh() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      print('🔄 [AuthStateListener] Forcing token refresh...');
      await user.getIdToken(true);
      final idTokenResult = await user.getIdTokenResult();

      final claims = idTokenResult.claims;
      print('📋 [AuthStateListener] Claims after refresh: $claims');

    } catch (error) {
      print('❌ [AuthStateListener] Failed to force token refresh: $error');
    }
  }

  void _showBanMessageAndNavigate() {
    print('🎯 [AuthStateListener] Showing ban message and navigating...');

    FLoaders.errorSnackBar(title: 'Account Suspended', message: 'Your account has been suspended. Please contact administrator.');
    // 使用 GetX 显示提示
    // Get.snackbar(
    //   'Account Suspended',
    //   'Your account has been suspended. Please contact administrator.',
    //   duration: Duration(seconds: 5),
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: FColors.error,
    //   colorText: FColors.white,
    // );

    print('📢 [AuthStateListener] Snackbar shown, waiting 3 seconds...');

    // 根据平台导航到不同的登录页面
    Future.delayed(Duration(seconds: 3), () {
      print('🔄 [AuthStateListener] Starting navigation...');

      if (kIsWeb) {
        print('🌐 [AuthStateListener] Navigating to AdminLoginScreen (Web)');
        Get.offAll(() => AdminLoginScreen());
      } else {
        print('📱 [AuthStateListener] Navigating to LoginScreen (Mobile)');
        Get.offAll(() => LoginScreen());
      }
    });
  }
}