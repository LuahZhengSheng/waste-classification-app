import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: FDeviceUtils.getAppBarHeight() / 2,
      right: FSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(),
        child: const Text('Skip'),
      ),
    );
  }
}