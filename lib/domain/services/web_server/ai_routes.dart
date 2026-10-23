import 'dart:async';
import 'dart:convert';

import 'package:keklist/domain/services/ai/ai_backend.dart';

/// The phone's AI for the web version: the browser sends messages and the phone's model answers.
/// [changes] tells browsers to reload the state; [replies] carries the reply being written.
final class AiRoutes {
  AiRoutes({required AiBackend backend}) : _backend = backend {
    _backend.addListener(_changed);
  }

  final AiBackend _backend;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  final StreamController<String> _replies = StreamController<String>.broadcast();
  String? _lastState;
  String? _lastReply;

  Stream<void> get changes => _changes.stream;
  Stream<String> get replies => _replies.stream;

  Map<String, dynamic> stateJson() => _backend.stateJson();

  void _changed() {
    final Map<String, dynamic> state = _backend.stateJson();
    final Object? streaming = state.remove('streaming');
    final String encoded = jsonEncode(state);
    if (encoded != _lastState) {
      _lastState = encoded;
      _changes.add(null);
    }
    final String reply = jsonEncode(streaming);
    if (reply != _lastReply) {
      _lastReply = reply;
      _replies.add(reply);
    }
  }

  /// Answers the POST at [path] with its JSON answer, or null when there is nothing to answer.
  Future<Object?> post(String path, Map<String, dynamic> body) async {
    switch (path) {
      case '/api/ai/session':
        return {'id': await _backend.createSession(body['personaId'] as String)};
      case '/api/ai/session/delete':
        await _backend.deleteSession(body['id'] as String);
      case '/api/ai/send':
        unawaited(_backend.send(body['sessionId'] as String, body['text'] as String));
      case '/api/ai/stop':
        _backend.stop();
      case '/api/ai/summarize':
        unawaited(_backend.summarizeDay((body['day'] as num).toInt()));
      default:
        throw ArgumentError.value(path, 'path');
    }
    return null;
  }

  void dispose() {
    _backend.removeListener(_changed);
    _changes.close();
    _replies.close();
  }
}
