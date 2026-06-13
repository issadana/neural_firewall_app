/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Pagination
  static const int defaultPageSize = 20;
  static const int initialPage = 0;

  // API Timeouts (3 minutes for meal plan generation)
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 180);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);

  static const String blacklistBox = 'blacklist_box';
  static const double defaultBlockThreshold = 0.80;
  static const double defaultWarnThreshold = 0.60;
  static const int maxTrafficEntries = 200;
  static const int maxSparklineEntries = 60;
  static const int defaultFloodPktPerSec = 1000;
  static const int defaultSynFloodPerSec = 100;
  static const String tunAddress = '10.0.0.2';
  static const String appName = 'Sentri';
  static const String appVersion = '1.0.0';
}

