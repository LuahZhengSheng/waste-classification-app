import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/admin/screens/authentication/admin_login.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
          _handleMetadataUpdate(metadata);
        }
      } else {
        print('ℹ️ [AuthStateListener] No metadata document found');
      }
    }, onError: (error) {
      print('❌ [AuthStateListener] Error in Firestore listener: $error');
    });

    print('✅ [AuthStateListener] Firestore metadata listener setup completed');
  }

  Future<void> _handleMetadataUpdate(Map<String, dynamic> metadata) async {
    print('🔍 [AuthStateListener] Handling metadata update...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ [AuthStateListener] No current user, user already logged out');
        return;
      }

      print('👤 [AuthStateListener] Current user: ${user.uid}');

      // 检查是否需要强制登出
      final forceLogout = metadata['forceLogout'] == true;
      final reason = metadata['reason'] as String?;

      if (forceLogout) {
        print('🚫 [AuthStateListener] Force logout detected! Reason: $reason');

        // 根据不同原因显示不同消息
        if (reason == 'banned') {
          await _handleBanned();
        } else if (reason == 'role_changed') {
          await _handleRoleChanged(metadata);
        } else {
          await _handleGenericLogout(reason ?? 'unknown');
        }
      } else {
        // 检查是否只是解除封禁
        final isBanned = metadata['banned'] == true;
        if (!isBanned && reason == 'recovered') {
          print('✅ [AuthStateListener] User recovered, forcing token refresh');
          await _forceTokenRefresh();
        }
      }
    } catch (error) {
      print('❌ [AuthStateListener] Failed to handle metadata update: $error');
    }
  }

  Future<void> _handleBanned() async {
    print('🚫 [AuthStateListener] Handling banned account...');

    await _auth.signOut();

    FLoaders.errorSnackBar(
      title: 'Account Suspended',
      message: 'Your account has been suspended. Please contact administrator.',
    );

    _navigateToLogin(3);
  }

  Future<void> _handleRoleChanged(Map<String, dynamic> metadata) async {
    print('🔄 [AuthStateListener] Handling role change...');

    final oldRole = metadata['oldRole'] as String? ?? 'Unknown';
    final newRole = metadata['newRole'] as String? ?? 'Unknown';

    print('📋 [AuthStateListener] Role changed: $oldRole → $newRole');

    // ✅ 先清除 metadata 标记，避免循环触发
    final user = _auth.currentUser;
    if (user != null) {
      await _clearForceLogoutFlag(user.uid);
    }

    await _auth.signOut();

    FLoaders.warningSnackBar(
      title: 'Role Updated',
      message: 'Your role has been changed from $oldRole to $newRole. Please log in again.',
    );

    _navigateToLogin(3);
  }

  Future<void> _handleGenericLogout(String reason) async {
    print('🚪 [AuthStateListener] Handling generic logout. Reason: $reason');

    await _auth.signOut();

    FLoaders.infoSnackBar(
      title: 'Logged Out',
      message: 'You have been logged out. Please log in again.',
    );

    _navigateToLogin(2);
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

  void _navigateToLogin(int delaySeconds) {
    print('📢 [AuthStateListener] Snackbar shown, waiting $delaySeconds seconds...');

    Future.delayed(Duration(seconds: delaySeconds), () {
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

  // 清除强制登出标记
  Future<void> _clearForceLogoutFlag(String uid) async {
    try {
      print('🧹 [AuthStateListener] Clearing forceLogout flag for user: $uid');

      await _firestore.collection('metadata').doc(uid).update({
        'forceLogout': FieldValue.delete(),
        'reason': FieldValue.delete(),
        'oldRole': FieldValue.delete(),
        'newRole': FieldValue.delete(),
        'refreshTime': FieldValue.serverTimestamp(), // 更新时间戳
      });

      print('✅ [AuthStateListener] ForceLogout flag cleared successfully');
    } catch (error) {
      print('❌ [AuthStateListener] Failed to clear forceLogout flag: $error');
    }
  }
}
