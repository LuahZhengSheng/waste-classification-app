import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fyp/main_app.dart';
import 'package:fyp/main_web.dart';

void main() {
  if (kIsWeb) {
    // 👉 Web 启动 Admin
    mainWeb();
  } else {
    // 👉 App 启动正常 App
    mainApp();
  }
}
