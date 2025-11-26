class EmailConfig {
  static const String sendGridApiKey = String.fromEnvironment('SENDGRID_API_KEY');
  static const String smtpHost = String.fromEnvironment('SMTP_HOST');
  static const String smtpUsername = String.fromEnvironment('SMTP_USERNAME');
  static const String smtpPassword = String.fromEnvironment('SMTP_PASSWORD');
  static const int smtpPort = 587;

  static bool get isSendGridConfigured => sendGridApiKey.isNotEmpty;
  static bool get isSmtpConfigured => smtpHost.isNotEmpty && smtpUsername.isNotEmpty;
}