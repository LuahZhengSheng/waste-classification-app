import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/secondary_header_container.dart';
import 'package:fyp/common/widgets/inputs/numeric_input_field.dart';
import 'package:fyp/common/widgets/options/options_selector.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class LandTravelScreen extends StatelessWidget {
  LandTravelScreen({super.key});

  final RxInt isVegetarian = 0.obs;
  final RxInt isVegan = 0.obs;
  final RxInt isMinimize = 0.obs;
  final RxInt cowOpt = 0.obs;
  final RxInt pigOpt = 0.obs;
  final RxInt chickenOpt = 0.obs;
  final RxInt fishOpt = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FSecondaryHeaderContainer(
                child: Column(
                  children: [
                    /// AppBar
                    FAppBar(title: Text('Land Travel', style: Theme.of(context).textTheme.headlineMedium!.apply(color: FColors.white)), backArrowColor: FColors.white),

                    const SizedBox(height: FSizes.spaceBtwSections),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Text('How many kilometers have you ridden in the past year?', style: Theme.of(context).textTheme.headlineSmall!.apply(color: FColors.white, fontSizeFactor: 1.15)),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Car', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Taxi + Ride Share', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Motorcycle', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Train', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Bus', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Electric Bicycle', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('By Bicycle', style: Theme.of(context).textTheme.bodyLarge!.apply(color: FColors.white, fontSizeFactor: 1.5)),
                        ),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        NumericInputField(value: 0.obs),
                      ],
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections * 2),
                    Text('Car Details', style: Theme.of(context).textTheme.headlineSmall!.apply(color: FColors.white, fontSizeFactor: 1.15)),
                    FOptionsSelector(options: const ["None", "Electric", "Plug-in Hybrid", "Hybrid", "Gas", "Diesel", "Biofuel (20%)", "Biofuel", "Sustainable Biofuel"], selectedIndex: isVegetarian, onSelect: (index) {isVegetarian.value = index;}),
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}


