part of 'settings_bloc.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsGet extends SettingsEvent {}

final class SettingsExport extends SettingsEvent {
  final SettingsExportType type;
  final String? password;
  final SettingsExportAction action;

  SettingsExport({
    required this.type,
    this.password,
    this.action = SettingsExportAction.share,
  });
}

final class SettingsImport extends SettingsEvent {
  final File file;
  final String? password;

  SettingsImport({required this.file, this.password});
}

enum SettingsExportType { csv, zip }

enum SettingsExportAction { saveToFiles, share }

@Deprecated('Use SettingsImport with file parameter instead')
enum SettingsImportType { csv }

final class SettingsExportAllMindsToCSV extends SettingsEvent {}

final class SettingsUploadMindsFromCacheToServer extends SettingsEvent {}

final class SettingsChangeThemePreference extends SettingsEvent {
  final KeklistThemeMode themePreference;

  const SettingsChangeThemePreference({required this.themePreference});
}

final class SettingsChangeInterfaceStyle extends SettingsEvent {
  final KeklistInterfaceStyle interfaceStyle;

  const SettingsChangeInterfaceStyle({required this.interfaceStyle});
}

final class SettingsGetMindCandidatesToUpload extends SettingsEvent {}

final class SettingsUploadMindCandidates extends SettingsEvent {}

final class SettingsUpdateShouldShowTitlesMode extends SettingsEvent {
  final bool value;

  const SettingsUpdateShouldShowTitlesMode({required this.value});
}

final class SettingsChangeLanguage extends SettingsEvent {
  final SupportedLanguage language;

  const SettingsChangeLanguage({required this.language});
}

final class SettingsEnableDebugMenu extends SettingsEvent {
  const SettingsEnableDebugMenu();
}

final class SettingsToggleWeatherSource extends SettingsEvent {
  final bool isEnabled;
  const SettingsToggleWeatherSource({required this.isEnabled});
}

final class SettingsUpdateWeatherLocation extends SettingsEvent {
  final double latitude;
  final double longitude;
  const SettingsUpdateWeatherLocation({required this.latitude, required this.longitude});
}

final class SettingsUpdateMediaFolderSource extends SettingsEvent {
  final String? folderPath;
  final bool? isRecursive;
  const SettingsUpdateMediaFolderSource({this.folderPath, this.isRecursive});
}

final class SettingsUpdateDayFeed extends SettingsEvent {
  final int? columnCount;
  final int? mindCellSpan;
  final bool? isMindTextVisible;
  const SettingsUpdateDayFeed({
    this.columnCount,
    this.mindCellSpan,
    this.isMindTextVisible,
  });
}

final class SettingsUpdateItemHidden extends SettingsEvent {
  final String id;
  final bool isHidden;
  const SettingsUpdateItemHidden({required this.id, required this.isHidden});
}

final class SettingsUpdateInsights extends SettingsEvent {
  final InsightsSettings insights;
  const SettingsUpdateInsights({required this.insights});
}

final class SettingsUpdateCalendar extends SettingsEvent {
  final CalendarSettings calendar;
  const SettingsUpdateCalendar({required this.calendar});
}

final class SettingsUpdateDayFeedArrangement extends SettingsEvent {
  final FeedSortOrder? sortOrder;
  final FeedGrouping? grouping;
  const SettingsUpdateDayFeedArrangement({this.sortOrder, this.grouping});
}

final class SettingsSetAnalyticsEnabled extends SettingsEvent {
  final bool isEnabled;
  const SettingsSetAnalyticsEnabled({required this.isEnabled});
}

final class SettingsSetMediaHidden extends SettingsEvent {
  final Set<String> ids;
  final bool isHidden;
  const SettingsSetMediaHidden({required this.ids, required this.isHidden});
}

final class SettingsUpdateStory extends SettingsEvent {
  final StorySettings story;
  const SettingsUpdateStory({required this.story});
}

final class SettingsUpdateTileMotion extends SettingsEvent {
  final TileEmojiMotion? emojiMotion;
  final GridResizeAnimation? resizeAnimation;
  const SettingsUpdateTileMotion({this.emojiMotion, this.resizeAnimation});
}

final class SettingsUpdateMindEmotionsPrompt extends SettingsEvent {
  final MindEmotionsPrompt prompt;
  const SettingsUpdateMindEmotionsPrompt({required this.prompt});
}

final class SettingsMarkShakeDiscovered extends SettingsEvent {
  final String screenId;
  const SettingsMarkShakeDiscovered({required this.screenId});
}
