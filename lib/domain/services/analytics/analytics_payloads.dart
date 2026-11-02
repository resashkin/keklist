import 'package:keklist/domain/repositories/settings/settings_repository.dart';

/// Every tweak the user can change, as plain values: enum names, bools and numbers only.
/// Nothing about minds, emotions, photos or places: no ids, paths, coordinates or names.
Map<String, Object> analyticsTweaksOf(KeklistSettings settings) => {
  'theme': settings.themePreference.name,
  'interface_style': settings.interfaceStyle.name,
  'show_titles': settings.shouldShowTitles,
  'language': settings.language.code,
  'weather_enabled': settings.isWeatherSourceEnabled,
  'media_folder_enabled': settings.mediaFolderPath != null,
  'media_folder_recursive': settings.isMediaFolderRecursive,
  'day_columns': settings.dayFeed.columnCount,
  'day_mind_span': settings.dayFeed.mindCellSpan,
  'day_mind_text_visible': settings.dayFeed.isMindTextVisible,
  'day_sort': settings.dayFeed.sortOrder.name,
  'day_grouping': settings.dayFeed.grouping.name,
  'insights_period': settings.insights.periodIndex,
  'insights_hidden_widgets': (settings.insights.hiddenWidgetIds.toList()..sort()).join(','),
  'calendar_columns': settings.calendar.columnCount,
  'calendar_mind_text_visible': settings.calendar.isMindTextVisible,
  'calendar_media_visible': settings.calendar.isMediaVisible,
  'calendar_sort': settings.calendar.sortOrder.name,
  'calendar_grouping': settings.calendar.grouping.name,
  'story_texture': settings.story.textureAnimation.name,
  'story_date_layout': settings.story.dateLayout.name,
  'story_spectrum_visible': settings.story.isSpectrumVisible,
  'story_sensitivity': settings.story.sensitivity,
  'mind_emotions_prompt': settings.mindEmotionsPrompt.name,
  'tile_emoji_motion': settings.tileEmojiMotion.name,
  'grid_resize_animation': settings.gridResizeAnimation.name,
  'hidden_settings_rows': (settings.hiddenSettingsItemIds.toList()..sort()).join(','),
};

/// The tweaks whose value differs between two snapshots, with their new values.
Map<String, Object> changedTweaks(Map<String, Object> previous, Map<String, Object> current) => {
  for (final MapEntry<String, Object> entry in current.entries)
    if (previous[entry.key] != entry.value) entry.key: entry.value,
};

/// Drops exception messages, which can quote user text or file paths; the type and stack frames stay.
Map<String, Object> withoutExceptionMessages(Map<String, Object> properties) {
  final Object? exceptions = properties[r'$exception_list'];
  if (exceptions is! List) return properties;
  return {
    ...properties,
    r'$exception_list': [
      for (final Object? exception in exceptions)
        if (exception is Map) {...exception}..remove('value') else exception,
    ],
  }..remove(r'$exception_message');
}
