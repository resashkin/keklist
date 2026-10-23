import 'package:flutter/foundation.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';

/// A reply that is still being written.
final class AiStreamingReply {
  const AiStreamingReply({required this.sessionId, required this.text});

  final String sessionId;
  final String text;

  Map<String, dynamic> toJson() => {'sessionId': sessionId, 'text': text};

  static AiStreamingReply? fromJson(Object? json) => switch (json) {
    {'sessionId': final String sessionId, 'text': final String text} => AiStreamingReply(
      sessionId: sessionId,
      text: text,
    ),
    _ => null,
  };
}

/// What the AI tab works with. On the phone it runs the model itself; the web version asks the phone.
abstract class AiBackend extends ChangeNotifier {
  /// Models and own roles are managed on the phone only.
  bool get canManage;

  /// The model replies come from, or null while there is none.
  String? get modelName;

  List<AiSession> get sessions;
  List<AiPersona> get personas;
  Map<int, AiDaySummary> get summaries;

  /// Days with records, newest first, that can get a summary.
  List<int> get summaryDays;

  /// Days whose records changed after their summary was written.
  Set<int> get staleSummaryDays;

  Set<int> get summarizingDays;
  AiStreamingReply? get streaming;
  String? get lastError;

  AiSession? session(String id) => sessions.where((session) => session.id == id).firstOrNull;

  AiPersona personaOf(AiSession session) =>
      personas.where((persona) => persona.id == session.personaId).firstOrNull ?? personas.first;

  /// The language replies are written in and the names of the built-in roles, from the app's locale.
  void configure({required String language, required Map<String, String> builtInNames}) {}

  Future<String> createSession(String personaId);
  Future<void> deleteSession(String id);
  Future<void> send(String sessionId, String text);
  void stop();
  Future<void> summarizeDay(int dayIndex);

  /// Lets summaries be written in the background while the tab is open and the phone charges.
  void setAutoSummaries(bool enabled) {}

  Future<void> savePersona(AiPersona persona);
  Future<void> deletePersona(String id);

  /// Everything the web version shows, in one object.
  Map<String, dynamic> stateJson() => {
    'modelName': modelName,
    'sessions': [for (final AiSession session in sessions) session.toJson()],
    'personas': [for (final AiPersona persona in personas) persona.toJson()],
    'summaries': [for (final AiDaySummary summary in summaries.values) summary.toJson()],
    'summaryDays': summaryDays,
    'staleSummaryDays': staleSummaryDays.toList(),
    'summarizingDays': summarizingDays.toList(),
    'streaming': streaming?.toJson(),
    'lastError': lastError,
  };
}
