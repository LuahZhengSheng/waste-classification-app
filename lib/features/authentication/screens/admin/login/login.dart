import 'package:flutter/material.dart';
import 'package:fyp/common/styles/spacing_styles.dart';
import 'package:fyp/features/authentication/screens/admin/login/widgets/login_form.dart';
import 'package:fyp/features/authentication/screens/login/widgets/login_header.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: FSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              const FLoginHeader(),

              /// Form
              const FAdminLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}








