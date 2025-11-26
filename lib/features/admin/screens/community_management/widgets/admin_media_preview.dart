import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:video_player/video_player.dart';

/// Admin Media Lightbox - 支持图片和视频
class AdminMediaLightbox extends StatefulWidget {
  final Uint8List? imageBytes;
  final List<String> mediaUrls;
  final int initialIndex;
  final bool dark;

  const AdminMediaLightbox({
    super.key,
    this.imageBytes,
    this.mediaUrls = const [],
    this.initialIndex = 0,
    required this.dark,
  });

  @override
  State<AdminMediaLightbox> createState() => _AdminMediaLightboxState();
}

class _AdminMediaLightboxState extends State<AdminMediaLightbox> {
  late int currentIndex;
  late PageController _pageController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize video if current page is video
    if (widget.mediaUrls.isNotEmpty && _isVideoUrl(widget.mediaUrls[currentIndex])) {
      _initializeVideo(widget.mediaUrls[currentIndex]);
    }
  }

  void _initializeVideo(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.play();
        }
      }).catchError((error) {
        print('Error initializing video: $error');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImageBytes = widget.imageBytes != null;
    final hasMediaUrls = widget.mediaUrls.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasImageBytes
                        ? 'Poster Preview'
                        : 'Media Preview (${currentIndex + 1} of ${widget.mediaUrls.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Media content
            Expanded(
              child: hasImageBytes
                  ? _buildImageFromBytes()
                  : _buildMediaPageView(),
            ),

            // Navigation controls (only for multiple media)
            if (hasMediaUrls && widget.mediaUrls.length > 1)
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentIndex > 0
                          ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                          : null,
                      icon: Icon(
                        Iconsax.arrow_left_2,
                        color: currentIndex > 0
                            ? (widget.dark ? FColors.adminDarkText : FColors.adminLightText)
                            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    // Dots indicator
                    Row(
                      children: List.generate(
                        widget.mediaUrls.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentIndex
                                ? (widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                                : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    IconButton(
                      onPressed: currentIndex < widget.mediaUrls.length - 1
                          ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                          : null,
                      icon: Icon(
                        Iconsax.arrow_right_3,
                        color: currentIndex < widget.mediaUrls.length - 1
                            ? (widget.dark ? FColors.adminDarkText : FColors.adminLightText)
                            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFromBytes() {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Center(
        child: Image.memory(
          widget.imageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildMediaPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
          _isVideoInitialized = false;
        });

        // Initialize video for new page if it's a video
        if (_isVideoUrl(widget.mediaUrls[index])) {
          _initializeVideo(widget.mediaUrls[index]);
        } else {
          _videoController?.dispose();
          _videoController = null;
        }
      },
      itemCount: widget.mediaUrls.length,
      itemBuilder: (context, index) {
        final mediaUrl = widget.mediaUrls[index];
        return Container(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Center(
            child: _isVideoUrl(mediaUrl)
                ? _buildVideoPlayer(mediaUrl)
                : _buildImagePlayer(mediaUrl),
          ),
        );
      },
    );
  }

  Widget _buildImagePlayer(String url) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingWidget(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildVideoPlayer(String url) {
    if (_videoController == null || !_isVideoInitialized) {
      return _buildLoadingWidget(null);
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoController!),
          // Play/Pause overlay
          GestureDetector(
            onTap: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Icon(
                  _videoController!.value.isPlaying
                      ? Iconsax.pause_circle
                      : Iconsax.play_circle,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
          // Video progress bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent? loadingProgress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            value: loadingProgress?.expectedTotalBytes != null
                ? loadingProgress!.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        ),
        const SizedBox(height: FSizes.md),
        Text(
          'Loading media...',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.close_circle,
          size: 64,
          color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
        ),
        const SizedBox(height: FSizes.md),
        Text(
          'Failed to load media',
          style: TextStyle(
            fontSize: 16,
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
      ],
    );
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }
}

/// Admin Media Preview Widget
class AdminMediaPreview extends StatelessWidget {
  final List<String> mediaUrls;
  final bool dark;
  final double size;
  final int maxDisplay;

  const AdminMediaPreview({
    super.key,
    required this.mediaUrls,
    required this.dark,
    this.size = 40,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) {
      return Text(
        'No media',
        style: TextStyle(
          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
      );
    }

    return SizedBox(
      height: size,
      child: Row(
        children: [
          ...mediaUrls.take(maxDisplay).toList().asMap().entries.map(
                (entry) {
              final index = entry.key;
              final mediaUrl = entry.value;
              return Padding(
                padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                child: GestureDetector(
                  onTap: () => _showMediaDialog(context, index),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusXs - 1),
                      child: _isImageUrl(mediaUrl)
                          ? Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Iconsax.image,
                          size: size * 0.5,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                      )
                          : Icon(
                        Iconsax.video_play,
                        size: size * 0.5,
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (mediaUrls.length > maxDisplay)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => _showMediaDialog(context, maxDisplay),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkPrimary.withOpacity(0.2) : FColors.adminLightPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                    border: Border.all(
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+${mediaUrls.length - maxDisplay}',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _showMediaDialog(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => AdminMediaLightbox(
        mediaUrls: mediaUrls,
        initialIndex: initialIndex,
        dark: dark,
      ),
    );
  }
}