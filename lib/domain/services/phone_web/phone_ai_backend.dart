import 'dart:async';
import 'dart:convert';

import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';

/// The AI tab of the web version: the phone runs the model and streams replies back over the local network.
final class PhoneAiBackend extends AiBackend {
  PhoneAiBackend({required PhoneApi api}) : _api = api {
    _subscriptions.addAll([
      _api.events.where((name) => name == 'ai' || name == 'open').listen((_) => _reload()),
      _api.eventData('ai-reply').listen(_onReply),
    ]);
    _reload();
  }

  final PhoneApi _api;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  String? _modelName;
  List<AiSession> _sessions = const [];
  List<AiPersona> _personas = const [];
  AiStreamingReply? _streaming;
  String? _lastError;

  @override
  bool get canManage => false;

  @override
  String? get modelName => _modelName;

  @override
  List<AiSession> get sessions => _sessions;

  @override
  List<AiPersona> get personas => _personas;

  @override
  AiStreamingReply? get streaming => _streaming;

  @override
  String? get lastError => _lastError;

  Future<void> _reload() async {
    try {
      final Map<String, dynamic>? json = await _api.get('/api/ai') as Map<String, dynamic>?;
      if (json == null) return;
      _modelName = json['modelName'] as String?;
      _sessions = [
        for (final Object? item in json['sessions'] as List<dynamic>) AiSession.fromJson(item as Map<String, dynamic>),
      ];
      _personas = [
        for (final Object? item in json['personas'] as List<dynamic>) AiPersona.fromJson(item as Map<String, dynamic>),
      ];
      _streaming = AiStreamingReply.fromJson(json['streaming']);
      _lastError = json['lastError'] as String?;
      notifyListeners();
    } on Object {
      // The phone may be away for a moment; the next event reloads.
    }
  }

  void _onReply(String data) {
    _streaming = AiStreamingReply.fromJson(jsonDecode(data));
    notifyListeners();
  }

  @override
  Future<String> createSession(String personaId) async {
    final Map<String, dynamic> json =
        await _api.postForJson('/api/ai/session', {'personaId': personaId}) as Map<String, dynamic>;
    await _reload();
    return json['id'] as String;
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions = _sessions.where((session) => session.id != id).toList();
    notifyListeners();
    await _api.post('/api/ai/session/delete', {'id': id});
  }

  @override
  Future<void> send(String sessionId, String text) async {
    _streaming = AiStreamingReply(sessionId: sessionId, text: '');
    notifyListeners();
    await _api.post('/api/ai/send', {'sessionId': sessionId, 'text': text});
  }

  @override
  void stop() => _api.post('/api/ai/stop', const {}).ignore();

  @override
  Future<void> savePersona(AiPersona persona) async {}

  @override
  Future<void> deletePersona(String id) async {}

  @override
  void dispose() {
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
