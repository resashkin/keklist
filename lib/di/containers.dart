import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:hive_ce/hive.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/tabs/tabs_settings_repository.dart';
import 'package:keklist/domain/repositories/tabs/tabs_settings_shared_preferences_repository.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/repositories/mind/mind_hive_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/emotion/object/emotion_object.dart';
import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/emotion/emotion_hive_repository.dart';
import 'package:keklist/domain/repositories/settings/object/settings_object.dart';
import 'package:keklist/domain/repositories/settings/settings_hive_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/repositories/bloc_log_settings/bloc_log_settings_hive_repository.dart';
import 'package:keklist/domain/repositories/bloc_log_settings/bloc_log_settings_repository.dart';
import 'package:keklist/domain/repositories/debug_menu/debug_menu_repository.dart';
import 'package:keklist/domain/repositories/debug_menu/debug_menu_hive_repository.dart';
import 'package:keklist/domain/repositories/debug_menu/object/debug_menu_object.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/media_index/media_index_hive_repository.dart';
import 'package:keklist/domain/repositories/media_index/object/media_day_index_object.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/photo_library_gallery_source.dart';
import 'package:keklist/domain/repositories/weather/object/weather_cache_object.dart';
import 'package:keklist/domain/repositories/weather/weather_hive_repository.dart';
import 'package:keklist/domain/repositories/weather/weather_repository.dart';
import 'package:keklist/domain/services/export_import/export_import_service.dart';
import 'package:keklist/domain/services/weather/weather_api_service.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:keklist/presentation/cubits/mind_searcher/mind_searcher_cubit.dart';

final class MainContainer {
  final StreamingSharedPreferences _streamingSharedPreferences;

  MainContainer({required StreamingSharedPreferences streamingSharedPreferences})
      : _streamingSharedPreferences = streamingSharedPreferences;

  Injector initialize(Injector injector) {
    injector.map<MindSearcherCubit>(
      (injector) => MindSearcherCubit(repository: injector.get<MindRepository>()),
    );
    injector.map<MindRepository>(
      (injector) => MindHiveRepository(box: Hive.box<MindObject>(HiveConstants.mindBoxName)),
    );
    injector.map<EmotionRepository>(
      (injector) => EmotionHiveRepository(box: Hive.box<EmotionObject>(HiveConstants.emotionBoxName)),
      isSingleton: true,
    );
    injector.map<SettingsRepository>(
      (injector) => SettingsHiveRepository(box: Hive.box<SettingsObject>(HiveConstants.settingsBoxName)),
    );
    injector.map<DebugMenuRepository>(
      (injector) => DebugMenuHiveRepository(box: Hive.box<DebugMenuObject>(HiveConstants.debugMenuBoxName)),
      isSingleton: true,
    );
    injector.map<BlocLogSettingsRepository>(
      (injector) => BlocLogSettingsHiveRepository(box: Hive.box(HiveConstants.blocLogSettingsBoxName)),
      isSingleton: true,
    );
    injector.map<GalleryIndexer>(
      (_) => GalleryIndexer(
        repository: MediaIndexHiveRepository(
          daysBox: Hive.box<MediaDayIndexObject>(HiveConstants.mediaDayIndexBoxName),
          metaBox: Hive.box(HiveConstants.mediaIndexMetaBoxName),
        ),
        source: const PhotoLibraryGallerySource(),
      ),
      isSingleton: true,
    );
    injector.map<AppFileRepository>(
      (_) => const AppFileRepository(),
      isSingleton: true,
    );
    injector.map<ExportImportService>(
      (injector) => ExportImportService(
        mindRepository: injector.get<MindRepository>(),
        fileRepository: injector.get<AppFileRepository>(),
        emotionRepository: injector.get<EmotionRepository>(),
      ),
      isSingleton: true,
    );
    injector.map<TabsSettingsRepository>(
      (injector) => TabsSettingsSharedPreferencesRepository(preferences: _streamingSharedPreferences),
    );
    injector.map<WeatherRepository>(
      (injector) => WeatherHiveRepository(
        box: Hive.box<WeatherCacheObject>(HiveConstants.weatherCacheBoxName),
        apiService: WeatherApiService(),
      ),
      isSingleton: true,
    );
    // BLoCs that need async-gap-safe dispatch (file pickers, native callbacks)
    // are registered here as singletons so sendEventTo can fall back to DI
    // when the originating widget's State has unmounted.
    injector.map<SettingsBloc>(
      (i) => SettingsBloc(
        repository: i.get<SettingsRepository>(),
        exportImportService: i.get<ExportImportService>(),
      ),
      isSingleton: true,
    );
    injector.map<EmotionBloc>(
      (i) => EmotionBloc(
        emotionRepository: i.get<EmotionRepository>(),
        mindRepository: i.get<MindRepository>(),
        settingsRepository: i.get<SettingsRepository>(),
      ),
      isSingleton: true,
    );
    return injector;
  }
}
