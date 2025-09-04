import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/options/options_selector.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class FFoodDetailInputs extends StatelessWidget {
  const FFoodDetailInputs({
    super.key,
    required this.cowOpt,
    required this.pigOpt,
    required this.chickenOpt,
    required this.fishOpt,
  });

  final RxInt cowOpt;
  final RxInt pigOpt;
  final RxInt chickenOpt;
  final RxInt fishOpt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text('Cow, sheep, or goat', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        FOptionsSelector(options: const ["Weekly", "Monthly", "Never"], selectedIndex: cowOpt, onSelect: (index) {cowOpt.value = index;}),
        const SizedBox(height: FSizes.spaceBtwItems),

        const Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text('Pig', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        FOptionsSelector(options: const ["Weekly", "Monthly", "Never"], selectedIndex: pigOpt, onSelect: (index) {pigOpt.value = index;}),
        const SizedBox(height: FSizes.spaceBtwItems),

        const Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text('Chicken or other poultry', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        FOptionsSelector(options: const ["Weekly", "Monthly", "Never"], selectedIndex: chickenOpt, onSelect: (index) {chickenOpt.value = index;}),
        const SizedBox(height: FSizes.spaceBtwItems),

        const Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text('Fish', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        FOptionsSelector(options: const ["Weekly", "Monthly", "Never"], selectedIndex: fishOpt, onSelect: (index) {fishOpt.value = index;}),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}