import 'dart:async';

import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';
import 'package:keklist/domain/services/phone_web/phone_collection.dart';

/// The phone's minds, for the web version.
final class MindApiRepository implements MindRepository {
  MindApiRepository({required PhoneApi api})
    : _minds = PhoneCollection<Mind>(
        api: api,
        path: '/api/minds',
        event: 'minds',
        idOf: (mind) => mind.id,
        toJson: (mind) => mind.toJson(),
        fromJson: Mind.fromJson,
      );

  final PhoneCollection<Mind> _minds;

  @override
  Iterable<Mind> get values => _minds.values;

  @override
  Stream<Iterable<Mind>> get stream => _minds.stream;

  @override
  FutureOr<Iterable<Mind>> obtainMinds() => _minds.obtain();

  @override
  FutureOr<Mind?> obtainMind({required String mindId}) async {
    await _minds.obtain();
    return _minds[mindId];
  }

  @override
  FutureOr<Iterable<Mind>> obtainMindsWhere(bool Function(Mind) where) async => (await _minds.obtain()).where(where);

  @override
  FutureOr<Mind> createMind({required Mind mind}) async {
    await _minds.upsert([mind]);
    return mind;
  }

  @override
  FutureOr<void> createMinds({required Iterable<Mind> minds}) => _minds.upsert(minds);

  @override
  FutureOr<void> updateMind({required Mind mind}) => _minds.upsert([mind]);

  @override
  FutureOr<void> updateMinds({required Iterable<Mind> minds}) => _minds.upsert(minds);

  @override
  FutureOr<void> deleteMind({required String mindId}) => _minds.delete([mindId]);

  @override
  FutureOr<void> deleteMinds() => _minds.delete(_minds.values.map((mind) => mind.id));

  @override
  FutureOr<void> deleteMindsWhere(bool Function(Mind) where) =>
      _minds.delete(_minds.values.where(where).map((mind) => mind.id));
}
