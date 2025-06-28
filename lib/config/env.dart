/// Defines application runtime environments with strict type safety
enum AppEnvironment {
  /// Local development environment
  development,
  
  /// Pre-production testing environment
  staging,
  
  /// Live production environment
  production;

  /// Factory method to parse environment from string
  /// 
  /// Throws [FormatException] for invalid inputs to prevent silent failures
  static AppEnvironment parse(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.development;
      case 'stage':
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      default:
        throw FormatException('Invalid environment: $value');
    }
  }

  /// Returns true if running in production environment
  bool get isProduction => this == AppEnvironment.production;
  
  /// Returns true if running in development environment
  bool get isDevelopment => this == AppEnvironment.development;
}