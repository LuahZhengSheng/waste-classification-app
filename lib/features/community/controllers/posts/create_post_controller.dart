// import 'package:flutter/material.dart';
// import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
// import 'package:fyp/features/authentication/models/user_model.dart';
// import 'package:fyp/features/community/models/post_model.dart';
// import 'package:fyp/utils/constants/image_strings.dart';
// import 'package:fyp/utils/helpers/network_manager.dart';
// import 'package:fyp/utils/popups/full_screen_loader.dart';
// import 'package:fyp/utils/popups/loaders.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// class CreatePostController extends GetxController {
//   static CreatePostController get instance => Get.find();
//
//   final title = TextEditingController();
//   final content = TextEditingController();
//   final selectedMedia = Rxn<File>(); // 图片或视频
//   final isVideo = false.obs;
//   GlobalKey<FormState> createPostFormKey = GlobalKey<FormState>();
//
//   final ImagePicker _picker = ImagePicker();
//
//   /// -- CREATE POST
//   void createPost() async {
//     try {
//       // Start Loading
//       FFullScreenLoader.openLoadingDialog('Creating...', FImages.docerAnimation);
//
//       // Check Internet Connectivity
//       final isConnected = await NetworkManager.instance.isConnected();
//       if (!isConnected) {
//         FFullScreenLoader.stopLoading();
//         return;
//       }
//
//       // Form Validation
//       if (!createPostFormKey.currentState!.validate()) {
//         FFullScreenLoader.stopLoading();
//         return;
//       }
//
//       // Save Authenticated user data in the Firebase Firestore
//       final newPost = PostModel(
//         id: '',
//         userId: AuthenticationRepository.instance.userId,
//         title: "New Post Title",
//         caption: "This is a sample post caption.",
//         mediaUrl: FImages.user,
//         likes: 0,
//         comments: 0,
//         shares: 0,
//         createdAt: DateTime.now(),
//       );
//
//       final userRepository = Get.put(UserRepository());
//       await userRepository.saveUserRecord(newUser);
//
//       // Show Success Message
//       FLoaders.successSnackBar(title: 'Congratulations', message: 'Your account has been created! Verify email to continue.');
//
//       FFullScreenLoader.stopLoading();
//
//       // Move to Verify Email Screen
//       Get.to(() => VerifyEmailScreen(email: email.text.trim()));
//     } catch (e) {
//       FFullScreenLoader.stopLoading();
//       // Show some Generic Error to the user
//       FLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
//     }
//   }
// }
//
//   // **选择图片**
//   Future<void> pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       selectedMedia.value = File(pickedFile.path);
//       isVideo.value = false;
//     }
//   }
//
//   // **选择视频**
//   Future<void> pickVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       selectedMedia.value = File(pickedFile.path);
//       isVideo.value = true;
//     }
//   }
//
//   // **提交帖子**
//   void submitPost() {
//     if (title.value.isEmpty || content.value.isEmpty) {
//       Get.snackbar("错误", "请填写标题和内容", backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//
//     // 模拟提交逻辑
//     print('Title: ${title.value}');
//     print('Content: ${content.value}');
//     print('Media: ${selectedMedia.value?.path}');
//     print('Is Video: ${isVideo.value}');
//
//     // 清空输入框
//     title.value = '';
//     content.value = '';
//     selectedMedia.value = null;
//
//     Get.snackbar("成功", "帖子已发布", backgroundColor: Colors.green, colorText: Colors.white);
//   }
// }