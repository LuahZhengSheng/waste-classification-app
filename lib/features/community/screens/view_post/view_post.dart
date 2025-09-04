import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_header.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_list.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

// Main posts screen
class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const FAppBar(title: Text("Posts"), showBackArrow: false,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              children: [
                /// Header with filter
                const FPostsHeader(),
                const SizedBox(height: FSizes.spaceBtwItems),

                /// Post Input
                // const FPostInput(),
                // const SizedBox(height: FSizes.spaceBtwSections),

                /// Posts List - 用 Obx 包装以监听 filteredPosts 变化
                Obx(() => FPostsList(posts: controller.filteredPosts.toList())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Post input widgets
class FPostInput extends StatelessWidget {
  const FPostInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Align children to the right
        children: [
          Container(
            width: double.infinity, // Take full width
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(() => const CreatePostScreen());
              },
              child: Text(
                "What's on your mind?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          FCustomButton(
            text: 'My Post',
            backgroundColor: const Color(0xFF4CAF50),
            textColor: Colors.white,
            onPressed: () {
              Get.to(() => const MyPostsScreen());
            },
          ),
        ],
      ),
    );
  }
}

// Custom button widgets - reusable
class FCustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;

  const FCustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: fontSize ?? 12,
          ),
        ),
      ),
    );
  }
}

// Custom tag widgets
class FCustomTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const FCustomTag({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Placeholder screen classes - implement according to your needs
class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: const Center(child: Text('Create Post Screen')),
    );
  }
}

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posts')),
      body: const Center(child: Text('My Posts Screen')),
    );
  }
}

class ViewPostScreen extends StatelessWidget {
  final String postId;
  const ViewPostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Post')),
      body: Center(child: Text('View Post Screen: $postId')),
    );
  }
}

class EditPostScreen extends StatelessWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Center(child: Text('Edit Post Screen: ${post.postId}')),
    );
  }
}

