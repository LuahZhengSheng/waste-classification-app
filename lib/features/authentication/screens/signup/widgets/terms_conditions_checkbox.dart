import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/signup/signup_controller.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class FTermsAndConditionCheckbox extends StatelessWidget {
  const FTermsAndConditionCheckbox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(() => Checkbox(
            value: controller.privacyPolicy.value,
            onChanged: (value) => controller.privacyPolicy.value = !controller.privacyPolicy.value))),
        const SizedBox(width: FSizes.spaceBtwItems),
        Text.rich(
          TextSpan(
              children: [
                TextSpan(text: '${FTexts.iAgreeTo} ', style: Theme.of(context).textTheme.bodySmall),
                TextSpan(text: FTexts.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? FColors.white : FColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? FColors.white : FColors.primary,
                )),
                TextSpan(text: ' ${FTexts.and} ', style: Theme.of(context).textTheme.bodySmall),
                TextSpan(text: '${FTexts.termsOfUse} ', style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? FColors.white : FColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? FColors.white : FColors.primary,
                )),
              ]
          ),
        ),
      ],
    );
  }
}
