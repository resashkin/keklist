import 'dart:async';
import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_context_builder.dart';
import 'package:keklist/domain/services/ai/ai_engine.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:keklist/domain/services/ai/ai_model_store.dart';
import 'package:keklist/domain/services/ai/ai_prompts.dart';
import 'package:keklist/domain/services/ai/ai_storage.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:uuid/uuid.dart';

/// Runs everything on the phone: the chosen model, the records it reads and where sessions are kept.
final class LocalAiBackend extends AiBackend {
  LocalAiBackend({
    required AiStorage storage,
    required AiModelStore models,
    required MindRepository minds,
    required EmotionRepository emotions,
    AiEngine? engine,
  }) : _storage = storage,
       _models = models,
       _minds = minds,
       _emotions = emotions,
       _engine = engine ?? AiEngine() {
    _subscriptions.addAll([
      _storage.changes.listen((_) => notifyListeners()),
      _minds.stream.listen((_) => notifyListeners()),
    ]);
    _models.addListener(_modelsChanged);
  }

  final AiStorage _storage;
  final AiModelStore _models;
  final MindRepository _minds;
  final EmotionRepository _emotions;
  final AiEngine _engine;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  static const int _summaryDaysLimit = 30;
  static const int _historyChars = 4000;
  static const int _historyMessages = 12;
  static const int _autoSummariesPerVisit = 7;
  static const Duration _streamThrottle = Duration(milliseconds: 120);

  String _language = 'English';
  Map<String, String> _builtInNames = const {};
  AiStreamingReply? _streaming;
  String? _lastError;
  final Set<int> _summarizing = {};
  String? _loadedModelId;

  bool _autoSummaries = false;
  bool _isCharging = false;
  int _autoSummariesLeft = 0;
  StreamSubscription<String>? _backgroundSummary;
  StreamSubscription<BatteryState>? _battery;

  @override
  bool get canManage => true;

  @override
  String? get modelName => _models.active?.name;

  @override
  List<AiSession> get sessions => _storage.sessions;

  @override
  List<AiPersona> get personas => [
    ...AiPrompts.builtIn(
      therapist: _builtInNames[AiPrompts.therapistId] ?? 'Therapist',
      coach: _builtInNames[AiPrompts.coachId] ?? 'Coach',
      friend: _builtInNames[AiPrompts.friendId] ?? 'Friend',
    ),
    ..._storage.customPersonas,
  ];

  @override
  Map<int, AiDaySummary> get summaries => _storage.summaries;

  Map<int, List<Mind>> get _mindsByDay {
    final Map<int, List<Mind>> days = {};
    final int today = DateUtils.getTodayIndex();
    for (final Mind mind in _minds.values) {
      if (mind.dayIndex > today || mind.plainNote.trim().isEmpty && mind.emotionIds.isEmpty) continue;
      days.putIfAbsent(mind.dayIndex, () => []).add(mind);
    }
    return days;
  }

  @override
  List<int> get summaryDays =>
      (_mindsByDay.keys.toList()..sort((a, b) => b.compareTo(a))).take(_summaryDaysLimit).toList();

  @override
  Set<int> get staleSummaryDays {
    final Map<int, List<Mind>> days = _mindsByDay;
    final Map<int, AiDaySummary> stored = summaries;
    return {
      for (final int day in summaryDays)
        if (stored[day] case final AiDaySummary summary when summary.sourceHash != _hashOf(day, days[day]!)) day,
    };
  }

  @override
  Set<int> get summarizingDays => Set.unmodifiable(_summarizing);

  @override
  AiStreamingReply? get streaming => _streaming;

  @override
  String? get lastError => _lastError;

  Map<String, Emotion> get _emotionsById => {for (final Emotion emotion in _emotions.values) emotion.id: emotion};

  AiContextBuilder _builder() => AiContextBuilder(
    minds: _minds.values,
    emotions: _emotionsById,
    summaries: summaries,
    todayIndex: DateUtils.getTodayIndex(),
  );

  String _hashOf(int day, List<Mind> minds) => sha1
      .convert(
        utf8.encode(
          '${AiPrompts.daySummaryVersion}\n'
          '${_builder().dayBlock(day, [...minds]..sort((a, b) => a.sortIndex.compareTo(b.sortIndex)))}',
        ),
      )
      .toString();

