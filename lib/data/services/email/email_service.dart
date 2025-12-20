// // services/email_service.dart
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
//
// import '../../../config/env_config.dart';
//
// class EmailService {
//   static final EmailService _instance = EmailService._internal();
//   factory EmailService() => _instance;
//   EmailService._internal();
//
//   static const String _sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';
//   static const int _maxRetries = 3;
//   static const Duration _retryDelay = Duration(seconds: 2);
//
//   /// Send email notification to manager with comprehensive error handling
//   Future<EmailResult> sendManagerNotification({
//     required String toEmail,
//     required String subject,
//     required String message,
//     required String managerName,
//     required String actionType,
//     int retryCount = 0,
//   }) async {
//     try {
//       // Validate input parameters
//       final validationError = _validateInputs(toEmail, subject, message, managerName);
//       if (validationError != null) {
//         return EmailResult.success(false, error: validationError);
//       }
//
//       // Get API key from EnvConfig
//       final sendGridApiKey = EnvConfig.sendGridApiKey;
//       if (sendGridApiKey.isEmpty) {
//         return EmailResult.success(false, error: 'SendGrid API key is not configured');
//       }
//
//       print('📧 Sending manager notification to: $toEmail');
//       print('📝 Subject: $subject');
//       print('👤 Manager: $managerName');
//       print('🔧 Action: $actionType');
//
//       final response = await http.post(
//         Uri.parse(_sendGridUrl),
//         headers: {
//           'Authorization': 'Bearer $sendGridApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'personalizations': [
//             {
//               'to': [
//                 {'email': toEmail, 'name': managerName}
//               ],
//               'dynamic_template_data': {
//                 'subject': subject,
//                 'manager_name': managerName,
//                 'message': message,
//                 'action_type': actionType,
//                 'support_email': 'admin@saveearth.com',
//                 'current_date': DateTime.now().toIso8601String(),
//               }
//             }
//           ],
//           'from': {
//             'email': 'noreply@saveearth.com',
//             'name': 'SaveEarth System Admin'
//           },
//           'template_id': 'd-763e94af4f274c34ad9ff6ae4621d87a',
//           'tracking_settings': {
//             'click_tracking': {'enable': true},
//             'open_tracking': {'enable': true},
//           },
//         }),
//       );
//
//       return _handleResponse(response, toEmail, subject, retryCount);
//
//     } on SocketException catch (e) {
//       print('🌐 Network error sending email: $e');
//       return await _handleRetry(
//           toEmail, subject, message, managerName, actionType, retryCount,
//           error: 'Network connection failed: ${e.message}'
//       );
//     } on http.ClientException catch (e) {
//       print('🚫 HTTP client error: $e');
//       return await _handleRetry(
//           toEmail, subject, message, managerName, actionType, retryCount,
//           error: 'HTTP request failed: ${e.message}'
//       );
//     } catch (e) {
//       print('❌ Unexpected error sending email: $e');
//       return EmailResult.success(false, error: 'Unexpected error: $e');
//     }
//   }
//
//   /// Validate all input parameters
//   String? _validateInputs(String toEmail, String subject, String message, String managerName) {
//     if (toEmail.isEmpty || !toEmail.contains('@')) {
//       return 'Invalid recipient email address';
//     }
//     if (subject.isEmpty) {
//       return 'Email subject cannot be empty';
//     }
//     if (message.isEmpty) {
//       return 'Email message cannot be empty';
//     }
//     if (managerName.isEmpty) {
//       return 'Manager name cannot be empty';
//     }
//     return null;
//   }
//
//   /// Handle HTTP response with detailed error analysis
//   EmailResult _handleResponse(http.Response response, String toEmail, String subject, int retryCount) {
//     print('📨 SendGrid response status: ${response.statusCode}');
//
//     if (response.statusCode == 202) {
//       print('✅ Email sent successfully to: $toEmail');
//       return EmailResult.success(true);
//     }
//
//     // Handle specific error codes
//     final errorMessage = _getErrorMessage(response);
//     print('❌ Email sending failed: $errorMessage');
//
//     if (_shouldRetry(response.statusCode) && retryCount < _maxRetries) {
//       print('🔄 Retrying email send (${retryCount + 1}/$_maxRetries)...');
//       return EmailResult.retry(error: errorMessage);
//     }
//
//     return EmailResult.success(false, error: errorMessage);
//   }
//
//   /// Get detailed error message from SendGrid response
//   String _getErrorMessage(http.Response response) {
//     try {
//       final responseBody = jsonDecode(response.body);
//       final errors = responseBody['errors'] as List?;
//
//       if (errors != null && errors.isNotEmpty) {
//         final firstError = errors.first;
//         return firstError['message']?.toString() ?? 'Unknown SendGrid error';
//       }
//
//       return 'SendGrid API error: ${response.statusCode}';
//     } catch (e) {
//       return 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
//     }
//   }
//
//   /// Determine if a request should be retried based on status code
//   bool _shouldRetry(int statusCode) {
//     return statusCode == 429 || // Too Many Requests
//         statusCode >= 500;   // Server errors
//   }
//
//   /// Handle retry logic with exponential backoff
//   Future<EmailResult> _handleRetry(
//       String toEmail, String subject, String message,
//       String managerName, String actionType, int retryCount,
//       {required String error}
//       ) async {
//     if (retryCount < _maxRetries) {
//       final delay = _retryDelay * (retryCount + 1);
//       print('⏳ Retrying in ${delay.inSeconds} seconds...');
//       await Future.delayed(delay);
//
//       return sendManagerNotification(
//         toEmail: toEmail,
//         subject: subject,
//         message: message,
//         managerName: managerName,
//         actionType: actionType,
//         retryCount: retryCount + 1,
//       );
//     }
//
//     return EmailResult.success(false, error: error);
//   }
//
//   /// Check if email service is properly configured
//   static bool get isConfigured {
//     try {
//       final apiKey = EnvConfig.sendGridApiKey;
//       return apiKey.isNotEmpty && apiKey.startsWith('SG.');
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// Get service status information
//   static Map<String, dynamic> get serviceStatus {
//     return {
//       'configured': isConfigured,
//       'api_key_length': EnvConfig.sendGridApiKey.length,
//       'max_retries': _maxRetries,
//       'retry_delay': _retryDelay.toString(),
//     };
//   }
// }
//
// /// Result class for email sending operations
// class EmailResult {
//   final bool success;
//   final String? error;
//   final bool shouldRetry;
//
//   const EmailResult({
//     required this.success,
//     this.error,
//     this.shouldRetry = false,
//   });
//
//   factory EmailResult.success(bool success, {String? error}) {
//     return EmailResult(success: success, error: error);
//   }
//
//   factory EmailResult.retry({String? error}) {
//     return EmailResult(success: false, error: error, shouldRetry: true);
//   }
//
//   @override
//   String toString() {
//     if (success) {
//       return 'EmailResult: Success';
//     } else if (shouldRetry) {
//       return 'EmailResult: Retry needed - $error';
//     } else {
//       return 'EmailResult: Failed - $error';
//     }
//   }
// }
//
// /// Email templates for different manager actions
// class ManagerEmailTemplates {
//   static String getBanNotification(String managerName) {
//     return '''
//       Dear $managerName,
//
//       Your manager account has been temporarily suspended by the system administrator.
//
//       During this suspension period, you will not be able to access the system.
//
//       If you believe this is a mistake or would like to appeal this decision, please contact our support team.
//
//       Best regards,
//       SaveEarth System Administration Team
//     ''';
//   }
//
//   static String getRecoverNotification(String managerName) {
//     return '''
//       Dear $managerName,
//
//       Your manager account has been successfully recovered and restored.
//
//       You can now access the system with your existing credentials.
//
//       If you experience any issues logging in, please contact our support team.
//
//       Welcome back!
//
//       Best regards,
//       SaveEarth System Administration Team
//     ''';
//   }
//
//   static String getUpdateNotification(String managerName, List<String> changes) {
//     final changesText = changes.isEmpty ?
//     'Your account information has been updated.' :
//     'The following changes were made to your account:\n${changes.join('\n')}';
//
//     return '''
//       Dear $managerName,
//
//       $changesText
//
//       If you did not request these changes or believe this is an error, please contact our support team immediately.
//
//       Best regards,
//       SaveEarth System Administration Team
//     ''';
//   }
// }