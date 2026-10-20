import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/migrations/migration.dart';
import 'package:keklist/domain/migrations/migrations/migration_v4_legacy_emoji_to_emotions.dart';
import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/emotion_seed.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:mocktail/mocktail.dart';

class MockMindRepository extends Mock implements MindRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockEmotionRepository extends Mock implements EmotionRepository {}

Mind _mind(String id, String? legacyEmoji) => Mind(
  id: id,
  legacyEmoji: legacyEmoji,
  note: id,
  dayIndex: 0,
  sortIndex: 0,
  creationDate: DateTime.utc(2026),
  rootId: null,
);

void main() {
  late MockMindRepository minds;
  late MockSettingsRepository settings;
  late MockEmotionRepository emotions;
  late MigrationContext context;
  final List<Emotion> stored = [];

  setUp(() {
    minds = MockMindRepository();
    settings = MockSettingsRepository();
    emotions = MockEmotionRepository();
    stored.clear();
    registerFallbackValue(<Mind>[]);
    registerFallbackValue(<Emotion>[]);
    when(() => settings.value).thenReturn(KeklistSettings.initial());
    when(() => settings.updateHasSeededEmotions(any())).thenAnswer((_) async {});
    when(() => emotions.obtainEmotions()).thenAnswer((_) async => List.of(stored));
    when(() => emotions.createEmotions(emotions: any(named: 'emotions'))).thenAnswer((invocation) async {
      stored.addAll(invocation.namedArguments[#emotions] as Iterable<Emotion>);
    });
    when(() => minds.updateMinds(minds: any(named: 'minds'))).thenAnswer((_) async {});
    context = MigrationContext(
      mindRepository: minds,
      settingsRepository: settings,
      fileRepository: const AppFileRepository(),
      emotionRepository: emotions,
    );
  });

  test('seeds starter emotions, then links only minds whose emoji matches one', () async {
    when(() => minds.obtainMinds()).thenAnswer((_) async => [_mind('joyful', '😄'), _mind('rocket', '🚀')]);

    final result = await MigrationV4LegacyEmojiToEmotions().run(context);

    expect(result.success, true);
    expect(stored.map((e) => e.emoji), EmotionSeed.emojis);
    final List<Mind> updated =
        verify(() => minds.updateMinds(minds: captureAny(named: 'minds'))).captured.single as List<Mind>;
    final String joyId = stored.firstWhere((e) => e.emoji == '😄').id;
    expect(updated.single.id, 'joyful');
    expect(updated.single.emotionIds, [joyId]);
  });

  test('writes nothing when no mind matches', () async {
    when(() => minds.obtainMinds()).thenAnswer((_) async => [_mind('rocket', '🚀'), _mind('none', null)]);

    await MigrationV4LegacyEmojiToEmotions().run(context);

    verifyNever(() => minds.updateMinds(minds: any(named: 'minds')));
  });
}
