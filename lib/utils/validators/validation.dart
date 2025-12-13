class FValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for lowercase letters
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the confirmation password';
    }

    // 确保确认密码与原始密码相同
    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Remove spaces, hyphens, and plus signs for validation
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\+]'), '');

    // Remove country code if present (60 or +60)
    String numberToValidate = cleanedValue;
    if (cleanedValue.startsWith('60')) {
      numberToValidate = '0${cleanedValue.substring(2)}';
    }

    // Check if starts with 0
    if (!numberToValidate.startsWith('0')) {
      return 'Invalid format. Mobile number must start with 01X.';
    }

    // Validate mobile number prefixes and lengths
    // 011 and 015: 11 digits total (0 + 2-digit prefix + 8 digits)
    // All others (010, 012-014, 016-019): 10 digits total (0 + 2-digit prefix + 7 digits)

    if (numberToValidate.startsWith('011') || numberToValidate.startsWith('015')) {
      // Must be exactly 11 digits: 011-XXXX XXXX
      if (!RegExp(r'^01[15]\d{8}$').hasMatch(numberToValidate)) {
        return 'Invalid format. Example: 011-1234 5678';
      }
    } else if (RegExp(r'^01[02346789]').hasMatch(numberToValidate)) {
      // Valid prefixes: 010, 012, 013, 014, 016, 017, 018, 019
      // Must be exactly 10 digits: 01X-XXX XXXX
      if (!RegExp(r'^01[02346789]\d{7}$').hasMatch(numberToValidate)) {
        return 'Invalid format. Example: 012-345 6789';
      }
    } else {
      // Invalid prefix (not 010-019)
      return 'Invalid mobile prefix. Must start with 010-019.';
    }

    return null;
  }
}
