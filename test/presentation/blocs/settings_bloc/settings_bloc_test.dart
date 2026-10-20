import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/export_import/export_import_service.dart';
import 'package:keklist/domain/services/language_manager.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockMindRepository extends Mock implements MindRepository {}

class MockAppFileRepository extends Mock implements AppFileRepository {}

class MockEmotionRepository extends Mock implements EmotionRepository {}

void main() {
  late MockSettingsRepository mockSettingsRepository;
  late SettingsBloc bloc;

  final currentSettings = KeklistSettings(
    isMindContentVisible: true,
    previousAppVersion: '1.0.0 1',
    themePreference: KeklistThemeMode.dark,
    interfaceStyle: KeklistInterfaceStyle.liquidGlass,
    shouldShowTitles: true,
    userName: 'kek',
    language: SupportedLanguage.english,
    dataSchemaVersion: 3,
    hasSeenLazyOnboarding: true,
    isDebugMenuVisible: false,
    isWeatherSourceEnabled: true,
    weatherLatitude: 1.5,
    weatherLongitude: 2.5,
    mediaFolderPath: '/media',
    isMediaFolderRecursive: true,
    hasSeededEmotions: true,
    dayFeed: const DayFeedSettings(columnCount: 5, mindCellSpan: 2, isMindTextVisible: false),
    hiddenSettingsItemIds: const {'weather'},
    shakeDiscoveredScreenIds: const {'day'},
  );

  setUpAll(() => registerFallbackValue(currentSettings));

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(() => mockSettingsRepository.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSettingsRepository.value).thenReturn(currentSettings);
    when(() => mockSettingsRepository.updateSettings(any())).thenAnswer((_) async {});
    bloc = SettingsBloc(
      repository: mockSettingsRepository,
      exportImportService: ExportImportService(
        mindRepository: MockMindRepository(),
        fileRepository: MockAppFileRepository(),
        emotionRepository: MockEmotionRepository(),
      ),
    );
  });

  tearDown(() => bloc.close());

  group('SettingsEnableDebugMenu', () {
    test('turns the debug menu on and keeps every other field', () async {
      bloc.add(const SettingsEnableDebugMenu());
      await Future.delayed(const Duration(milliseconds: 50));

      final updated =
          verify(() => mockSettingsRepository.updateSettings(captureAny())).captured.single as KeklistSettings;
      expect(updated.isDebugMenuVisible, isTrue);
      expect(updated.hasSeededEmotions, isTrue);
      expect(updated.dayFeed, same(currentSettings.dayFeed));
      expect(updated.hiddenSettingsItemIds, {'weather'});
      expect(updated.shakeDiscoveredScreenIds, {'day'});
      expect(updated.isWeatherSourceEnabled, isTrue);
      expect(updated.mediaFolderPath, '/media');
      expect(updated.dataSchemaVersion, 3);
    });
  });
}
