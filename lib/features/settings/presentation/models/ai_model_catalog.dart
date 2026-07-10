import 'package:flutter/material.dart';

import 'package:Sentri/core/theme/app_colors.dart';

/// Presentation metadata for every on-device AI protection model the app ships.
///
/// Descriptions are intentionally written for non-technical users — the
/// technical name is kept separately for the curious in the details popup.
class AiModelInfo {
  /// Stable id, also used as the SharedPreferences key suffix (`model_<id>`).
  final String id;

  /// Friendly, human name shown on the card.
  final String name;

  /// One-line plain-language summary shown under the name.
  final String tagline;

  final IconData icon;
  final Color accent;

  /// A short friendly paragraph explaining the threat in everyday terms.
  final String overview;

  /// Plain-language bullets of what the model keeps the user safe from.
  final List<String> protects;

  /// The real/technical model name, surfaced for advanced users.
  final String techName;

  /// Number of network features the model inspects per packet.
  final int features;

  /// Headline accuracy figure shown as a stat chip.
  final String accuracy;

  const AiModelInfo({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.accent,
    required this.overview,
    required this.protects,
    required this.techName,
    required this.features,
    required this.accuracy,
  });
}

/// The full catalog of shipped models, in display order.
const List<AiModelInfo> kAiModelCatalog = [
  AiModelInfo(
    id: 'bruteForce',
    name: 'Brute Force Guard',
    tagline: 'Stops repeated password-guessing attempts',
    icon: Icons.lock_person_rounded,
    accent: AppColors.primary,
    overview:
        'Some attackers try thousands of password combinations in a row, hoping '
        'one finally works. This guard recognises that pattern instantly and '
        'shuts the door before anyone can sneak in.',
    protects: [
      'Repeated login attempts',
      'Automated password-guessing bots',
      'Stolen-credential testing',
    ],
    techName: 'Brute-Force Detection model',
    features: 4,
    accuracy: '96.61%',
  ),
  AiModelInfo(
    id: 'dos',
    name: 'DoS Shield',
    tagline: 'Blocks traffic floods that slow you down',
    icon: Icons.bolt_rounded,
    accent: AppColors.statusWarning,
    overview:
        'A denial-of-service attack buries your connection under a flood of junk '
        'traffic to knock you offline. This shield spots the flood early and '
        'filters it out so things keep running smoothly.',
    protects: [
      'Sudden connection slowdowns',
      'Service outages',
      'Junk traffic floods',
    ],
    techName: 'DoS Specialist model',
    features: 5,
    accuracy: '99.52%',
  ),
  AiModelInfo(
    id: 'dosHulk',
    name: 'HULK Defender',
    tagline: 'Catches rapid-fire web request storms',
    icon: Icons.whatshot_rounded,
    accent: AppColors.statusDanger,
    overview:
        'HULK attacks bombard a server with a storm of constantly-changing '
        'requests to overwhelm it. This defender learns that storm’s signature '
        'and blocks it before your device is overloaded.',
    protects: [
      'Web server overload',
      'Rapid request storms',
      'Resource exhaustion',
    ],
    techName: 'DoS Specialist (HULK) model',
    features: 10,
    accuracy: '99.84%',
  ),
  AiModelInfo(
    id: 'loic',
    name: 'Flood Cannon Detector',
    tagline: 'Detects popular group attack tools',
    icon: Icons.rocket_launch_rounded,
    accent: AppColors.accent,
    overview:
        'LOIC is a well-known tool that lets attackers team up and aim a flood of '
        'traffic at a single target. This detector recognises its fingerprint and '
        'flags the attack as it starts.',
    protects: [
      'Coordinated group attacks',
      'Volunteer “botnet” floods',
      'Targeted traffic cannons',
    ],
    techName: 'LOIC Detection model',
    features: 10,
    accuracy: '99.22%',
  ),
  AiModelInfo(
    id: 'hoic',
    name: 'Heavy Storm Detector',
    tagline: 'Stops large, high-volume attack storms',
    icon: Icons.cyclone_rounded,
    accent: AppColors.statusCritical,
    overview:
        'HOIC is a powerful tool that can launch huge floods from many places at '
        'once. This detector is tuned for those massive, high-volume storms and '
        'catches them before they take you down.',
    protects: [
      'Large-scale DDoS storms',
      'Multi-source traffic floods',
      'Amplified “booster” attacks',
    ],
    techName: 'HOIC Detection model',
    features: 12,
    accuracy: '100%',
  ),
];
