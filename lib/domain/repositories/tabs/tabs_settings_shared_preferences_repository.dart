import 'dart:async';

import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/domain/repositories/tabs/tabs_settings_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final class TabsSettingsSharedPreferencesRepository extends TabsSettingsRepository {
  final StreamingSharedPreferences _preferences;
  final Preference<TabsSettings?> _tabsSettingsPreferences;
  final BehaviorSubject<TabsSettings> _behaviorSubject = BehaviorSubject<TabsSettings>();

  @override
  Stream<TabsSettings> get stream => _behaviorSubject;

  @override
  TabsSettings get value => _behaviorSubject.valueOrNull ?? _tabsSettingsPreferences.getValue()!;

  TabsSettingsSharedPreferencesRepository({required StreamingSharedPreferences preferences})
      : _preferences = preferences,
        _tabsSettingsPreferences = preferences.getCustomValue<TabsSettings?>(
          'tabs_settings',
          defaultValue: KeklistConstants.defaultTabSettings,
          adapter: JsonAdapter<TabsSettings>(
            deserializer: (jsonObject) => TabsSettings.fromJson(_withoutRemovedTabs(jsonObject as Map<String, dynamic>)),
          ),
        ) {
    _behaviorSubject.addStream(
      _tabsSettingsPreferences.asBroadcastStream().whereNotNull().debounceTime(const Duration(milliseconds: 10)),
    );
    _addAiTabOnce();
  }

  static const String _aiTabAddedKey = 'tabs_ai_added_v1';

  /// The AI tab arrived after people chose their tabs, so it is put before Settings once; removing it sticks.
  void _addAiTabOnce() {
    if (_preferences.getBool(_aiTabAddedKey, defaultValue: false).getValue()) return;
    _preferences.setBool(_aiTabAddedKey, true);
    final TabsSettings? settings = _tabsSettingsPreferences.getValue();
    if (settings == null || settings.selectedTabModels.any((tab) => tab.type == TabType.ai)) return;
    final List<TabModel> tabs = [...settings.selectedTabModels];
    final int settingsIndex = tabs.indexWhere((tab) => tab.type == TabType.settings);
    final int aiIndex = settingsIndex < 0 ? tabs.length : settingsIndex;
    tabs.insert(aiIndex, TabModel(type: TabType.ai));
    final int defaultIndex = settings.defaultSelectedTabIndex;
    _updateSettings(
      TabsSettings(selectedTabModels: tabs, defaultSelectedTabIndex: defaultIndex >= aiIndex ? defaultIndex + 1 : defaultIndex),
    );
  }

  /// Tabs dropped from [TabType] (like the old Profile) would fail to decode, so they are skipped.
  static Map<String, dynamic> _withoutRemovedTabs(Map<String, dynamic> json) {
    final Set<String> knownTypes = TabType.values.map((type) => type.name).toSet();
    final List<dynamic> tabs = (json['selectedTabModels'] as List<dynamic>? ?? [])
        .where((tab) => tab is Map && knownTypes.contains(tab['type']))
        .toList();
    final int defaultIndex = (json['defaultSelectedTabIndex'] as int? ?? 0).clamp(0, tabs.isEmpty ? 0 : tabs.length - 1);
    return {...json, 'selectedTabModels': tabs, 'defaultSelectedTabIndex': defaultIndex};
  }

  @override
  FutureOr<void> updateDefaultSelectedTabIndex({required int defaultSelectedTabIndex}) => _updateSettings(
        TabsSettings(
          selectedTabModels: _tabsSettingsPreferences.getValue()?.selectedTabModels ?? [],
          defaultSelectedTabIndex: defaultSelectedTabIndex,
        ),
      );

  @override
  FutureOr<void> update({required List<TabModel> tabModels}) => _updateSettings(
        TabsSettings(
          selectedTabModels: tabModels,
          defaultSelectedTabIndex: _tabsSettingsPreferences.getValue()?.defaultSelectedTabIndex ?? 0,
        ),
      );

  FutureOr<void> _updateSettings(TabsSettings settings) async => _preferences.setCustomValue(
        'tabs_settings',
        settings,
        adapter: JsonAdapter<TabsSettings>(),
      );
}
