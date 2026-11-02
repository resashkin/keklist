import 'package:keklist/l10n/app_localizations.dart';

class OnboardingConstants {
  /// Prefix for onboarding mind IDs
  static const String onboardingIdPrefix = 'ONBOARDING_';

  /// Check if a mind ID belongs to onboarding
  static bool isOnboardingMindId(String id) => id.startsWith(onboardingIdPrefix);

  /// Check if a mind is an onboarding mind (parent or child)
  static bool isOnboardingMind(String id, String? rootId) {
    // If the mind's ID starts with prefix, it's a parent onboarding mind
    if (isOnboardingMindId(id)) return true;
    // If the rootId starts with prefix, it's a child of onboarding mind
    if (rootId != null && isOnboardingMindId(rootId)) return true;
    return false;
  }

  // Parent minds (main educational minds)
  static List<OnboardingMindData> parentMinds = [
    OnboardingMindData(emotionEmoji: '😄', translation: (l10n) => l10n.onboardingMind1, sortIndex: 0),
    OnboardingMindData(emotionEmoji: '❤️', translation: (l10n) => l10n.onboardingMind2, sortIndex: 1),
    OnboardingMindData(translation: (l10n) => l10n.onboardingMind3, sortIndex: 2),
    OnboardingMindData(translation: (l10n) => l10n.onboardingMind4, sortIndex: 3),
    OnboardingMindData(emotionEmoji: '😨', translation: (l10n) => l10n.onboardingMind5, sortIndex: 4),
    OnboardingMindData(emotionEmoji: '😄', translation: (l10n) => l10n.onboardingMind6, sortIndex: 5),
  ];

  // Comment minds (children of parent minds) - indexed by parent sortIndex
  static Map<int, List<String Function(AppLocalizations)>> commentMinds = {
    1: [
      (l10n) => l10n.onboardingMind2Comment1,
      (l10n) => l10n.onboardingMind2Comment2,
    ], // Comments for mind 2
  };
}

class OnboardingMindData {
  /// Emoji of the starter emotion (see `EmotionSeed.emojis`) the mind is tagged with.
  final String? emotionEmoji;
  final String Function(AppLocalizations) translation;
  final int sortIndex;

  OnboardingMindData({
    this.emotionEmoji,
    required this.translation,
    required this.sortIndex,
  });
}
