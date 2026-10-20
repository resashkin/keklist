import 'package:keklist/domain/migrations/migration.dart';
import 'package:keklist/domain/services/emotions/emotion_seeder.dart';
import 'package:keklist/domain/services/emotions/legacy_emoji_linker.dart';

/// Migration v4: the main emoji became `legacyEmoji`; link it to a matching
/// emotion once, seeding the starter emotions first so common emoji can match.
class MigrationV4LegacyEmojiToEmotions extends Migration {
  @override
  int get version => 4;

  @override
  String get description => 'Link legacy main emoji to matching emotions';

  @override
  Future<MigrationResult> run(MigrationContext context) async {
    await EmotionSeeder.seedIfNeeded(
      emotionRepository: context.emotionRepository,
      settingsRepository: context.settingsRepository,
    );
    final linked = LegacyEmojiLinker.link(
      minds: await context.mindRepository.obtainMinds(),
      emotions: await context.emotionRepository.obtainEmotions(),
    );
    if (linked.isNotEmpty) await context.mindRepository.updateMinds(minds: linked);
    return MigrationResult.success(message: 'linked ${linked.length} minds');
  }
}
