import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';

/// The name and avatar shown in the insights header; both stay on this device.
final class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> with DisposeBag {
  static const int maxHistoryLength = 12;

  final SettingsRepository _settingsRepository;
  final AppFileRepository _fileRepository;

  UserProfileBloc({required SettingsRepository settingsRepository, required AppFileRepository fileRepository})
    : _settingsRepository = settingsRepository,
      _fileRepository = fileRepository,
      super(const UserProfileState(nickname: null, avatarEmoji: null, avatarImagePath: null, history: [])) {
    on<UserProfileGet>(_getUserProfile);
    on<UserProfileUpdateNickName>(_updateNickName);
    on<UserProfileUpdateAvatar>(_updateAvatar);
    on<UserProfileSelectAvatar>(_selectAvatar);
    on<UserProfileRemoveAvatar>(_removeAvatar);

    _settingsRepository.stream
        .map((settings) => (settings.userName, settings.avatar, settings.avatarHistory.join()))
        .distinct()
        .listen((_) => add(UserProfileGet()))
        .disposed(by: this);
  }

  @override
  Future<void> close() {
    cancelSubscriptions();
    return super.close();
  }

  Future<void> _getUserProfile(UserProfileGet event, Emitter<UserProfileState> emit) async {
    final KeklistSettings settings = _settingsRepository.value;
    final List<UserAvatarChoice> history = [];
    for (final UserAvatar avatar in _historyOf(settings)) {
      final String? image = await _resolvedImageOf(avatar);
      // A photo whose file is gone has nothing left to show.
      if (avatar.imagePath != null && image == null) continue;
      history.add((avatar: avatar, imagePath: image));
    }
    emit(
      UserProfileState(
        nickname: settings.userName,
        avatarEmoji: settings.avatar.emoji,
        avatarImagePath: await _resolvedImageOf(settings.avatar),
        current: settings.avatar,
        history: history,
      ),
    );
  }

  Future<String?> _resolvedImageOf(UserAvatar avatar) async {
    final String? imagePath = avatar.imagePath;
    final String? image = imagePath == null ? null : await _fileRepository.resolveAbsolutePath(imagePath);
    return image != null && (isRemoteMediaPath(image) || File(image).existsSync()) ? image : null;
  }

  /// Avatars set before the history existed still show up in it.
  List<UserAvatar> _historyOf(KeklistSettings settings) => settings.avatarHistory.isEmpty && !settings.avatar.isEmpty
      ? [settings.avatar]
      : settings.avatarHistory;

  Future<void> _updateNickName(UserProfileUpdateNickName event, Emitter<UserProfileState> emit) async {
    await _settingsRepository.updateUserName(event.nickName.trim());
  }

  Future<void> _updateAvatar(UserProfileUpdateAvatar event, Emitter<UserProfileState> emit) async {
    final File? photo = event.photo;
    final String? imagePath = photo == null ? null : await _fileRepository.saveAvatarImage(photo);
    await _setAvatar(UserAvatar(emoji: event.emoji, imagePath: imagePath));
  }

  Future<void> _selectAvatar(UserProfileSelectAvatar event, Emitter<UserProfileState> emit) =>
      _setAvatar(event.avatar);

  Future<void> _removeAvatar(UserProfileRemoveAvatar event, Emitter<UserProfileState> emit) async {
    final KeklistSettings settings = _settingsRepository.value;
    await _saveHistory(_historyOf(settings).where((avatar) => avatar != event.avatar).toList());
    if (settings.avatar == event.avatar) await _settingsRepository.updateUserAvatar(const UserAvatar());
    await _deleteFileOf(event.avatar);
  }

  /// The new avatar goes first in the history; the ones pushed past [maxHistoryLength] lose their files.
  Future<void> _setAvatar(UserAvatar avatar) async {
    final KeklistSettings settings = _settingsRepository.value;
    final List<UserAvatar> history = [
      if (!avatar.isEmpty) avatar,
      ..._historyOf(settings).where((entry) => entry != avatar),
    ];
    await _saveHistory(history.take(maxHistoryLength).toList());
    await _settingsRepository.updateUserAvatar(avatar);
    for (final UserAvatar dropped in history.skip(maxHistoryLength)) {
      await _deleteFileOf(dropped);
    }
  }

  Future<void> _saveHistory(List<UserAvatar> history) async => _settingsRepository.updateAvatarHistory(history);

  Future<void> _deleteFileOf(UserAvatar avatar) async {
    final String? imagePath = avatar.imagePath;
    if (imagePath != null) await _fileRepository.deleteAvatarImage(imagePath);
  }
}

abstract class UserProfileEvent {}

final class UserProfileGet extends UserProfileEvent {}

final class UserProfileUpdateNickName extends UserProfileEvent {
  final String nickName;

  UserProfileUpdateNickName({required this.nickName});
}

/// A photo, an emoji, or neither to fall back to the name's initial.
final class UserProfileUpdateAvatar extends UserProfileEvent {
  final String? emoji;
  final File? photo;

  UserProfileUpdateAvatar({this.emoji, this.photo});
}

/// Makes an avatar from the history the current one again.
final class UserProfileSelectAvatar extends UserProfileEvent {
  final UserAvatar avatar;

  UserProfileSelectAvatar(this.avatar);
}

final class UserProfileRemoveAvatar extends UserProfileEvent {
  final UserAvatar avatar;

  UserProfileRemoveAvatar(this.avatar);
}

/// A history entry with its image resolved for display.
typedef UserAvatarChoice = ({UserAvatar avatar, String? imagePath});

final class UserProfileState {
  final String? nickname;
  final String? avatarEmoji;
  /// A local file, or a URL in the web version.
  final String? avatarImagePath;
  final UserAvatar current;
  final List<UserAvatarChoice> history;

  const UserProfileState({
    required this.nickname,
    required this.avatarEmoji,
    required this.avatarImagePath,
    required this.history,
    this.current = const UserAvatar(),
  });
}
