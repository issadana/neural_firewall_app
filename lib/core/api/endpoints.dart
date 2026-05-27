import 'package:Sentri/core/constants/api_constants.dart';

/// Base endpoints class
/// Note: For better organization and to avoid merge conflicts,
/// create feature-specific endpoint classes in each feature's data/endpoints folder
/// Example: lib/features/sample/data/endpoints/sample_endpoints.dart
class Endpoints {
  Endpoints._();

  static String get baseUrl => ApiConstants.baseUrl;
  
  // Core/shared endpoints can be added here
  // For feature-specific endpoints, create per-feature endpoint files
}