// import 'package:flutter/material.dart';
// import 'package:fyp/common/widgets/appbar/appbar.dart';
// import 'package:fyp/features/carbon_footprint_calculator/controllers/options_controller.dart';
// import 'package:fyp/features/carbon_footprint_calculator/screens/carbon_footprint_calculator/widgets/options_selector.dart';
// import 'package:fyp/features/carbon_footprint_calculator/screens/carbon_footprint_calculator/widgets/options_slider.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:get/get.dart';
//
// class FoodScreen extends StatelessWidget {
//   const FoodScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final OptionsController vegetarianController = Get.put(OptionsController());
//     final OptionsController veganController = Get.put(OptionsController());
//     final OptionsController foodWasteController = Get.put(OptionsController());
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF081C3D), // 深蓝色背景
//       appBar: FAppBar(
//         title: Text('Food', style: Theme.of(context).textTheme.headlineMedium!.apply(color: FColors.white)),
//         showBackArrow: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             const Text(
//               "How many days per week do you eat meat or seafood?",
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 10),
//             const FOptionsSlider(
//               min: 0,
//               max: 7,
//               divisions: 9,
//               activeColor: Colors.blue,
//               thumbColor: FColors.primary,
//               sliderWidthFactor: 0.6,
//             ),
//             const SizedBox(height: 30),
//
//             _buildQuestion("Are you a vegetarian?", vegetarianController),
//             const SizedBox(height: 20),
//             _buildQuestion("Are you a vegan?", veganController),
//             const SizedBox(height: 20),
//             _buildQuestion("Do you minimize food waste?", foodWasteController),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// ✅ 复用的 Yes/No 选择组件
//   Widget _buildQuestion(String question, OptionsController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question, style: const TextStyle(color: Colors.white, fontSize: 18)),
//         const SizedBox(height: 5),
//         FOptionsSelector(
//           options: const ["Yes", "No"],
//           selectedIndex: controller.selectedIndex,
//           onSelect: controller.selectOption,
//         ),
//       ],
//     );
//   }
//
// }
