import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/features/authentication/screens/onboarding/onboarding.dart';
import 'package:fyp/navigation_menu.dart';
import 'package:fyp/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/admin/screens/admin_layout.dart';
import '../../../features/admin/screens/authentication/admin_login.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;

  final String _usersCollection = "users";

  /// Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  /// Called from main.dart on app launch
  @override
  void onReady() {
    // Remove the native splash screen
    FlutterNativeSplash.remove();
    // Redirect to the appropriate screen
    screenRedirect();
  }

  /// Function to Show Relevant Screen
  Future<void> screenRedirect() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // ✅ Already logged in
      // Get user role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String role = userDoc.data()?['role'] ?? 'user';

      if (kIsWeb) {
        // 👉 Web - Navigate based on role
        switch (role) {
          case 'admin':
          // Admin can access all pages, default to User Management
            Get.offAll(() => const UserManagementPage());
            break;
          case 'community_manager':
          // Community Manager - default to Dashboard (since they can't access User Management)
            Get.offAll(() => const AdminDashboard());
            break;
          case 'event_manager':
          // Event Manager - default to Dashboard
            Get.offAll(() => const AdminDashboard());
            break;
          case 'reward_manager':
          // Reward Manager - default to Dashboard
            Get.offAll(() => const AdminDashboard());
            break;
          default:
          // Unknown role or regular user - shouldn't access web admin
            Get.offAll(() => const AdminLoginScreen());
        }
      } else {
        // 👉 App - Navigate based on role
        switch (role) {
          case 'user':
            Get.offAll(() => const NavigationMenu());
            break;
          case 'center_staff':
            Get.offAll(() => const StaffNavigationMenu());
            break;
          case 'admin':
          case 'community_manager':
          case 'event_manager':
          case 'reward_manager':
          // Admin roles should not use mobile app
          // Redirect to login or show error
            Get.offAll(() => const LoginScreen());
            break;
          default:
            Get.offAll(() => const NavigationMenu());
        }
      }
    } else {
      // ✅ Not logged in
      if (kIsWeb) {
        // 👉 Web - Go to Admin Login
        Get.offAll(() => const AdminLoginScreen());
      } else {
        // 👉 App
        deviceStorage.writeIfNull('IsFirstTime', true);
        final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;

        if (isFirstTime) {
          // First time - OnBoarding
          Get.offAll(() => const OnBoardingScreen());
        } else {
          // Not first time - Login
          Get.offAll(() => const LoginScreen());
        }
      }
    }
  }

  /// 更新用户 FCM Token
  Future<void> _updateUserFCMToken(String userId) async {
    try {
      // 获取当前设备的 FCM token
      String? fcmToken = await _firebaseMessaging.getToken();

      print('fcmToken: $fcmToken');
      print('userID#: $userId');

      if (fcmToken != null && userId.isNotEmpty) {
        // 使用数组来存储多个设备的 token，避免覆盖
        await _firestore.collection(_usersCollection).doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([fcmToken]), // 使用数组和 FieldValue.arrayUnion
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print('FCM Token added to fcmTokens array for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token: $e');
      }
      // 不抛出异常，因为 FCM token 更新失败不应该影响登录流程
    }
  }

/* --------------------------- Email & Password sign-in --------------------------- */

  /// [EmailAuthentication] - Login
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // 登录成功后更新 FCM token
      if (userCredential.user != null) {
        await _updateUserFCMToken(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Register
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Mail Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [ReAuthenticate] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword(
      String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential =
      EmailAuthProvider.credential(email: email, password: password);

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Forget Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

/* --------------------------- Federated identity & social sign-in --------------------------- */

  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await userAccount?.authentication;

      // Create a new credential
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential? userCredential = await _auth.signInWithCredential(credentials);

      // 登录成功后更新 FCM token
      if (userCredential?.user != null) {
        await _updateUserFCMToken(userCredential!.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

  /// [FacebookAuthentication] - FACEBOOK
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(
          '${loginResult.accessToken?.tokenString}');

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      // 登录成功后更新 FCM token
      if (userCredential.user != null) {
        await _updateUserFCMToken(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

  /// [GoogleAuthentication] - Link Google Account to Existing Firebase User
  Future<UserCredential?> linkGoogleAccount() async {
    try {
      // 获取当前用户
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'No user is currently logged in.';
      }

      // 触发 Google 登录流程
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw 'Google sign-in failed';
      }

      // 获取 Google 登录凭证
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 将 Google 登录凭证链接到当前用户
      final UserCredential userCredential =
      await currentUser.linkWithCredential(googleCredential);

      // 链接成功后更新 FCM token
      await _updateUserFCMToken(currentUser.uid);

      // 返回合并后的用户凭证
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

/* --------------------------- Federated identity & social sign-in --------------------------- */

  /// [LogoutUser] - Valid for any authentication
  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        // Disconnect Google Account to ensure user must choose account again
        await googleSignIn.disconnect();
      }

      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Clear any local storage if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [DeleteUser] - Remove user Auth and Firestore Account
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}