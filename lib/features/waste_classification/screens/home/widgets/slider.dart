import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/images/rounded_image.dart';
import 'package:fyp/utils/constants/image_strings.dart';

class FSlider extends StatelessWidget {
  const FSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
          viewportFraction: 0.8
      ),
      items: [
        FRoundedImage(imageUrl: FImages.promoBanner1),
        FRoundedImage(imageUrl: FImages.promoBanner1),
        FRoundedImage(imageUrl: FImages.promoBanner1),
      ],
    );
  }
}