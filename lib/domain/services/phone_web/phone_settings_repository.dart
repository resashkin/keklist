import 'dart:async';

import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/language_manager.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';
import 'package:rxdart/rxdart.dart';

/// The browser's own settings (theme, columns, tweaks) with the name and avatar of the phone. Seeding and
/// onboarding count as done, so that the web version never writes starter minds or emotions to the phone.
final class PhoneSettingsRepository implements SettingsRepository {
  PhoneSettingsRepository({required SettingsRepository local, required PhoneApi api}) : _local = local, _api = api {
    _events = _api.events.where((name) => name == 'profile' || name == 'open').listen((_) => _reloadProfile());
    _reloadProfile();
  }

  final SettingsRepository _local;
  final PhoneApi _api;
  late final StreamSubscription<String> _events;
  final BehaviorSubject<({String? name, UserAvatar avatar})> _profile = BehaviorSubject.seeded((
    name: null,
    avatar: const UserAvatar(),
  ));

  @override
  KeklistSettings get value => _merge(_local.value, _profile.value);

  @override
  Stream<KeklistSettings> get stream => Rx.combineLatest2(_local.stream, _profile.stream, _merge);

  static KeklistSettings _merge(KeklistSettings local, ({String? name, UserAvatar avatar}) profile) =>
      local.copyWith(
        userName: profile.name,
        avatar: profile.avatar,
        hasSeededEmotions: true,
        hasSeenLazyOnboarding: true,
      );

  Future<void> _reloadProfile() async {
    final Map<String, dynamic> json = await _api.get('/api/profile') as Map<String, dynamic>;
    _profile.add((
      name: json['name'] as String?,
      avatar: UserAvatar(emoji: json['emoji'] as String?, imagePath: json['imagePath'] as String?),
    ));
  }

  @override
  FutureOr<void> updateUserName(String string) async {
    _profile.add((name: string, avatar: _profile.value.avatar));
    await _api.put('/api/profile', {'name': string});
  }

  /// Only an emoji (or none) can be set from a browser; photos are picked on the phone.
  @override
  FutureOr<void> updateUserAvatar(UserAvatar avatar) async {
    if (avatar.imagePath != null) return;
    _profile.add((name: _profile.value.name, avatar: avatar));
    await _api.put('/api/profile', {'emoji': avatar.emoji});
  }

  @override
  FutureOr<void> updateSettings(KeklistSettings settings) => _local.updateSettings(settings);

  @override
  FutureOr<void> updateThemePreference(KeklistThemeMode themeMode) => _local.updateThemePreference(themeMode);

  @override
  FutureOr<void> updateInterfaceStyle(KeklistInterfaceStyle style) => _local.updateInterfaceStyle(style);

  @override
  FutureOr<void> updateShouldShowTitles(bool shouldShowTitles) => _local.updateShouldShowTitles(shouldShowTitles);

  @override
  FutureOr<void> updateLanguage(SupportedLanguage language) => _local.updateLanguage(language);

  @override
  FutureOr<void> updateWeatherSettings({bool? isEnabled, double? latitude, double? longitude}) =>
      _local.updateWeatherSettings(isEnabled: isEnabled, latitude: latitude, longitude: longitude);

  @override
  FutureOr<void> updateMediaFolderSource({String? folderPath, bool? isRecursive}) =>
      _local.updateMediaFolderSource(folderPath: folderPath, isRecursive: isRecursive);

  @override
  FutureOr<void> updateHasSeededEmotions(bool value) {}

  @override
  FutureOr<void> updateDayFeedSettings({int? columnCount, int? mindCellSpan, bool? isMindTextVisible}) =>
      _local.updateDayFeedSettings(
        columnCount: columnCount,
        mindCellSpan: mindCellSpan,
        isMindTextVisible: isMindTextVisible,
      );

  @override
  FutureOr<void> updateSettingsItemHidden(String id, {required bool isHidden}) =>
      _local.updateSettingsItemHidden(id, isHidden: isHidden);

  @override
  FutureOr<void> markShakeDiscovered(String screenId) => _local.markShakeDiscovered(screenId);

  Future<void> dispose() async {
    await _events.cancel();
    await _profile.close();
  }
}
