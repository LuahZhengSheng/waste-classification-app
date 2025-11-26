import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

class ProfileImageService {
  static final UserRepository _userRepository = Get.find<UserRepository>();

  // 压缩图片
  static Future<Uint8List> compressImage(Uint8List imageBytes) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        format: CompressFormat.webp,
        quality: 85,
        minWidth: 1080,
        minHeight: 1080,
      );
      return compressedBytes;
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes; // 如果压缩失败，返回原图
    }
  }

  // 验证图片大小
  static bool validateImageSize(Uint8List imageBytes) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (imageBytes.length > maxSize) {
      FLoaders.errorSnackBar(
        title: 'File Too Large',
        message: 'Image size must be less than 5MB',
      );
      return false;
    }
    return true;
  }

  // 上传图片
  static Future<String?> uploadProfileImage({
    required Uint8List imageBytes,
    required String userId,
    required String? currentProfileImg,
  }) async {
    try {
      // 验证文件大小
      if (!validateImageSize(imageBytes)) {
        return null;
      }

      // 压缩图片
      final compressedBytes = await compressImage(imageBytes);

      // 上传到存储
      final fileName = await _userRepository.uploadProfileImageWeb(
        compressedBytes,
        userId,
        currentProfileImg,
      );

      // 更新缓存
      final tempImageUrl = await _createTempImageUrl(compressedBytes);
      _userRepository.profileImageCache[fileName] = tempImageUrl;

      return fileName;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Upload Error',
        message: 'Failed to upload profile image: $e',
      );
      return null;
    }
  }

  // 删除图片
  static Future<void> deleteProfileImage({
    required String userId,
    required String? profileImg,
  }) async {
    try {
      if (profileImg != null && profileImg.isNotEmpty) {
        await _userRepository.deleteProfileImage(profileImg);

        // 从缓存中移除
        _userRepository.profileImageCache.remove(profileImg);
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Delete Error',
        message: 'Failed to delete profile image: $e',
      );
    }
  }

  static Future<String> _createTempImageUrl(Uint8List imageBytes) async {
    final base64String = base64Encode(imageBytes);
    return 'data:image/webp;base64,$base64String';
  }
}