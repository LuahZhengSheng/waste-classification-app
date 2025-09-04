// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/controllers/posts/create_post_controller.dart';
// import 'package:get/get.dart';
//
// class UploadMedia extends StatelessWidget {
//   final CreatePostController controller;
//
//   const UploadMedia({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // **上传按钮**
//         Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.image, color: Colors.white),
//               onPressed: controller.pickImage,
//             ),
//             IconButton(
//               icon: const Icon(Icons.video_collection, color: Colors.white),
//               onPressed: controller.pickVideo,
//             ),
//           ],
//         ),
//
//         // **显示已选媒体**
//         Obx(() {
//           if (controller.selectedMedia.value == null) return const SizedBox();
//           return Container(
//             margin: const EdgeInsets.only(top: 10),
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.grey[800],
//             ),
//             child: controller.isVideo.value
//                 ? const Center(
//               child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
//             )
//                 : ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Image.file(controller.selectedMedia.value!, fit: BoxFit.cover),
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }