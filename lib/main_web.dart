import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/app_admin.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void mainWeb() async {
  /// Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// -- GetX Local Storage
  await GetStorage.init();

  /// -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
        (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );

  // Load all the Material Design / Themes / Localizations / Bindings
  runApp(const AdminApp());
}