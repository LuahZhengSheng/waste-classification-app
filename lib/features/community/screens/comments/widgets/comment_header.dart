import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class FCommentsHeader extends StatelessWidget {
  const FCommentsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailsController>();

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Row(
        children: [
          Obx(() => Text(
            '${controller.comments.length} Comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortingBottomSheet(context),
            child: Row(
              children: [
                Obx(() => Text(
                  controller.commentSortType.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                )),
                const SizedBox(width: FSizes.xs),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortingBottomSheet(BuildContext context) {
    final controller = Get.find<PostDetailsController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Comments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            Obx(() => Column(
              children: [
                _buildSortOption('Top comments', controller),
                _buildSortOption('Newest first', controller),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String sortType, PostDetailsController controller) {
    final isSelected = controller.commentSortType.value == sortType;

    return ListTile(
      title: Text(
        sortType,
        style: TextStyle(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF4CAF50)) : null,
      onTap: () {
        controller.setSortType(sortType);
        Get.back();
      },
    );
  }
}