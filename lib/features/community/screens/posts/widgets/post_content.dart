// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/models/post_model.dart';
//
// class PostContent extends StatelessWidget {
//   final Post post;
//
//   const PostContent({super.key, required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 帖子文本内容
//         Text(
//           post.caption,
//           style: const TextStyle(color: Colors.white70, fontSize: 16),
//         ),
//         const SizedBox(height: 16),
//
//         // 帖子图片/影片
//         if (post.imageUrl != null && post.imageUrl!.isNotEmpty) // 如果有图片，则显示
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image(
//               image: AssetImage(post.imageUrl!),
//               fit: BoxFit.cover
//             ),
//           ),
//
//         if (post.videoUrl != null && post.videoUrl!.isNotEmpty) // 如果有视频，则显示
//           Container(
//             margin: const EdgeInsets.only(top: 16),
//             height: 200, // 你可以调整高度
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Center(
//               child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50), // 这里可以换成视频播放器
//             ),
//           ),
//       ],
//     );
//   }
// }
