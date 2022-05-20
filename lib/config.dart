class EnvironmentConfig {
  static const apiKey = String.fromEnvironment(
    'API_KEY',
  );
  static const apiUrl = String.fromEnvironment(
    'API_URL',
  );
}
