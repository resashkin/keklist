import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:keklist/domain/services/ai/device_memory.dart';
import 'package:llamadart/llamadart.dart';

/// One model in memory at a time, one generation at a time. llamadart runs GGUF through llama.cpp and
/// `.litertlm` through LiteRT-LM behind the same API; nothing here touches the network.
/// The model file is fine but the phone can't load it, almost always for lack of memory.
final class AiModelLoadException implements Exception {
  const AiModelLoadException(this.model);

  final AiModelInfo model;

  @override
  String toString() => 'AiModelLoadException: ${model.id}';
}

final class AiEngine {
  LlamaEngine? _engine;
  String? _loadedId;
  Future<void> _queue = Future.value();
  Future<void> _unloading = Future.value();

  static const double _loadShare = 1.2;
  static const double _firstLiteRtLoadShare = 2.0;
  static const int _contextReserveBytes = 384 << 20;
  bool _isGenerating = false;

  String? get loadedId => _loadedId;
  bool get isGenerating => _isGenerating;

  Future<void> _load(AiModelInfo model, String path) async {
    await _unloading;
    if (_loadedId == model.id && _engine != null) return;
    if (_engine != null) await unload();
    if (!_fitsInMemory(model, path)) throw AiModelLoadException(model);
    final LlamaEngine engine = _engine = LlamaEngine(LlamaBackend());
    final LlamaModel source = LlamaModel(ModelSource.path(path));
    try {
      try {
        await engine.setModel(source, params: ModelParams(contextSize: model.contextSize));
      } on LlamaUnsupportedException {
        await engine.setModel(
          source,
          params: ModelParams(contextSize: model.contextSize, device: ComputeDevice.cpu),
        );
      }
    } on LlamaModelFormatException {
      rethrow;
    } on LlamaException catch (error) {
      debugPrint('AI engine: $error');
      throw AiModelLoadException(model);
    }
    _loadedId = model.id;
  }

  /// The system stops an app that takes more than it may, so a model that won't fit isn't loaded at all.
  static bool _fitsInMemory(AiModelInfo model, String path) {
    final int? available = DeviceMemory.availableBytes;
    if (available == null) return true;
    final bool buildsWeightCache = model.format == AiModelFormat.liteRtLm && !_hasWeightCache(path);
    final double share = buildsWeightCache ? _firstLiteRtLoadShare : _loadShare;
    return model.sizeBytes * share + _contextReserveBytes <= available;
  }

  static bool _hasWeightCache(String path) {
    final File model = File(path);
    final String prefix = model.uri.pathSegments.last;
    try {
      return model.parent.listSync().any((entry) {
        final String name = entry.uri.pathSegments.last;
        return name.startsWith(prefix) && name.endsWith('weight_cache.bin');
      });
    } on FileSystemException {
      return false;
    }
  }

  /// Streams the reply text; generations wait for each other.
  Stream<String> generate({
    required AiModelInfo model,
    required String path,
    required String system,
    required List<AiMessage> history,
    int maxTokens = 512,
  }) {
    final StreamController<String> controller = StreamController<String>();
    final Completer<void> done = Completer<void>();
    final Completer<void> finished = Completer<void>();
    StreamSubscription<LlamaCompletionChunk>? subscription;
    bool isCancelled = false;
    // A listener that leaves ends the generation, whether it already runs or still waits its turn.
    controller.onCancel = () {
      isCancelled = true;
      if (subscription != null) _engine?.cancelGeneration();
      unawaited(subscription?.cancel());
      if (!finished.isCompleted) finished.complete();
    };
    final Future<void> previous = _queue;
    _queue = done.future;
    previous.whenComplete(() async {
      try {
        if (isCancelled) return;
        await _load(model, path);
        if (isCancelled) return;
        _isGenerating = true;
        final Stream<LlamaCompletionChunk> chunks = _engine!.create(
          [
            LlamaChatMessage.fromText(role: LlamaChatRole.system, text: system),
            for (final AiMessage message in history)
              LlamaChatMessage.fromText(
                role: message.role == AiRole.user ? LlamaChatRole.user : LlamaChatRole.assistant,
                text: message.text,
              ),
          ],
          params: GenerationParams(maxTokens: maxTokens, temp: 0.7, topK: 40, topP: 0.9),
          enableThinking: false,
        );
        subscription = chunks.listen(
          (chunk) {
            if (chunk.text.isNotEmpty && !isCancelled) controller.add(chunk.text);
          },
          onError: (Object error, StackTrace stack) {
            if (!isCancelled) controller.addError(error, stack);
            if (!finished.isCompleted) finished.complete();
          },
          onDone: () {
            if (!finished.isCompleted) finished.complete();
          },
          cancelOnError: true,
        );
        await finished.future;
      } on Object catch (error, stack) {
        debugPrint('AI engine: $error');
        if (!isCancelled) controller.addError(error, stack);
      } finally {
        _isGenerating = false;
        unawaited(controller.close());
        done.complete();
      }
    });
    return controller.stream;
  }

  void stop() => _engine?.cancelGeneration();

  /// Frees the model, e.g. after it was deleted or another one became active.
  Future<void> unload() {
    final LlamaEngine? engine = _engine;
    _engine = null;
    _loadedId = null;
    final Future<void> previous = _unloading;
    return _unloading = previous.then((_) => engine?.dispose());
  }
}
