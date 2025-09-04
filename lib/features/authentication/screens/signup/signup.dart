import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/login_signup/form_divider.dart';
import 'package:fyp/common/widgets/login_signup/social_buttons.dart';
import 'package:fyp/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(FTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Form
              const FSignupForm(),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Divider
              FFormDivider(dividerText: FTexts.orSignUpWith.capitalize!),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Social Buttons
              const FSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}


