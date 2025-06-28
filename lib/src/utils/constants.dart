/// Application-wide constants with clear documentation
class AppConstants {
  // API configuration
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String pineconeBaseUrl = 'https://controller.{region}.pinecone.io';
  
  // Local storage keys
  static const String prefFirstLaunch = 'first_launch';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLastAgent = 'last_agent';
  
  // Default values
  static const int defaultTokenLimit = 4096;
  static const double defaultTemperature = 0.7;
  static const int maxHistoryItems = 100;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration voiceInputTimeout = Duration(seconds: 60);
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double buttonBorderRadius = 24.0;
  static const double cardElevation = 2.0;
  
  // Animation durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  
  // Security
  static const int minPasswordLength = 8;
  static const int maxFailedAttempts = 5;
  
  // Error messages
  static const String networkErrorMessage = 'Network unavailable. Please check your connection.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  
  // Vector DB dimensions
  static const int embeddingDimensions = 768;
  
  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB
}