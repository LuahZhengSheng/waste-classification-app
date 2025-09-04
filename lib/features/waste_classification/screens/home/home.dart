import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:fyp/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:fyp/common/widgets/texts/section_heading.dart';
import 'package:fyp/features/personalization/screens/notification/widgets/notification_icon.dart';
import 'package:fyp/features/waste_classification/screens/home/widgets/home_appbar.dart';
import 'package:fyp/features/waste_classification/screens/home/widgets/slider.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            FPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// -- Appbar
                  const FHomeAppBar(),
                  const SizedBox(height: FSizes.spaceBtwSections),

                  /// -- Searchbar
                  const FSearchContainer(text: 'Search Waste'),
                  const SizedBox(height: FSizes.spaceBtwSections),

                  /// -- Searchbar
                  const NotificationIcon(),
                  const SizedBox(height: FSizes.spaceBtwSections),

                  /// Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                    child: Column(
                      children: [
                        /// -- Headings
                        const FSectionHeading(title: 'Popular Categories', showActionButton: false, textColor: Colors.white),
                        const SizedBox(height: FSizes.spaceBtwItems),

                        /// -- Categories
                        SizedBox(
                          width: 350,
                          height: 80,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 6,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) {
                              return FVerticalImageText(image: FImages.google, title: 'Waste', onTap: () {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FSizes.spaceBtwSections),
                ],
              ),
            ),

            /// Body
            const Padding(
              padding: EdgeInsets.all(FSizes.defaultSpace),
              child: FSlider(),
            )
          ],
        ),
      ),
    );
  }
}




