/// Media Helper Functions
/// 用于处理媒体文件 URL 和文件名的转换
class MediaHelpers {
  MediaHelpers._(); // 私有构造函数，防止实例化

  /// 从完整 URL 提取文件名
  ///
  /// 支持的格式：
  /// - Firebase Storage URL: https://firebasestorage.googleapis.com/.../filename.jpg?token=...
  /// - 普通 URL: https://example.com/path/to/filename.jpg
  /// - 已经是文件名: filename.jpg
  ///
  /// 返回: filename.jpg
  static String extractFileNameFromUrl(String url) {
    try {
      // 检查是否已经是文件名（不包含 http 或 /）
      if (!url.contains('http') && !url.contains('/')) {
        return url;
      }

      final uri = Uri.parse(url);

      // Firebase Storage URL 格式
      if (url.contains('firebasestorage.googleapis.com')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          // 获取 'o/' 后面的部分并解码
          final encodedPath = pathSegments.last;
          final decodedPath = Uri.decodeComponent(encodedPath);

          // 从完整路径中提取文件名
          // 例如: posts/userId/images/filename.jpg -> filename.jpg
          final parts = decodedPath.split('/');
          return parts.last;
        }
      }

      // 普通 URL，直接从路径提取最后一部分
      final path = uri.path;
      final segments = path.split('/');
      return segments.isNotEmpty ? segments.last : url;
    } catch (e) {
      print('Error extracting filename from URL: $e');
      return url; // 如果解析失败，返回原始值
    }
  }

  /// 将 URL 列表转换为文件名列表
  ///
  /// 用于保存到 Firestore 时，把完整 URL 转换为文件名
  static List<String> convertUrlsToFileNames(List<String> urls) {
    return urls.map((url) => extractFileNameFromUrl(url)).toList();
  }

  /// 从文件名构建完整的 Firebase Storage URL
  ///
  /// [fileName]: 文件名（如 filename.jpg）
  /// [userId]: 用户 ID
  /// [folder]: 文件夹名称（images 或 videos）
  ///
  /// 返回: posts/userId/folder/filename.jpg 格式的路径
  static String buildStoragePath(String fileName, String userId, String folder) {
    return 'posts/$userId/$folder/$fileName';
  }

  /// 判断 URL 是图片还是视频
  static bool isImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      return imageExtensions.any((ext) => path.endsWith(ext));
    } catch (e) {
      print('Error checking if URL is image: $e');
      // 如果解析失败，回退到简单的字符串检查
      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      return imageExtensions.any((ext) => url.toLowerCase().contains(ext));
    }
  }

  /// 判断是否为视频 URL
  static bool isVideoUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
      return videoExtensions.any((ext) => path.endsWith(ext));
    } catch (e) {
      print('Error checking if URL is video: $e');
      return false;
    }
  }

  /// 从 URL 获取文件扩展名
  static String getFileExtension(String url) {
    try {
      final fileName = extractFileNameFromUrl(url);
      final lastDot = fileName.lastIndexOf('.');
      if (lastDot != -1 && lastDot < fileName.length - 1) {
        return fileName.substring(lastDot); // 包含 .
      }
      return '';
    } catch (e) {
      print('Error getting file extension: $e');
      return '';
    }
  }

  /// 检查文件名是否有效
  static bool isValidFileName(String fileName) {
    if (fileName.isEmpty) return false;
    // 不能包含路径分隔符或特殊字符
    final invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
    return !invalidChars.any((char) => fileName.contains(char));
  }
}
