import 'package:flutter/material.dart';
import 'package:fyp/common/styles/spacing_styles.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:lottie/lottie.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      required this.onPressed});

  final String image, title, subTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: FSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              /// Image
              Lottie.asset(
                image, // 这里的 image 是你的 .json 路径
                width: FDeviceUtils.getScreenWidth() * 0.6,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Title & Subtitle
              Text(title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(subTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: FSizes.spaceBtwSections),

              /// Buttons
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: onPressed,
                      child: const Text(FTexts.tContinue))),
            ],
          ),
        ),
      ),
    );
  }
}
