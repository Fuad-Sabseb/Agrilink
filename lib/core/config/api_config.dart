/// API Configuration for different environments
/// Centralized configuration for all API endpoints and settings
class ApiConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // Base URLs for different environments
  static const Map<String, String> _baseUrls = {
    'development': 'https://dev-api.agrolink.et/v1',
    'staging': 'https://staging-api.agrolink.et/v1',
    'production': 'https://api.agrolink.et/v1',
  };

  /// Get base URL for current environment
  static String get baseUrl => _baseUrls[environment] ?? _baseUrls['development']!;

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API version
  static const String apiVersion = 'v1';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';

  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String sendOTPEndpoint = '/auth/send-otp';
  static const String verifyOTPEndpoint = '/auth/verify-otp';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String verifyTokenEndpoint = '/auth/verify-token';

  // User endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String updateProfileEndpoint = '/user/profile';
  static const String userPreferencesEndpoint = '/user/preferences';

  // Produce endpoints
  static const String produceListEndpoint = '/produce';
  static const String produceDetailEndpoint = '/produce/{id}';
  static const String createProduceEndpoint = '/produce';
  static const String updateProduceEndpoint = '/produce/{id}';
  static const String deleteProduceEndpoint = '/produce/{id}';

  // Order endpoints
  static const String ordersEndpoint = '/orders';
  static const String createOrderEndpoint = '/orders';
  static const String orderDetailEndpoint = '/orders/{id}';
  static const String updateOrderStatusEndpoint = '/orders/{id}/status';
  static const String buyerOrdersEndpoint = '/orders/buyer/{userId}';
  static const String farmerOrdersEndpoint = '/orders/farmer/{userId}';

  // Transport endpoints
  static const String transportRequestsEndpoint = '/transport/requests';
  static const String createTransportRequestEndpoint = '/transport/requests';
  static const String transporterTripsEndpoint = '/transport/trips/transporter/{transporterId}';
  static const String tripDetailEndpoint = '/transport/trips/{id}';
  static const String updateTripStatusEndpoint = '/transport/trips/{id}/status';

  // Market endpoints
  static const String marketsEndpoint = '/markets';
  static const String marketPricesEndpoint = '/markets/{id}/prices';
  static const String priceHistoryEndpoint = '/markets/prices/history';

  // File upload endpoints
  static const String uploadImageEndpoint = '/upload/image';
  static const String uploadDocumentEndpoint = '/upload/document';

  // Helper method to replace path parameters
  static String replacePath(String path, Map<String, String> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  // Check if in development mode
  static bool get isDevelopment => environment == 'development';

  // Check if in staging mode
  static bool get isStaging => environment == 'staging';

  // Check if in production mode
  static bool get isProduction => environment == 'production';

  // Enable/disable logging based on environment
  static bool get enableLogging => !isProduction;

  // Enable/disable debug features
  static bool get enableDebugFeatures => isDevelopment;
}