  void _modelsChanged() {
    final String? activeId = _models.active?.id;
    if (_loadedModelId != null && _loadedModelId != activeId) unawaited(_engine.unload());
    _loadedModelId = activeId;
    notifyListeners();
  }

  @override
  void configure({required String language, required Map<String, String> builtInNames}) {
    if (_language == language && mapEquals(_builtInNames, builtInNames)) return;
    _language = language;
    _builtInNames = builtInNames;
    // Screens call this while they build.
    scheduleMicrotask(notifyListeners);
  }

  static bool mapEquals(Map<String, String> a, Map<String, String> b) =>
      a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

  @override
  Future<String> createSession(String personaId) async {
    final DateTime now = DateTime.now();
    final AiSession session = AiSession(
      id: const Uuid().v4(),
      personaId: personaId,
      title: '',
      createdAt: now,
      updatedAt: now,
    );
    await _storage.putSession(session);
    return session.id;
  }

  @override
  Future<void> deleteSession(String id) => _storage.deleteSession(id);

  @override
  Future<void> send(String sessionId, String text) async {
    final AiModelInfo? model = _models.active;
    final AiSession? stored = _storage.session(sessionId);
    if (model == null || stored == null || _streaming != null || text.trim().isEmpty) return;
    await _stopBackgroundSummary();
    _lastError = null;
    final AiMessage question = AiMessage(role: AiRole.user, text: text.trim(), createdAt: DateTime.now());
    AiSession session = stored.copyWith(
      title: stored.title.isEmpty ? _titleOf(question.text) : null,
      updatedAt: DateTime.now(),
      messages: [...stored.messages, question],
    );
    await _storage.putSession(session);

    final AiContext context = _builder().build(question.text);
    final String system = AiPrompts.system(persona: personaOf(session), language: _language, context: context.text);
    final StringBuffer reply = StringBuffer();
    _streaming = AiStreamingReply(sessionId: sessionId, text: '');
    notifyListeners();
    Timer? throttle;
    try {
      await for (final String piece in _engine.generate(
        model: model,
        path: _models.pathOf(model),
        system: system,
        history: _recentHistory(session.messages),
      )) {
        reply.write(piece);
        throttle ??= Timer(_streamThrottle, () {
          throttle = null;
          _streaming = AiStreamingReply(sessionId: sessionId, text: AiPrompts.visiblePart(reply.toString()));
          notifyListeners();
        });
      }
    } on Object catch (error) {
      _lastError = error.toString();
    }
    throttle?.cancel();
    final (String answer, List<String> suggestions) = AiPrompts.splitSuggestions(reply.toString());
    if (answer.isNotEmpty) {
      session = (_storage.session(sessionId) ?? session).copyWith(
        updatedAt: DateTime.now(),
        messages: [
          ...(_storage.session(sessionId) ?? session).messages,
          AiMessage(
            role: AiRole.assistant,
            text: answer,
            createdAt: DateTime.now(),
            suggestions: suggestions,
            dayIndexes: context.dayIndexes,
          ),
        ],
      );
      await _storage.putSession(session);
    }
    _streaming = null;
    notifyListeners();
    _continueAutoSummaries();
  }

  static String _titleOf(String text) {
    final String line = text.split('\n').first.trim();
    return line.length <= 48 ? line : '${line.substring(0, 47)}…';
  }

  /// The latest turns that fit; the oldest go first.
  static List<AiMessage> _recentHistory(List<AiMessage> messages) {
    final List<AiMessage> recent = [];
    int chars = 0;
    for (final AiMessage message in messages.reversed.take(_historyMessages)) {
      chars += message.text.length;
      if (chars > _historyChars && recent.isNotEmpty) break;
      recent.insert(0, message);
    }
    while (recent.isNotEmpty && recent.first.role != AiRole.user) {
      recent.removeAt(0);
    }
    return recent;
  }

  @override
  void stop() => _engine.stop();

