import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/constants/onboarding_constants.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart' show DateUtils;

/// One What's New slide: a looping muted clip from `assets/whats_new/` with a title and a line of text.
final class WhatsNewSlide {
  final String videoAsset;
  final String title;
  final String body;
  final String? footnote;

  const WhatsNewSlide({required this.videoAsset, required this.title, required this.body, this.footnote});
}

/// The release the What's New sheet announces; see `documentation/WHATS_NEW.md` for bumping it.
abstract final class WhatsNewRelease {
  static const String release = '6.0';
  static const int mindsBeforeReviewPrompt = 5;

  static List<WhatsNewSlide> slides(AppLocalizations l10n) => [
    WhatsNewSlide(videoAsset: _video('gallery'), title: l10n.whatsNewGalleryTitle, body: l10n.whatsNewGalleryBody),
    WhatsNewSlide(videoAsset: _video('circles'), title: l10n.whatsNewCirclesTitle, body: l10n.whatsNewCirclesBody),
    WhatsNewSlide(videoAsset: _video('shake'), title: l10n.whatsNewShakeTitle, body: l10n.whatsNewShakeBody),
    WhatsNewSlide(
      videoAsset: _video('web'),
      title: l10n.whatsNewWebTitle,
      body: l10n.whatsNewWebBody,
      footnote: l10n.whatsNewAlsoDesign,
    ),
  ];

  static bool shouldShow(KeklistSettings settings) => settings.whatsNewSeenRelease != release;

  /// Asks once per release, after [mindsBeforeReviewPrompt] minds made since What's New, and not on that same day.
  static bool shouldAskForReview({
    required KeklistSettings settings,
    required Iterable<Mind> minds,
    required DateTime now,
  }) {
    final DateTime? seenAt = settings.whatsNewSeenAt;
    if (settings.whatsNewSeenRelease != release || settings.reviewPromptedRelease == release) return false;
    if (seenAt == null || DateUtils.isSameDay(seenAt, now)) return false;
    final int newMinds = minds
        .where((mind) => mind.creationDate.isAfter(seenAt) && !OnboardingConstants.isOnboardingMind(mind.id, mind.rootId))
        .length;
    return newMinds >= mindsBeforeReviewPrompt;
  }

  static String _video(String name) => 'assets/whats_new/$name.mp4';
}
