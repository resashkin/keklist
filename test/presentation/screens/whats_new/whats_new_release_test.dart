import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/constants/onboarding_constants.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/whats_new/whats_new_release.dart';

void main() {
  final DateTime seenAt = DateTime(2026, 11, 1, 10);
  final DateTime nextDay = DateTime(2026, 11, 2, 9);

  KeklistSettings settings({String? seenRelease = WhatsNewRelease.release, String? promptedRelease}) =>
      KeklistSettings.initial().copyWith(
        whatsNewSeenRelease: seenRelease,
        whatsNewSeenAt: seenRelease == null ? null : seenAt,
        reviewPromptedRelease: promptedRelease,
      );

  List<Mind> minds(int count, {DateTime? at, String idPrefix = ''}) => [
    for (int i = 0; i < count; i++)
      Mind(
        id: '$idPrefix$i',
        note: 'note',
        dayIndex: 0,
        creationDate: at ?? seenAt.add(Duration(minutes: i + 1)),
        sortIndex: i,
        rootId: null,
      ),
  ];

  group('shouldShow', () {
    test('shows when no release was seen', () {
      expect(WhatsNewRelease.shouldShow(settings(seenRelease: null)), isTrue);
    });

    test('shows when an older release was seen', () {
      expect(WhatsNewRelease.shouldShow(settings(seenRelease: '5.0')), isTrue);
    });

    test('does not show the same release twice', () {
      expect(WhatsNewRelease.shouldShow(settings()), isFalse);
    });
  });

  group('shouldAskForReview', () {
    test('asks after five minds made since What\'s New, on a later day', () {
      expect(WhatsNewRelease.shouldAskForReview(settings: settings(), minds: minds(5), now: nextDay), isTrue);
    });

    test('waits for the fifth mind', () {
      expect(WhatsNewRelease.shouldAskForReview(settings: settings(), minds: minds(4), now: nextDay), isFalse);
    });

    test('never asks on the day What\'s New was seen', () {
      expect(WhatsNewRelease.shouldAskForReview(settings: settings(), minds: minds(9), now: seenAt), isFalse);
    });

    test('ignores minds made before What\'s New', () {
      final List<Mind> old = minds(9, at: seenAt.subtract(const Duration(days: 30)));
      expect(WhatsNewRelease.shouldAskForReview(settings: settings(), minds: old, now: nextDay), isFalse);
    });

    test('ignores onboarding minds', () {
      final List<Mind> onboarding = minds(9, idPrefix: OnboardingConstants.onboardingIdPrefix);
      expect(WhatsNewRelease.shouldAskForReview(settings: settings(), minds: onboarding, now: nextDay), isFalse);
    });

    test('asks once per release', () {
      final KeklistSettings prompted = settings(promptedRelease: WhatsNewRelease.release);
      expect(WhatsNewRelease.shouldAskForReview(settings: prompted, minds: minds(9), now: nextDay), isFalse);
    });

    test('does not ask before What\'s New of this release was seen', () {
      expect(
        WhatsNewRelease.shouldAskForReview(settings: settings(seenRelease: '5.0'), minds: minds(9), now: nextDay),
        isFalse,
      );
    });
  });
}
