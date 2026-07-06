// DEPENDENCY INJECTION SETUP - Central Warehouse Configuration

// PURPOSE:
//    Instead of manually creating and passing objects through constructors,
//    this warehouse automatically delivers the right objects to the right
//    places at the right time.

// HOW IT WORKS:
//    1. You annotate classes with @injectable or @singleton
//    2. Run: flutter pub run build_runner build
//    3. Code generator creates injection.config.dart with all registrations
//    4. Call configureDependencies() in main.dart before runApp()
//    5. Use getIt<ClassName>() anywhere to get instances

import 'package:get_it/get_it.dart'; // Service locator package
import 'package:injectable/injectable.dart'; // Auto-registration annotations
import 'injection.config.dart'; // Generated registration code

// WHY GLOBAL?
//   Avoids passing objects through 10 constructor layers
//   Any widget/class can request what it needs directly
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Method name in generated file
  preferRelativeImports: true, // Use relative paths: '../path/file.dart' instead of 'package:app/path/file.dart'
  asExtension: true, // Create as extension method
)
Future<void> configureDependencies() async {
  // MUST be awaited: init() is async because of the @preResolve dependencies
  // (SharedPreferences, the ML models). Without the await, this returns while
  // the container is only half-built and later getIt<T>() lookups (AppBootstrap,
  // the cubits) throw "not registered".
  await getIt.init(); // ← Calls auto-generated registration code
}