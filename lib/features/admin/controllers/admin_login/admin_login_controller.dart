import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/user/admin_repository.dart';
import '../../models/admin_model.dart';

class AdminLoginController extends GetxController {
  static AdminLoginController get instance => Get.find();

  // Variables
  final email = TextEditingController();
  final password = TextEditingController();
  final hidePassword = true.obs;
  final isBlocked = false.obs;
  final remainingBlockTime = ''.obs;
  GlobalKey<FormState> adminLoginFormKey = GlobalKey<FormState>();

  // Repositories
  final _adminRepository = Get.put(AdminRepository());
  final _authRepository = Get.put(AuthenticationRepository());

  // Constants for blocking logic
  static const int MAX_ATTEMPTS = 5;
  static const int ATTEMPT_WINDOW_MINUTES = 5;
  static const int BLOCK_DURATION_MINUTES = 10;

  Timer? _blockTimer;

  @override
  void onClose() {
    _blockTimer?.cancel();
    email.dispose();
    password.dispose();
    super.onClose();
  }

  /// Admin Login with blocking logic
  Future<void> adminLogin() async {
    try {
      // Validate form
      if (!adminLoginFormKey.currentState!.validate()) return;

      // Show loading
      FLoaders.showLoading('Signing you in...');

      // Check if user exists and get admin data (现在包含 Auth 验证状态)
      final adminData = await _adminRepository.getAdminByEmail(email.text.trim());

      if (adminData == null) {
        FLoaders.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Login Failed',
          message: 'Invalid email or password.',
        );
        return;
      }

      // Check if account is blocked
      final blockStatus = await _checkBlockStatus(adminData);
      if (blockStatus != null) {
        FLoaders.stopLoading();
        _startBlockTimer(blockStatus);
        return;
      }

      // Check account status before login (现在使用 Auth 的 emailVerified)
      final statusCheck = _checkAccountStatus(adminData);
      if (statusCheck != null) {
        FLoaders.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Access Denied',
          message: statusCheck,
        );
        return;
      }

      // Attempt Firebase Authentication
      try {
        await _authRepository.loginWithEmailAndPassword(
          email.text.trim(),
          password.text.trim(),
        );

        // Login successful - reset attempts
        await _adminRepository.resetLoginAttempts(adminData.userId);

        FLoaders.stopLoading();

        // Redirect to admin dashboard
        _authRepository.screenRedirect();

      } catch (authError) {
        FLoaders.stopLoading();

        // Login failed - increment attempts
        await _handleFailedLogin(adminData);

        FLoaders.errorSnackBar(
          title: 'Login Failed',
          message: 'Invalid email or password.',
        );
      }

    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
    }
  }

  /// Check if account is blocked
  Future<DateTime?> _checkBlockStatus(AdminModel admin) async {
    // If no failed login, account is not blocked
    if (admin.lastFailedLogin == null) return null;

    final now = DateTime.now();
    final timeSinceLastFail = now.difference(admin.lastFailedLogin!);

    // If more than ATTEMPT_WINDOW_MINUTES passed, reset is automatic
    if (timeSinceLastFail.inMinutes >= ATTEMPT_WINDOW_MINUTES) {
      // Reset attempts automatically
      await _adminRepository.resetLoginAttempts(admin.userId);
      return null;
    }

    // Check if max attempts reached within window
    if (admin.loginAttemptCount >= MAX_ATTEMPTS) {
      final blockEndTime = admin.lastFailedLogin!.add(
        const Duration(minutes: BLOCK_DURATION_MINUTES),
      );

      // If still within block period
      if (now.isBefore(blockEndTime)) {
        return blockEndTime;
      } else {
        // Block period expired, reset attempts
        await _adminRepository.resetLoginAttempts(admin.userId);
        return null;
      }
    }

    return null;
  }

  /// Check account status (banned, inactive, not verified, invalid role)
  /// 现在使用 Auth 的 emailVerified 而不是 Firestore 的 isVerified
  String? _checkAccountStatus(AdminModel admin) {
    if (admin.isBanned) {
      return 'Your account has been banned. Please contact support.';
    }

    if (!admin.isActive) {
      return 'Your account is inactive. Please contact support.';
    }

    // 现在使用从 Auth 获取的 emailVerified 状态
    if (!admin.isVerified) {
      return 'Your account is not verified. Please verify your email.';
    }

    // Check if role is valid admin role
    const validRoles = ['admin', 'community_manager', 'reward_manager', 'event_manager'];
    if (!validRoles.contains(admin.role)) {
      return 'Invalid email or password.';
    }

    return null;
  }

  /// Handle failed login attempt
  Future<void> _handleFailedLogin(AdminModel admin) async {
    final now = DateTime.now();
    final timeSinceLastFail = admin.lastFailedLogin != null
        ? now.difference(admin.lastFailedLogin!)
        : const Duration(hours: 1);

    int newAttemptCount;

    // If last attempt was more than ATTEMPT_WINDOW_MINUTES ago, reset count
    if (timeSinceLastFail.inMinutes >= ATTEMPT_WINDOW_MINUTES) {
      newAttemptCount = 1;
    } else {
      newAttemptCount = admin.loginAttemptCount + 1;
    }

    await _adminRepository.updateLoginAttempt(
      admin.userId,
      newAttemptCount,
      now,
    );

    // If reached max attempts, show block message
    if (newAttemptCount >= MAX_ATTEMPTS) {
      final blockEndTime = now.add(const Duration(minutes: BLOCK_DURATION_MINUTES));
      _startBlockTimer(blockEndTime);

      FLoaders.warningSnackBar(
        title: 'Account Locked',
        message: 'Too many failed attempts. Please try again in $BLOCK_DURATION_MINUTES minutes.',
      );
    } else {
      final remainingAttempts = MAX_ATTEMPTS - newAttemptCount;
    }
  }

  /// Start countdown timer for blocked account
  void _startBlockTimer(DateTime blockEndTime) {
    isBlocked.value = true;

    _blockTimer?.cancel();
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = blockEndTime.difference(now);

      if (remaining.isNegative) {
        timer.cancel();
        isBlocked.value = false;
        remainingBlockTime.value = '';
      } else {
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        remainingBlockTime.value = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    });
  }
}