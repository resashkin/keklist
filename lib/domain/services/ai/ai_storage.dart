import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:rxdart/rxdart.dart';

/// Sessions, own roles, day summaries and the downloaded models, as JSON in encrypted Hive boxes.
/// None of it goes into the ZIP export.
final class AiStorage {
  AiStorage({
    required Box<String> sessions,
    required Box<String> personas,
    required Box<String> summaries,
    required Box<String> models,
  }) : _sessions = sessions,
       _personas = personas,
       _summaries = summaries,
       _models = models;

  static const String sessionsBoxName = 'ai_sessions_box';
  static const String personasBoxName = 'ai_personas_box';
  static const String summariesBoxName = 'ai_day_summaries_box';
  static const String modelsBoxName = 'ai_models_box';

  static const String _activeModelKey = '_active';
  static const String _catalogKey = '_gallery_catalog';
  static const String _installedPrefix = 'installed:';

  final Box<String> _sessions;
  final Box<String> _personas;
  final Box<String> _summaries;
  final Box<String> _models;

  static Future<AiStorage> open(HiveCipher cipher) async => AiStorage(
    sessions: await Hive.openBox<String>(sessionsBoxName, encryptionCipher: cipher),
    personas: await Hive.openBox<String>(personasBoxName, encryptionCipher: cipher),
    summaries: await Hive.openBox<String>(summariesBoxName, encryptionCipher: cipher),
    models: await Hive.openBox<String>(modelsBoxName, encryptionCipher: cipher),
  );

  Stream<void> get changes => MergeStream([_sessions.watch(), _personas.watch(), _summaries.watch()]);

  List<AiSession> get sessions =>
      _sessions.values.map((value) => AiSession.fromJson(jsonDecode(value) as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  AiSession? session(String id) => switch (_sessions.get(id)) {
    final String value => AiSession.fromJson(jsonDecode(value) as Map<String, dynamic>),
    null => null,
  };

  Future<void> putSession(AiSession session) => _sessions.put(session.id, jsonEncode(session.toJson()));

  Future<void> deleteSession(String id) => _sessions.delete(id);

  List<AiPersona> get customPersonas =>
      _personas.values.map((value) => AiPersona.fromJson(jsonDecode(value) as Map<String, dynamic>)).toList();

  Future<void> putPersona(AiPersona persona) => _personas.put(persona.id, jsonEncode(persona.toJson()));

  Future<void> deletePersona(String id) => _personas.delete(id);

  Map<int, AiDaySummary> get summaries => {
    for (final String value in _summaries.values)
      if (AiDaySummary.fromJson(jsonDecode(value) as Map<String, dynamic>) case final AiDaySummary summary)
        summary.dayIndex: summary,
  };

  Future<void> putSummary(AiDaySummary summary) => _summaries.put('${summary.dayIndex}', jsonEncode(summary.toJson()));

  Future<void> clearSummaries() => _summaries.clear();

  List<AiModelInfo> get installedModels => [
    for (final MapEntry<dynamic, String> entry in _models.toMap().entries)
      if ((entry.key as String).startsWith(_installedPrefix))
        AiModelInfo.fromJson(jsonDecode(entry.value) as Map<String, dynamic>),
  ];

  Future<void> putInstalled(AiModelInfo model) =>
      _models.put('$_installedPrefix${model.id}', jsonEncode(model.toJson()));

  Future<void> deleteInstalled(String id) => _models.delete('$_installedPrefix$id');

  String? get activeModelId => _models.get(_activeModelKey);

  Future<void> setActiveModelId(String? id) =>
      id == null ? _models.delete(_activeModelKey) : _models.put(_activeModelKey, id);

  List<AiModelInfo>? get cachedGallery => switch (_models.get(_catalogKey)) {
    final String value => [
      for (final Object? item in jsonDecode(value) as List<dynamic>) AiModelInfo.fromJson(item as Map<String, dynamic>),
    ],
    null => null,
  };

  Future<void> putCachedGallery(List<AiModelInfo> models) =>
      _models.put(_catalogKey, jsonEncode([for (final AiModelInfo model in models) model.toJson()]));
}
