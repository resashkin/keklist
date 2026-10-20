import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';

final class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> with DisposeBag {
  final SettingsRepository _settingsRepository;

  UserProfileBloc({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(
          UserProfileState(
            nickname: '',
            folders: [],
          ),
        ) {
    on<UserProfileGet>(_getUserProfile);
    on<UserProfileUpdateNickName>(_updateNickName);

    _settingsRepository.stream
        .map((settings) => settings.userName)
        .distinct()
        .listen((userName) async => add(UserProfileGet()))
        .disposed(by: this);
  }

  @override
  Future<void> close() {
    cancelSubscriptions();

    return super.close();
  }

  // On-Events

  Future<void> _getUserProfile(UserProfileGet event, Emitter<UserProfileState> emit) async {
    // final List<Mind> folders =
    //     (await _mindRepository.obtainMindsWhere((mind) => mind.dayIndex == KeklistConstants.foldersDayIndex))
    //         .toList(growable: false);
    emit(
      UserProfileState(
        nickname: _settingsRepository.value.userName,
        folders: [],
      ),
    );
  }

  Future<void> _updateNickName(
    UserProfileUpdateNickName event,
    Emitter<UserProfileState> emit,
  ) async {
    await _settingsRepository.updateUserName(event.nickName);
    emit(
      UserProfileState(
        nickname: state.nickname,
        folders: state.folders,
      ),
    );
  }

  // Private functions

  // Future<List<String>> _getSuggestionEmojies() async {
  //   final Iterable<Mind> minds = await _mindRepository.obtainMinds();
  //   final List<String> predictedEmojies = minds
  //       .map((mind) => mind.emoji)
  //       .toList()
  //       .distinct()
  //       .sorted((emoji1, emoji2) => minds
  //           .where((mind) => mind.emoji == emoji2)
  //           .length
  //           .compareTo(minds.where((mind) => mind.emoji == emoji1).length))
  //       .toList(growable: false);
  //   return predictedEmojies;
  // }
}

// Events.

abstract class UserProfileEvent {}

final class UserProfileGet extends UserProfileEvent {
  UserProfileGet();
}

final class UserProfileUpdateNickName extends UserProfileEvent {
  final String nickName;

  UserProfileUpdateNickName({required this.nickName});
}

// State.

final class UserProfileState {
  final String? nickname;
  final List<Mind> folders;

  UserProfileState({
    required this.nickname,
    required this.folders,
  });
}
