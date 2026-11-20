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

/// Shown in the round-video camera circle while "recording" in screenshot builds; the simulator has no camera.
const String kDemoRoundFacePath = 'video/demo_round_face.jpg';

/// Days back from today, used by the capture test to open the right day.
const int kDemoVoiceDayOffset = 1;
const int kDemoTripDayOffset = 3;

/// Today's three notes and three photos alternate in time: slot `i` is `(kDemoTodaySlots - i) × kDemoTodaySlotStep`
/// before now. On a 3-column grid each wide note and the photo after it fill a row exactly.
/// Photos take [kDemoTodayPhotoSlots]; `screenshots/prepare_media.py` stamps them with the same rule.
const int kDemoTodaySlots = 6;
const Duration kDemoTodaySlotStep = Duration(minutes: 35);
const List<int> kDemoTodayPhotoSlots = [1, 3, 5];
const List<int> _kDemoTodayMindSlots = [0, 2, 4];

Future<void> seedScreenshotDemo({
  required SettingsRepository settings,
  required MindRepository minds,
  required EmotionRepository emotions,
}) async {
  await settings.updateSettings(
    settings.value.copyWith(
      userName: 'Alex',
      language: SupportedLanguage.english,
      themePreference: KeklistThemeMode.dark,
      hasSeenLazyOnboarding: true,
      hasSeededEmotions: true,
      isAnalyticsEnabled: false,
      whatsNewSeenRelease: WhatsNewRelease.release,
      whatsNewSeenAt: DateTime.now(),
      reviewPromptedRelease: WhatsNewRelease.release,
      // Notes and photos mixed in time order: a wide note and a photo per row of three.
      dayFeed: const DayFeedSettings(columnCount: 3, mindCellSpan: 2, grouping: FeedGrouping.none),
      shakeDiscoveredScreenIds: const {
        ShakeScreenIds.day,
        ShakeScreenIds.settings,
        ShakeScreenIds.insights,
        ShakeScreenIds.calendar,
        ShakeScreenIds.story,
      },
    ),
  );
  await emotions.deleteEmotions();
  await emotions.createEmotions(emotions: _emotions);
  await minds.deleteMinds();
  await minds.createMinds(minds: _minds());
}

final DateTime _created = DateTime(2026, 1, 1);

Emotion _emotion(String id, String emoji, String title, {int order = 0}) => Emotion(
  id: id,
  title: title,
  emoji: emoji,
  parentId: null,
  isArchived: false,
  orderIndex: order,
  creationDate: _created,
);

final List<Emotion> _emotions = [
  _emotion('joy', '😄', 'Joy', order: 0),
  _emotion('calm', '😌', 'Calm', order: 1),
  _emotion('grateful', '🙏', 'Grateful', order: 2),
  _emotion('proud', '💪', 'Proud', order: 3),
  _emotion('inspired', '✨', 'Inspired', order: 4),
  _emotion('love', '❤️', 'Love', order: 5),
  _emotion('warmth', '🤗', 'Warmth', order: 6),
  _emotion('excited', '🤩', 'Excited', order: 7),
  _emotion('hopeful', '🌱', 'Hopeful', order: 8),
  _emotion('curious', '🧐', 'Curious', order: 9),
  _emotion('relaxed', '🛁', 'Relaxed', order: 10),
  _emotion('nostalgic', '📷', 'Nostalgic', order: 11),
  _emotion('sad', '😢', 'Sad', order: 12),
  _emotion('tired', '🥱', 'Tired', order: 13),
  _emotion('lonely', '🌧️', 'Lonely', order: 14),
  _emotion('fear', '😨', 'Fear', order: 15),
  _emotion('anxious', '😬', 'Anxious', order: 16),
  _emotion('stressed', '🤯', 'Stressed', order: 17),
  _emotion('angry', '😠', 'Angry', order: 18),
  _emotion('annoyed', '😤', 'Annoyed', order: 19),
  _emotion('bored', '🙄', 'Bored', order: 20),
  _emotion('confused', '😵‍💫', 'Confused', order: 21),
  _emotion('content', '😊', 'Content', order: 22),
  _emotion('loved', '🥰', 'Loved', order: 23),
  _emotion('playful', '😜', 'Playful', order: 24),
  _emotion('amazed', '😲', 'Amazed', order: 25),
  _emotion('confident', '😎', 'Confident', order: 26),
  _emotion('relieved', '😮‍💨', 'Relieved', order: 27),
  _emotion('cozy', '☕', 'Cozy', order: 28),
  _emotion('motivated', '🚀', 'Motivated', order: 29),
  _emotion('focused', '🎯', 'Focused', order: 30),
  _emotion('sleepy', '😴', 'Sleepy', order: 31),
  _emotion('overwhelmed', '😩', 'Overwhelmed', order: 32),
  _emotion('guilty', '😔', 'Guilty', order: 33),
  _emotion('embarrassed', '😳', 'Embarrassed', order: 34),
  _emotion('disappointed', '😞', 'Disappointed', order: 35),
  _emotion('homesick', '🏡', 'Homesick', order: 36),
  _emotion('jealous', '😒', 'Jealous', order: 37),
];

typedef _Entry = (int daysAgo, String text, List<String> emotions);

const List<_Entry> _textEntries = [
  (0, 'Morning run by the river, 6 km', ['proud']),
  (0, 'Coffee with Anna. We laughed for an hour', ['warmth', 'joy']),
  (0, 'A bit anxious about tomorrow’s talk', ['anxious']),
  (1, 'Rainy day, stayed in and cooked soup', ['calm']),
  (1, 'Called mom', ['grateful', 'love']),
  (2, 'Missed the train, read a book instead', ['annoyed', 'calm']),
  (2, 'New idea for the garden', ['inspired']),
  (2, 'Finished the hard part of the project', ['proud', 'calm']),
  (2, 'Read 30 pages before sleep', ['calm']),
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
      creationDate: daysAgo == 0 && sortIndex < _kDemoTodayMindSlots.length
          ? DateTime.now().subtract(kDemoTodaySlotStep * (kDemoTodaySlots - _kDemoTodayMindSlots[sortIndex]))
          : DateUtils.getDateFromDayIndex(dayIndex).add(Duration(hours: 9 + sortIndex * 2)),
      sortIndex: sortIndex,
      rootId: null,
      emotionIds: emotionIds,
    );
  }

  String withText(BaseMindNotePiece media, String text) =>
      MindNoteContent.fromPieces([MindNoteText(text), media]).toRawNoteString();

  final List<Mind> textMinds = [
    for (final (daysAgo, text, emotionIds) in _textEntries) mind(daysAgo, text, emotionIds),
  ];
  final Mind talk = textMinds.firstWhere((mind) => mind.note.startsWith('A bit anxious'));
  Mind reply(int index, String note, int minutesLater) => Mind(
    id: '${talk.id}-reply-$index',
    note: note,
    dayIndex: talk.dayIndex,
    creationDate: talk.creationDate.add(Duration(minutes: minutesLater)),
    sortIndex: index,
    rootId: talk.id,
    emotionIds: const [],
  );

  return [
    ...textMinds,
    reply(0, 'Practiced it twice, it flows now', 40),
    reply(1, 'Going to bed early tonight', 150),
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