  @override
  Future<void> summarizeDay(int dayIndex) async {
    final AiModelInfo? model = _models.active;
    final List<Mind>? minds = _mindsByDay[dayIndex];
    if (model == null || minds == null || _summarizing.contains(dayIndex)) return;
    _summarizing.add(dayIndex);
    _lastError = null;
    notifyListeners();
    try {
      final String text = await _summaryStream(model, dayIndex, minds).join();
      final String summary = text.trim();
      if (summary.isNotEmpty) {
        await _storage.putSummary(
          AiDaySummary(
            dayIndex: dayIndex,
            text: summary,
            sourceHash: _hashOf(dayIndex, minds),
            createdAt: DateTime.now(),
          ),
        );
      }
    } on Object catch (error) {
      _lastError = error.toString();
    }
    _summarizing.remove(dayIndex);
    notifyListeners();
  }

  Stream<String> _summaryStream(AiModelInfo model, int dayIndex, List<Mind> minds) {
    return _engine.generate(
      model: model,
      path: _models.pathOf(model),
      system: 'You write short, kind diary summaries.',
      history: [
        AiMessage(
          role: AiRole.user,
          text: AiPrompts.daySummary(
            language: _language,
            records: _builder().dayBlock(dayIndex, [...minds]..sort((a, b) => a.sortIndex.compareTo(b.sortIndex))),
          ),
          createdAt: DateTime.now(),
        ),
      ],
      maxTokens: 200,
    );
  }

  @override
  void setAutoSummaries(bool enabled) {
    if (_autoSummaries == enabled) return;
    _autoSummaries = enabled;
    if (!enabled) {
      unawaited(_battery?.cancel());
      _battery = null;
      unawaited(_stopBackgroundSummary());
      return;
    }
    _autoSummariesLeft = _autoSummariesPerVisit;
    _battery = Battery().onBatteryStateChanged.listen((state) {
      _isCharging = state == BatteryState.charging || state == BatteryState.full;
      if (_isCharging) {
        _continueAutoSummaries();
      } else {
        unawaited(_stopBackgroundSummary());
      }
    }, onError: (_) {});
  }

  /// One missing or outdated summary at a time, newest day first, while nothing else runs.
  void _continueAutoSummaries() {
    final AiModelInfo? model = _models.active;
    if (!_autoSummaries || !_isCharging || model == null || _autoSummariesLeft <= 0) return;
    if (_backgroundSummary != null || _streaming != null || _summarizing.isNotEmpty) return;
    final Map<int, AiDaySummary> stored = summaries;
    final Set<int> stale = staleSummaryDays;
    final int? day = summaryDays.where((day) => !stored.containsKey(day) || stale.contains(day)).firstOrNull;
    final List<Mind>? minds = day == null ? null : _mindsByDay[day];
    if (day == null || minds == null) return;
    _autoSummariesLeft--;
    _summarizing.add(day);
    notifyListeners();
    final StringBuffer text = StringBuffer();
    _backgroundSummary = _summaryStream(model, day, minds).listen(
      text.write,
      onError: (_) {},
      onDone: () async {
        _backgroundSummary = null;
        if (text.toString().trim().isNotEmpty) {
          await _storage.putSummary(
            AiDaySummary(
              dayIndex: day,
              text: text.toString().trim(),
              sourceHash: _hashOf(day, minds),
              createdAt: DateTime.now(),
            ),
          );
        }
        _summarizing.remove(day);
        notifyListeners();
        _continueAutoSummaries();
      },
    );
  }

  Future<void> _stopBackgroundSummary() async {
    final StreamSubscription<String>? summary = _backgroundSummary;
    if (summary == null) return;
    _backgroundSummary = null;
    await summary.cancel();
    _summarizing.clear();
    notifyListeners();
  }

  @override
  Future<void> savePersona(AiPersona persona) =>
      _storage.putPersona(persona.id.isEmpty ? persona.copyWith(id: const Uuid().v4(), isBuiltIn: false) : persona);

  @override
  Future<void> deletePersona(String id) => _storage.deletePersona(id);

  @override
  void dispose() {
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      subscription.cancel();
    }
    _battery?.cancel();
    _models.removeListener(_modelsChanged);
    unawaited(_engine.unload());
    super.dispose();
  }
}
