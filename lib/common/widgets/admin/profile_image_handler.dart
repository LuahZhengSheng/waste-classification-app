import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'admin_lightbox.dart';

class ProfileImageHandler extends StatefulWidget {
  final String? profileImg;
  final String username;
  final String userId;
  final bool dark;
  final double radius;
  final bool isEditMode;
  final Function(Uint8List?) onImageChanged; // 只通知有变化，不立即上传
  final Function(bool) onDeleteRequested; // 只通知删除请求，不立即执行

  const ProfileImageHandler({
    super.key,
    required this.profileImg,
    required this.username,
    required this.userId,
    required this.dark,
    this.radius = 60,
    this.isEditMode = false,
    required this.onImageChanged,
    required this.onDeleteRequested,
  });

  @override
  State<ProfileImageHandler> createState() => _ProfileImageHandlerState();
}

class _ProfileImageHandlerState extends State<ProfileImageHandler> {
  Uint8List? _pendingImageBytes; // 改为 pending，表示待确认的图片
  bool _pendingDelete = false; // 待确认的删除操作
  final UserRepository _userRepo = Get.find<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _viewImage(),
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            child: _buildProfileImageContent(),
          ),
        ),
        if (widget.isEditMode)
          Positioned(
            bottom: 0,
            right: 0,
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.camera, color: Colors.white, size: 20),
              ),
              onSelected: (value) {
                if (value == 'upload') {
                  _pickImage();
                } else if (value == 'delete') {
                  _requestDeleteImage();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'upload',
                  child: Row(
                    children: [
                      Icon(Iconsax.gallery_add),
                      SizedBox(width: 8),
                      Text('Upload Photo'),
                    ],
                  ),
                ),
                if (widget.profileImg != null && widget.profileImg!.isNotEmpty && !_pendingDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Photo', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImageContent() {
    // 如果有待确认的新图片，显示新图片
    if (_pendingImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _pendingImageBytes!,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
        ),
      );
    }

    // 如果有待确认的删除操作，显示默认头像
    if (_pendingDelete) {
      return _buildDefaultAvatar();
    }

    // 否则显示当前图片（如果有）
    final currentImageUrl = _userRepo.getCachedProfileImageUrl(widget.profileImg);
    if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      return ClipOval(
        child: currentImageUrl.startsWith('data:')
            ? Image.memory(
          base64Decode(currentImageUrl.split(',').last),
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
        )
            : Image.network(
          currentImageUrl,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      );
    }

    // 默认头像
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Icon(Iconsax.user, size: widget.radius, color: Colors.white);
  }

  void _viewImage() {
    String? imageUrlForLightbox;

    // 优先显示待确认的新图片
    if (_pendingImageBytes != null) {
      final base64String = base64Encode(_pendingImageBytes!);
      imageUrlForLightbox = 'data:image/webp;base64,$base64String';
    }
    // 如果没有待确认的操作，显示当前图片
    else if (!_pendingDelete) {
      imageUrlForLightbox = _userRepo.getCachedProfileImageUrl(widget.profileImg);
    }

    if (imageUrlForLightbox != null && imageUrlForLightbox.isNotEmpty) {
      Get.to(() => ImageLightbox(
        imageUrl: imageUrlForLightbox!,
        title: widget.username,
      ));
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        setState(() {
          _pendingImageBytes = bytes;
          _pendingDelete = false; // 取消删除标记
        });

        // 通知父组件有图片变更（但不立即上传）
        widget.onImageChanged(_pendingImageBytes);

        FLoaders.successSnackBar(
          title: 'Success',
          message: 'Profile image selected. Click "Update Profile" to save changes.',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select image: ${e.toString()}',
      );
    }
  }

  void _requestDeleteImage() {
    setState(() {
      _pendingDelete = true;
      _pendingImageBytes = null; // 清除任何待确认的图片
    });

    // 通知父组件有删除请求（但不立即执行）
    widget.onDeleteRequested(true);
    widget.onImageChanged(null);

    FLoaders.successSnackBar(
      title: 'Success',
      message: 'Profile image marked for deletion. Click "Update Profile" to confirm.',
    );
  }

  // 获取待确认的图片字节
  Uint8List? getPendingImageBytes() => _pendingImageBytes;

  // 是否有待确认的删除操作
  bool get hasPendingDelete => _pendingDelete;

  // 重置所有待确认的操作
  void resetPendingOperations() {
    setState(() {
      _pendingImageBytes = null;
      _pendingDelete = false;
    });
  }

  // 是否有任何待确认的更改
  bool get hasPendingChanges => _pendingImageBytes != null || _pendingDelete;
}