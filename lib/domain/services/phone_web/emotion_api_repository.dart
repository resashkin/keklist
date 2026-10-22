import 'dart:async';

import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';
import 'package:keklist/domain/services/phone_web/phone_collection.dart';

/// The phone's emotions, for the web version.
final class EmotionApiRepository implements EmotionRepository {
  EmotionApiRepository({required PhoneApi api})
    : _emotions = PhoneCollection<Emotion>(
        api: api,
        path: '/api/emotions',
        event: 'emotions',
        idOf: (emotion) => emotion.id,
        toJson: (emotion) => emotion.toJson(),
        fromJson: Emotion.fromJson,
      );

  final PhoneCollection<Emotion> _emotions;

  @override
  Iterable<Emotion> get values => _emotions.values;

  @override
  Stream<Iterable<Emotion>> get stream => _emotions.stream;

  @override
  FutureOr<Iterable<Emotion>> obtainEmotions() => _emotions.obtain();

  @override
  FutureOr<Emotion?> obtainEmotion({required String id}) async {
    await _emotions.obtain();
    return _emotions[id];
  }

  @override
  FutureOr<void> createEmotion({required Emotion emotion}) => _emotions.upsert([emotion]);

  @override
  FutureOr<void> createEmotions({required Iterable<Emotion> emotions}) => _emotions.upsert(emotions);

  @override
  FutureOr<void> updateEmotion({required Emotion emotion}) => _emotions.upsert([emotion]);

  @override
  FutureOr<void> updateEmotions({required Iterable<Emotion> emotions}) => _emotions.upsert(emotions);

  @override
  FutureOr<void> deleteEmotion({required String id}) => _emotions.delete([id]);

  @override
  FutureOr<void> deleteEmotions() => _emotions.delete(_emotions.values.map((emotion) => emotion.id));
}
