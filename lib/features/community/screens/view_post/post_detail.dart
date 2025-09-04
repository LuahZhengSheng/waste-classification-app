import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_header.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_list.dart';
import 'package:fyp/features/community/screens/comments/widgets/write_comment.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_detail_card.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/sizes.dart';

// Post Details Screen
class PostDetailsScreen extends StatelessWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailsController());

    // Load post details when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPostDetails(postId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.post.value.postId.isEmpty) {
                    return const Center(child: Text('Post not found'));
                  }

                  return Column(
                    children: [
                      // Post content
                      FPostDetailsCard(post: controller.post.value),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Comments section
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Comments header with sorting
                            FCommentsHeader(),

                            // Comments list
                            Obx(() => FCommentsList(
                              comments: controller.sortedComments,
                            )),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // Write comment input at bottom
            FWriteCommentInput(),
          ],
        ),
      ),
    );
  }
}

// Media Viewer (Full Screen)
class FMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FMediaViewer({
    super.key,
    required this.mediaUrls,
    required this.initialIndex,
  });

  @override
  State<FMediaViewer> createState() => _FMediaViewerState();
}

class _FMediaViewerState extends State<FMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.mediaUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    widget.mediaUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 64,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Page indicator (if multiple images)
          if (widget.mediaUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${widget.mediaUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}