import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';

/// The name and avatar shown in the insights header; both stay on this device.
final class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> with DisposeBag {
  final SettingsRepository _settingsRepository;
  final AppFileRepository _fileRepository;

  UserProfileBloc({required SettingsRepository settingsRepository, required AppFileRepository fileRepository})
    : _settingsRepository = settingsRepository,
      _fileRepository = fileRepository,
      super(const UserProfileState(nickname: null, avatarEmoji: null, avatarImage: null)) {
    on<UserProfileGet>(_getUserProfile);
    on<UserProfileUpdateNickName>(_updateNickName);
    on<UserProfileUpdateAvatar>(_updateAvatar);

    _settingsRepository.stream
        .map((settings) => (settings.userName, settings.avatar))
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
    final String? imagePath = settings.avatar.imagePath;
    final File? image = imagePath == null ? null : File(await _fileRepository.resolveAbsolutePath(imagePath));
    emit(
      UserProfileState(
        nickname: settings.userName,
        avatarEmoji: settings.avatar.emoji,
        avatarImage: image != null && image.existsSync() ? image : null,
      ),
    );
  }

  Future<void> _updateNickName(UserProfileUpdateNickName event, Emitter<UserProfileState> emit) async {
    await _settingsRepository.updateUserName(event.nickName.trim());
  }

  Future<void> _updateAvatar(UserProfileUpdateAvatar event, Emitter<UserProfileState> emit) async {
    final File? photo = event.photo;
    final String? imagePath = photo == null ? null : await _fileRepository.saveAvatarImage(photo);
    await _settingsRepository.updateUserAvatar(UserAvatar(emoji: event.emoji, imagePath: imagePath));
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

final class UserProfileState {
  final String? nickname;
  final String? avatarEmoji;
  final File? avatarImage;

  const UserProfileState({required this.nickname, required this.avatarEmoji, required this.avatarImage});
}
