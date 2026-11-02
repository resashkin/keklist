import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/language_manager.dart';
import 'package:keklist/presentation/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockAppFileRepository extends Mock implements AppFileRepository {}

KeklistSettings _settings({UserAvatar avatar = const UserAvatar(), List<UserAvatar> history = const []}) =>
    KeklistSettings(
      themePreference: KeklistThemeMode.dark,
      interfaceStyle: KeklistInterfaceStyle.liquidGlass,
      shouldShowTitles: true,
      userName: null,
      language: SupportedLanguage.english,
      dataSchemaVersion: 4,
      hasSeenLazyOnboarding: true,
      isDebugMenuVisible: false,
      isWeatherSourceEnabled: false,
      weatherLatitude: null,
      weatherLongitude: null,
      mediaFolderPath: null,
      isMediaFolderRecursive: false,
      hasSeededEmotions: true,
      avatar: avatar,
      avatarHistory: history,
    );

void main() {
  late MockSettingsRepository settingsRepository;
  late MockAppFileRepository fileRepository;
  late KeklistSettings settings;
  late UserProfileBloc bloc;

  setUpAll(() {
    registerFallbackValue(const UserAvatar());
    registerFallbackValue(File('x'));
  });

  void start({UserAvatar avatar = const UserAvatar(), List<UserAvatar> history = const []}) {
    settings = _settings(avatar: avatar, history: history);
    settingsRepository = MockSettingsRepository();
    fileRepository = MockAppFileRepository();
    when(() => settingsRepository.stream).thenAnswer((_) => const Stream.empty());
    when(() => settingsRepository.value).thenAnswer((_) => settings);
    when(() => settingsRepository.updateUserAvatar(any())).thenAnswer((invocation) async {
      settings = settings.copyWith(avatar: invocation.positionalArguments.first as UserAvatar);
    });
    when(() => settingsRepository.updateAvatarHistory(any())).thenAnswer((invocation) async {
      settings = settings.copyWith(avatarHistory: invocation.positionalArguments.first as List<UserAvatar>);
    });
    when(() => fileRepository.saveAvatarImage(any())).thenAnswer((_) async => 'avatar/new.jpg');
    when(() => fileRepository.deleteAvatarImage(any())).thenAnswer((_) async {});
    bloc = UserProfileBloc(settingsRepository: settingsRepository, fileRepository: fileRepository);
  }

  tearDown(() => bloc.close());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a new avatar goes first in the history', () async {
    start(avatar: const UserAvatar(emoji: '🐱'));
    bloc.add(UserProfileUpdateAvatar(emoji: '🐶'));
    await settle();

    expect(settings.avatar, const UserAvatar(emoji: '🐶'));
    expect(settings.avatarHistory, const [UserAvatar(emoji: '🐶'), UserAvatar(emoji: '🐱')]);
  });

  test('picking an avatar from the history moves it to the front without a duplicate', () async {
    start(
      avatar: const UserAvatar(emoji: '🐶'),
      history: const [
        UserAvatar(emoji: '🐶'),
        UserAvatar(emoji: '🐱'),
      ],
    );
    bloc.add(UserProfileSelectAvatar(const UserAvatar(emoji: '🐱')));
    await settle();

    expect(settings.avatar, const UserAvatar(emoji: '🐱'));
    expect(settings.avatarHistory, const [UserAvatar(emoji: '🐱'), UserAvatar(emoji: '🐶')]);
  });

  test('the history keeps 12 avatars and deletes the file of the one pushed out', () async {
    final List<UserAvatar> full = [
      for (int i = 0; i < 11; i++) UserAvatar(emoji: '$i'),
      const UserAvatar(imagePath: 'avatar/old.jpg'),
    ];
    start(avatar: full.first, history: full);
    bloc.add(UserProfileUpdateAvatar(emoji: '🆕'));
    await settle();

    expect(settings.avatarHistory.length, UserProfileBloc.maxHistoryLength);
    expect(settings.avatarHistory.first, const UserAvatar(emoji: '🆕'));
    verify(() => fileRepository.deleteAvatarImage('avatar/old.jpg')).called(1);
  });

  test('removing the current avatar falls back to the letter and deletes its file', () async {
    const UserAvatar photo = UserAvatar(imagePath: 'avatar/me.jpg');
    start(
      avatar: photo,
      history: const [
        photo,
        UserAvatar(emoji: '🐱'),
      ],
    );
    bloc.add(UserProfileRemoveAvatar(photo));
    await settle();

    expect(settings.avatar.isEmpty, isTrue);
    expect(settings.avatarHistory, const [UserAvatar(emoji: '🐱')]);
    verify(() => fileRepository.deleteAvatarImage('avatar/me.jpg')).called(1);
  });

  test('the letter avatar does not enter the history', () async {
    start(avatar: const UserAvatar(emoji: '🐱'));
    bloc.add(UserProfileUpdateAvatar());
    await settle();

    expect(settings.avatar.isEmpty, isTrue);
    expect(settings.avatarHistory, const [UserAvatar(emoji: '🐱')]);
  });
}
