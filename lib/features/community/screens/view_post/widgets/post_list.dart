import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_card.dart';
import 'package:fyp/utils/constants/sizes.dart';

class FPostsList extends StatelessWidget {
  final List<PostModel> posts;

  const FPostsList({
    super.key,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Text('No posts available'),
      );
    }

    return Column(
      children: posts.map((post) => Column(
        children: [
          FPostCard(post: post),
          const SizedBox(height: FSizes.spaceBtwSections),
        ],
      )).toList(),
    );
  }
}