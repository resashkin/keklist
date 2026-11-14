import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/domain/services/language_manager.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/screens/whats_new/whats_new_release.dart';

/// Builds made with `--dart-define=KEKLIST_SCREENSHOTS=true` replace all data with the demo set below.
/// Only `screenshots/capture.sh` makes such builds; see `documentation/STORE_SCREENSHOTS.md`.
const bool kScreenshotMode = bool.fromEnvironment('KEKLIST_SCREENSHOTS');

/// Media the capture script copies into `Documents/user_files` before the app starts.
const String kDemoAudioPath = 'audio/demo_voice.m4a';
const String kDemoVideoPath = 'video/demo_round.mp4';

/// Days back from today, used by the capture test to open the right day.
const int kDemoVoiceDayOffset = 1;
const int kDemoTripDayOffset = 3;

Future<void> seedScreenshotDemo({
  required SettingsRepository settings,
  required MindRepository minds,
  required EmotionRepository emotions,
}) async {
  await settings.updateSettings(
    settings.value.copyWith(
      userName: 'Alex',
      language: SupportedLanguage.english,
      themePreference: KeklistThemeMode.light,
      hasSeenLazyOnboarding: true,
      hasSeededEmotions: true,
      isAnalyticsEnabled: false,
      whatsNewSeenRelease: WhatsNewRelease.release,
      whatsNewSeenAt: DateTime.now(),
      reviewPromptedRelease: WhatsNewRelease.release,
      shakeDiscoveredScreenIds: const {
        ShakeScreenIds.day,
        ShakeScreenIds.settings,
        ShakeScreenIds.insights,
        ShakeScreenIds.calendar,
        ShakeScreenIds.story,
        ShakeScreenIds.creator,
      },
    ),
  );
  await emotions.deleteEmotions();
  await emotions.createEmotions(emotions: _emotions);
  await minds.deleteMinds();
  await minds.createMinds(minds: _minds());
}

final DateTime _created = DateTime(2026, 1, 1);

Emotion _emotion(String id, String emoji, String title, {String? parent, int order = 0}) => Emotion(
  id: id,
  title: title,
  emoji: emoji,
  parentId: parent,
  isArchived: false,
  orderIndex: order,
  creationDate: _created,
);

final List<Emotion> _emotions = [
  _emotion('joy', '😄', 'Joy', order: 0),
  _emotion('calm', '😌', 'Calm', parent: 'joy', order: 0),
  _emotion('grateful', '🙏', 'Grateful', parent: 'joy', order: 1),
  _emotion('proud', '💪', 'Proud', parent: 'joy', order: 2),
  _emotion('inspired', '✨', 'Inspired', parent: 'joy', order: 3),
  _emotion('love', '❤️', 'Love', order: 1),
  _emotion('warmth', '🤗', 'Warmth', parent: 'love', order: 0),
  _emotion('sad', '😢', 'Sad', order: 2),
  _emotion('tired', '🥱', 'Tired', parent: 'sad', order: 0),
  _emotion('lonely', '🌧️', 'Lonely', parent: 'sad', order: 1),
  _emotion('fear', '😨', 'Fear', order: 3),
  _emotion('anxious', '😬', 'Anxious', parent: 'fear', order: 0),
  _emotion('angry', '😠', 'Angry', order: 4),
  _emotion('annoyed', '😤', 'Annoyed', parent: 'angry', order: 0),
];

typedef _Entry = (int daysAgo, String text, List<String> emotions);

const List<_Entry> _textEntries = [
  (0, 'Morning run by the river, 6 km', ['proud']),
  (0, 'Coffee with Anna. We laughed for an hour', ['warmth', 'joy']),
  (0, 'Finished the hard part of the project', ['proud', 'calm']),
  (0, 'A bit anxious about tomorrow’s talk', ['anxious']),
  (0, 'Read 30 pages before sleep', ['calm']),
  (1, 'Rainy day, stayed in and cooked soup', ['calm']),
  (1, 'Called mom', ['grateful', 'love']),
  (2, 'Missed the train, read a book instead', ['annoyed', 'calm']),
  (2, 'New idea for the garden', ['inspired']),
  (3, 'Day trip to the mountains with friends', ['joy', 'inspired']),
  (3, 'The lake was so clear', ['calm', 'grateful']),
  (4, 'Long day at work', ['tired']),
  (5, 'Dinner with the team', ['warmth']),
  (6, 'Felt lonely in the evening', ['lonely']),
  (7, 'Yoga in the park', ['calm']),
  (8, 'Got good feedback on my work', ['proud', 'joy']),
  (9, 'Argued about nothing', ['angry']),
  (10, 'Slow Sunday', ['calm', 'grateful']),
  (12, 'Tried a new pizza place', ['joy']),
  (13, 'Worried about the deadline', ['anxious']),
  (15, 'Saw the stars outside the city', ['inspired', 'calm']),
  (17, 'Helped a neighbour move', ['warmth', 'tired']),
  (20, 'First swim of the season', ['joy', 'proud']),
];

List<Mind> _minds() {
  final int today = DateUtils.getTodayIndex();
  final Map<int, int> sortByDay = {};
  Mind mind(int daysAgo, String note, List<String> emotionIds) {
    final int dayIndex = today - daysAgo;
    final int sortIndex = sortByDay.update(dayIndex, (value) => value + 1, ifAbsent: () => 0);
    return Mind(
      id: 'demo-$dayIndex-$sortIndex',
      note: note,
      dayIndex: dayIndex,
      creationDate: DateUtils.getDateFromDayIndex(dayIndex).add(Duration(hours: 9 + sortIndex * 2)),
      sortIndex: sortIndex,
      rootId: null,
      emotionIds: emotionIds,
    );
  }

  String withText(BaseMindNotePiece media, String text) =>
      MindNoteContent.fromPieces([MindNoteText(text), media]).toRawNoteString();

  return [
    for (final (daysAgo, text, emotionIds) in _textEntries) mind(daysAgo, text, emotionIds),
    mind(
      kDemoVoiceDayOffset,
      withText(const MindNoteAudio(appRelativeAbsoulutePath: kDemoAudioPath, durationSeconds: 14), 'Thoughts on the way home'),
      ['calm'],
    ),
    mind(
      kDemoVoiceDayOffset,
      withText(const MindNoteVideo(appRelativePath: kDemoVideoPath, durationSeconds: 8), 'Sunset from the balcony'),
      ['grateful'],
    ),
  ];
}
