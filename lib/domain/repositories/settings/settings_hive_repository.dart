import 'dart:async';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/object/settings_object.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/language_manager.dart';
import 'package:rxdart/rxdart.dart';

final class SettingsHiveRepository implements SettingsRepository {
  final Box<SettingsObject> _hiveBox;
  final BehaviorSubject<KeklistSettings> _behaviorSubject = BehaviorSubject<KeklistSettings>();
  SettingsObject? get _settingsObject => _hiveBox.values.firstOrNull;

  SettingsHiveRepository({required Box<SettingsObject> box}) : _hiveBox = box {
    if (_settingsObject != null) {
      _behaviorSubject.add(_settingsObject!.toSettings());
    } else {
      updateSettings(KeklistSettings.initial());
    }
    _behaviorSubject.addStream(
      _hiveBox
          .watch()
          .whereNotNull()
          .map((_) => _settingsObject!.toSettings())
          .debounceTime(const Duration(milliseconds: 10)),
    );
  }

  @override
  KeklistSettings get value => _behaviorSubject.value;

  @override
  Stream<KeklistSettings> get stream => _behaviorSubject;

  @override
  FutureOr<void> updateThemePreference(KeklistThemeMode themeMode) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    settingsObject.themePreferenceIndex = themeMode.index;
    settingsObject.isDarkMode = themeMode == KeklistThemeMode.dark;
    await settingsObject.save();
  }

  @override
  FutureOr<void> updateInterfaceStyle(KeklistInterfaceStyle style) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    settingsObject.interfaceStyleIndex = style.index;
    await settingsObject.save();
  }

  @override
  FutureOr<void> updateLanguage(SupportedLanguage language) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    settingsObject?.language = language.code;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateHasSeededEmotions(bool value) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    settingsObject?.hasSeededEmotions = value;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateSettings(KeklistSettings settings) async {
    await _hiveBox.put(HiveConstants.globalSettingsIndex, settings.toObject());
  }

  @override
  FutureOr<void> updateShouldShowTitles(bool shouldShowTitles) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    settingsObject?.shouldShowTitles = shouldShowTitles;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateUserName(String userName) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    settingsObject?.userName = userName;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateUserAvatar(UserAvatar avatar) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    settingsObject.avatarEmoji = avatar.emoji;
    settingsObject.avatarImagePath = avatar.imagePath;
    await settingsObject.save();
  }

  @override
  FutureOr<void> updateWeatherSettings({bool? isEnabled, double? latitude, double? longitude}) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    if (isEnabled != null) settingsObject.isWeatherSourceEnabled = isEnabled;
    if (latitude != null) settingsObject.weatherLatitude = latitude;
    if (longitude != null) settingsObject.weatherLongitude = longitude;
    await settingsObject.save();
  }

  @override
  FutureOr<void> updateMediaFolderSource({String? folderPath, bool? isRecursive}) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    if (folderPath != null) settingsObject.mediaFolderPath = folderPath;
    if (isRecursive != null) settingsObject.isMediaFolderRecursive = isRecursive;
    await settingsObject.save();
  }

  @override
  FutureOr<void> updateDayFeedSettings({
    int? columnCount,
    int? mindCellSpan,
    bool? isMindTextVisible,
  }) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    if (columnCount != null) settingsObject.dayFeedColumnCount = columnCount;
    if (mindCellSpan != null) settingsObject.dayFeedMindCellSpan = mindCellSpan;
    if (isMindTextVisible != null) settingsObject.isDayFeedMindTextVisible = isMindTextVisible;
    await settingsObject.save();
  }

  @override
  FutureOr<void> updateSettingsItemHidden(String id, {required bool isHidden}) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null) return;
    final Set<String> hiddenIds = settingsObject.hiddenSettingsItemIds.toSet();
    final bool isChanged = isHidden ? hiddenIds.add(id) : hiddenIds.remove(id);
    if (!isChanged) return;
    settingsObject.hiddenSettingsItemIds = hiddenIds.toList();
    await settingsObject.save();
  }

  @override
  FutureOr<void> markShakeDiscovered(String screenId) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.globalSettingsIndex);
    if (settingsObject == null || settingsObject.shakeDiscoveredScreenIds.contains(screenId)) return;
    settingsObject.shakeDiscoveredScreenIds = [...settingsObject.shakeDiscoveredScreenIds, screenId];
    await settingsObject.save();
  }
}
