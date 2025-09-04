import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/admin/screens/user_management/user_management.dart';
import 'package:fyp/features/authentication/screens/admin/login/login.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/features/authentication/screens/onboarding/onboarding.dart';
import 'package:fyp/features/authentication/screens/signup/verify_email.dart';
import 'package:fyp/navigation_menu.dart';
import 'package:fyp/sidebar_menu.dart';
import 'package:fyp/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

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
      // ✅ 已登录
      if (user.emailVerified) {
        if (kIsWeb) {
          // 👉 Web 用 Sidebar
          Get.offAll(() => UserManagementScreen());
        } else {
          // 👉 App 用 Navigation Menu
          Get.offAll(() => const NavigationMenu());
        }
      } else {
        // 账号存在但还没验证邮箱
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
    } else {
      // ✅ 未登录
      if (kIsWeb) {
        // 👉 Web 直接去 AdminLogin
        Get.offAll(() => const AdminLoginScreen());
      } else {
        // 👉 App
        deviceStorage.writeIfNull('IsFirstTime', true);
        final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;

        if (isFirstTime) {
          // 第一次使用 → OnBoarding
          Get.offAll(() => const OnBoardingScreen());
        } else {
          // 非第一次 → Login
          Get.offAll(() => const LoginScreen());
        }
      }
    }
  }



  // /// Function to Show Relevant Screen
  // Future<void> screenRedirect() async {
  //   final User? user = _auth.currentUser;
  //   if (user != null) {
  //     if (user.emailVerified) {
  //       Get.offAll(() => const NavigationMenu());
  //     } else {
  //       Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
  //     }
  //   } else {
  //     // Local Storage
  //     deviceStorage.writeIfNull('IsFirstTime', true);
  //     // Check if it's the first time launching the app
  //     deviceStorage.read('IsFirstTime') != true
  //         ? Get.offAll(() => const LoginScreen()) // Redirect to Login Screen if not the first time
  //         : Get.offAll(const OnBoardingScreen()); // Redirect to OnBoarding Screen if It's the first time
  //   }
  // }

/* --------------------------- Email & Password sign-in --------------------------- */

  /// [EmailAuthentication] - Login
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
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
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      
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
      final GoogleSignInAuthentication? googleAuth = await userAccount?.authentication;

      // Create a new credential
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credentials);

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
      // throw 'Something went wrong. Please try again.';
    }
  }

  /// [FacebookAuthentication] - FACEBOOK
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential('${loginResult.accessToken?.tokenString}');

      // return await currentUser?.linkWithCredential(facebookAuthCredential);
      //
      // // Check if the user exists in Firebase Authentication
      // final List<UserInfo> providerData =
      //     (await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential))
      //         .user!
      //         .providerData;
      // bool hasEmailProvider = providerData.any((element) => element.providerId == 'password');
      //
      // // If user already exists with email/password, link accounts
      // final currentUser = FirebaseAuth.instance.currentUser;
      // if (hasEmailProvider) {
      //   return await currentUser?.linkWithCredential(facebookAuthCredential);
      // } else {
      //   // Otherwise, sign in normally
      //   return await _auth.signInWithCredential(facebookAuthCredential);
      // }

      // Once signed in, return the UserCredential
      return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

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
      // throw 'Something went wrong. Please try again.';
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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 将 Google 登录凭证链接到当前用户
      final UserCredential userCredential = await currentUser.linkWithCredential(googleCredential);

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

      Get.offAll(() => const LoginScreen());
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
