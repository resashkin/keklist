import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/constants/onboarding_constants.dart';
import 'package:keklist/domain/services/emotions/emotion_seeder.dart';
import 'package:keklist/domain/services/emotions/legacy_emoji_linker.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart' as kek_date_utils;
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:uuid/uuid.dart';

part 'lazy_onboarding_event.dart';
part 'lazy_onboarding_state.dart';

final class LazyOnboardingBloc extends Bloc<LazyOnboardingEvent, LazyOnboardingState> {
  final MindRepository _mindRepository;
  final SettingsRepository _settingsRepository;
  final EmotionRepository _emotionRepository;

  LazyOnboardingBloc({
    required MindRepository mindRepository,
    required SettingsRepository settingsRepository,
    required EmotionRepository emotionRepository,
  }) : _mindRepository = mindRepository,
       _settingsRepository = settingsRepository,
       _emotionRepository = emotionRepository,
      super(LazyOnboardingInitial()) {
    on<LazyOnboardingCheck>(_onCheck);
    on<LazyOnboardingCreate>(_onCreate);
    on<LazyOnboardingDelete>(_onDelete);
    on<LazyOnboardingMarkAsSeen>(_onMarkAsSeen);
    on<LazyOnboardingReset>(_onReset);
  }

  Future<void> _onCheck(LazyOnboardingCheck event, Emitter<LazyOnboardingState> emit) async {
    // If user has already seen onboarding, don't show it again
    if (_settingsRepository.value.hasSeenLazyOnboarding) {
      emit(LazyOnboardingNeeded(shouldShow: false));
      return;
    }

    // Get all minds
    final minds = await _mindRepository.obtainMinds();

    // Guard against stale hasSeenLazyOnboarding=false after encryption migration:
    // if onboarding minds already exist the user already ran onboarding.
    if (minds.any((m) => OnboardingConstants.isOnboardingMindId(m.id))) {
      emit(LazyOnboardingNeeded(shouldShow: false));
      return;
    }

    // Check conditions: totalMinds < 10 OR no minds in last 30 days
    final totalMinds = minds.length;
    final last30DaysMinds = MindUtils.findLast30DaysMinds(allMinds: minds.toList());
    final shouldShow = totalMinds < 10 || last30DaysMinds.isEmpty;

    emit(LazyOnboardingNeeded(shouldShow: shouldShow));
  }

  Future<void> _onCreate(LazyOnboardingCreate event, Emitter<LazyOnboardingState> emit) async {
    final todayDayIndex = kek_date_utils.DateUtils.getTodayIndex();
    final uuid = const Uuid();
    final l10n = event.context.l10n;

    final List<Mind> mindsToCreate = [];
    await EmotionSeeder.seedIfNeeded(emotionRepository: _emotionRepository, settingsRepository: _settingsRepository);
    final Map<String, String> emotionIdByEmoji = {
      for (final Emotion emotion in _emotionRepository.values.where((e) => !e.isArchived && e.parentId == null))
        LegacyEmojiLinker.normalize(emotion.emoji): emotion.id,
    };

    // Create parent minds with ONBOARDING_ prefix in ID
    for (final parentData in OnboardingConstants.parentMinds) {
      final parentId = '${OnboardingConstants.onboardingIdPrefix}${uuid.v4()}';
      final parentMind = Mind(
        id: parentId,
        note: parentData.translation(l10n),
        dayIndex: todayDayIndex,
        creationDate: DateTime.now(),
        sortIndex: parentData.sortIndex,
        rootId: null, // Parent minds have no rootId - they ARE the root
        emotionIds: [?emotionIdByEmoji[LegacyEmojiLinker.normalize(parentData.emotionEmoji ?? '')]],
      );
      mindsToCreate.add(parentMind);

      // Create comment minds for this parent if they exist
      final commentTranslations = OnboardingConstants.commentMinds[parentData.sortIndex];
      if (commentTranslations != null) {
        for (int i = 0; i < commentTranslations.length; i++) {
          final commentMind = Mind(
            id: uuid.v4(),
            note: commentTranslations[i](l10n),
            dayIndex: todayDayIndex,
            creationDate: DateTime.now(),
            sortIndex: i,
            rootId: parentId, // Use parent's ID as rootId
          );
          mindsToCreate.add(commentMind);
        }
      }
    }

    // Create all minds in bulk
    await _mindRepository.createMinds(minds: mindsToCreate);

    emit(LazyOnboardingCreated());
  }

  Future<void> _onDelete(LazyOnboardingDelete event, Emitter<LazyOnboardingState> emit) async {
    // Delete all parent onboarding minds (those with ONBOARDING_ prefix)
    await _mindRepository.deleteMindsWhere((mind) => OnboardingConstants.isOnboardingMindId(mind.id));

    // Delete all comment minds (children of onboarding parent minds)
    final allMinds = await _mindRepository.obtainMinds();
    final onboardingParentIds = allMinds
        .where((mind) => OnboardingConstants.isOnboardingMindId(mind.id))
        .map((mind) => mind.id)
        .toSet();

    await _mindRepository.deleteMindsWhere((mind) => mind.rootId != null && onboardingParentIds.contains(mind.rootId));

    emit(LazyOnboardingDeleted());
  }

  Future<void> _onMarkAsSeen(LazyOnboardingMarkAsSeen event, Emitter<LazyOnboardingState> emit) async {
    final currentSettings = _settingsRepository.value;
    final updatedSettings = currentSettings.copyWith(hasSeenLazyOnboarding: true);

    await _settingsRepository.updateSettings(updatedSettings);
  }

  Future<void> _onReset(LazyOnboardingReset event, Emitter<LazyOnboardingState> emit) async {
    // Delete all existing onboarding minds first
    await _mindRepository.deleteMindsWhere((mind) => OnboardingConstants.isOnboardingMindId(mind.id));

    final allMinds = await _mindRepository.obtainMinds();
    final onboardingParentIds = allMinds
        .where((mind) => OnboardingConstants.isOnboardingMindId(mind.id))
        .map((mind) => mind.id)
        .toSet();

    await _mindRepository.deleteMindsWhere((mind) => mind.rootId != null && onboardingParentIds.contains(mind.rootId));

    // Reset the flag in settings
    final currentSettings = _settingsRepository.value;
    final updatedSettings = currentSettings.copyWith(hasSeenLazyOnboarding: false);

    await _settingsRepository.updateSettings(updatedSettings);

    emit(LazyOnboardingResetComplete());
  }
}
