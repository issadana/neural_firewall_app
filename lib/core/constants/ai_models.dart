/// Static asset locations + metadata for every on-device TFLite model the app
/// ships. All five models share a single root scaler file
/// ([AiModels.scalerParams]); each model has its own section inside it, keyed
/// by [AiModelSpec.scalerKey]. That section also carries the model's ordered
/// feature list, which [MlDataSource] uses to build inputs of the right length.
class AiModelSpec {
  /// Catalog id — matches `kAiModelCatalog` and the settings toggles.
  final String id;

  /// Human-readable name for the UI (e.g. blacklist tile, settings).
  final String label;

  /// Path to the `.tflite` asset.
  final String assetPath;

  /// Section name inside `scaler_params.json` (feature list + mean/scale).
  final String scalerKey;

  const AiModelSpec({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.scalerKey,
  });
}

class AiModels {
  /// Single scaler file holding one section per model.
  static const String scalerParams = 'assets/ai_models/scaler_params.json';

  static const AiModelSpec bruteForce = AiModelSpec(
    id: 'bruteForce',
    label: 'Brute Force',
    assetPath: 'assets/ai_models/bruteforce/bruteforce_detection_mobile.tflite',
    scalerKey: 'bruteforce_detection',
  );

  static const AiModelSpec dos = AiModelSpec(
    id: 'dos',
    label: 'DoS',
    assetPath: 'assets/ai_models/dos_specialist/dos_specialist_mobile.tflite',
    scalerKey: 'dos_specialist',
  );

  static const AiModelSpec dosHulk = AiModelSpec(
    id: 'dosHulk',
    label: 'DoS HULK',
    assetPath:
        'assets/ai_models/dos_specialist_hulk/dos_specialist_hulk_mobile.tflite',
    scalerKey: 'dos_specialist_hulk',
  );

  static const AiModelSpec loic = AiModelSpec(
    id: 'loic',
    label: 'LOIC',
    assetPath: 'assets/ai_models/loic/loic_mobile.tflite',
    scalerKey: 'loic',
  );

  static const AiModelSpec hoic = AiModelSpec(
    id: 'hoic',
    label: 'HOIC',
    assetPath: 'assets/ai_models/hoic/hoic_mobile.tflite',
    scalerKey: 'hoic',
  );

  /// All shipped models, in display order.
  static const List<AiModelSpec> all = [bruteForce, dos, dosHulk, loic, hoic];

  /// Look up a spec by catalog id; falls back to [bruteForce] for unknown ids.
  static AiModelSpec byId(String id) =>
      all.firstWhere((m) => m.id == id, orElse: () => bruteForce);

  /// Look up a spec by catalog id, or null when the id isn't recognised — lets
  /// callers fall back gracefully instead of silently getting [bruteForce].
  static AiModelSpec? tryById(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }
}
