import 'package:intl/intl.dart';

class FFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd MMMM yyyy').format(date);  // Customize the date format as needed
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Assuming a 10-digit US phone number format: (123) 456-7890
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }

    return phoneNumber;
  }

  /// Format time ago (e.g., "2h ago", "3d ago")
  static String formatTimeAgo(DateTime dateTime) {
    // 统一转换为本地时间进行比较
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
  /// Format count (e.g., 1K, 1.5M)
  static String formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  // 格式化为国际格式的静态方法
  static String formatPhoneToInternational(String phoneNumber) {
    // 移除所有空格、连字符和加号
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\+]'), '');

    // 如果已经以60开头，直接返回
    if (cleaned.startsWith('60')) {
      return '+$cleaned';
    }

    // 如果以0开头（马来西亚本地格式），移除0并添加60
    if (cleaned.startsWith('0')) {
      return '+60${cleaned.substring(1)}';
    }

    // 如果没有任何前缀，假设是本地号码，添加60
    return '+60$cleaned';
  }
}