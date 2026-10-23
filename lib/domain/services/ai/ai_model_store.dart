import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:keklist/domain/services/ai/ai_catalog.dart';
import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:keklist/domain/services/ai/ai_storage.dart';
import 'package:path_provider/path_provider.dart';

enum AiDownloadStatus { running, paused, failed }

final class AiDownload {
  const AiDownload({required this.model, required this.status, required this.progress, this.error});

  final AiModelInfo model;
  final AiDownloadStatus status;
  final double progress;
  final String? error;
}

/// Downloads models in the background with resume, keeps several of them and remembers the active one.
/// The network is used only here and by [AiCatalog]; the models themselves never go online.
final class AiModelStore extends ChangeNotifier {
  AiModelStore({required AiStorage storage, AiCatalog? catalog}) : _storage = storage, catalog = catalog ?? AiCatalog();

  final AiStorage _storage;
  final AiCatalog catalog;

  static const String _group = 'ai_models';
  static const String _directory = 'ai_models';

  final Map<String, AiDownload> _downloads = {};
  final Map<String, DownloadTask> _tasks = {};
  StreamSubscription<TaskUpdate>? _updates;
  late String _modelsPath;

  List<AiModelInfo> _gallery = const [];
  bool _isLoadingGallery = false;
  Object? _galleryError;

  List<AiModelInfo> get installed => _storage.installedModels..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
  Map<String, AiDownload> get downloads => Map.unmodifiable(_downloads);
  List<AiModelInfo> get gallery => _gallery;
  bool get isLoadingGallery => _isLoadingGallery;
  Object? get galleryError => _galleryError;

  AiModelInfo? get active {
    final List<AiModelInfo> models = installed;
    final String? id = _storage.activeModelId;
    return models.where((model) => model.id == id).firstOrNull ?? models.firstOrNull;
  }

  bool isInstalled(AiModelInfo model) => installed.any((item) => item.id == model.id);

  String pathOf(AiModelInfo model) => '$_modelsPath/${_fileName(model)}';

  Future<void> start() async {
    _modelsPath = '${(await getApplicationSupportDirectory()).path}/$_directory';
    await Directory(_modelsPath).create(recursive: true);
    _gallery = _storage.cachedGallery ?? const [];
    _updates = FileDownloader().updates.listen(_onUpdate);
    await FileDownloader().trackTasksInGroup(_group);
    await FileDownloader().start();
    for (final TaskRecord record in await FileDownloader().database.allRecords(group: _group)) {
      if (record.task case final DownloadTask task) _restore(task, record.status, record.progress);
    }
    notifyListeners();
  }

  void _restore(DownloadTask task, TaskStatus status, double progress) {
    final AiModelInfo model = AiModelInfo.fromJson(jsonDecode(task.metaData) as Map<String, dynamic>);
    if (status == TaskStatus.complete) {
      unawaited(_finish(model, task.taskId));
      return;
    }
    _tasks[model.id] = task;
    _downloads[model.id] = AiDownload(
      model: model,
      status: switch (status) {
        TaskStatus.paused => AiDownloadStatus.paused,
        TaskStatus.failed || TaskStatus.notFound || TaskStatus.canceled => AiDownloadStatus.failed,
        _ => AiDownloadStatus.running,
      },
      progress: progress.clamp(0, 1),
    );
  }

  /// Refreshes the Gallery list; the last good list stays when the network fails.
  Future<void> refreshGallery() async {
    if (_isLoadingGallery) return;
    _isLoadingGallery = true;
    _galleryError = null;
    notifyListeners();
    try {
      _gallery = await catalog.galleryModels();
      await _storage.putCachedGallery(_gallery);
    } on Object catch (error) {
      _galleryError = error;
    }
    _isLoadingGallery = false;
    notifyListeners();
  }

  Future<bool> isOnCellular() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.mobile) && !results.contains(ConnectivityResult.wifi);
  }

  Future<void> download(AiModelInfo model) async {
    if (isInstalled(model) || _downloads[model.id]?.status == AiDownloadStatus.running) return;
    final DownloadTask task = DownloadTask(
      taskId: _taskId(model),
      url: model.url.toString(),
      filename: _fileName(model),
      directory: _directory,
      baseDirectory: BaseDirectory.applicationSupport,
      group: _group,
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 5,
      displayName: model.name,
      metaData: jsonEncode(model.toJson()),
    );
    _tasks[model.id] = task;
    _downloads[model.id] = AiDownload(model: model, status: AiDownloadStatus.running, progress: 0);
    notifyListeners();
    if (!await FileDownloader().enqueue(task)) _fail(model, 'enqueue');
  }

  Future<void> pause(AiModelInfo model) async {
    if (_tasks[model.id] case final DownloadTask task) await FileDownloader().pause(task);
  }

  Future<void> resume(AiModelInfo model) async {
    final DownloadTask? task = _tasks[model.id];
    if (task == null || !await FileDownloader().resume(task)) {
      _downloads.remove(model.id);
      await download(model);
    }
  }

  Future<void> cancel(AiModelInfo model) async {
    final DownloadTask? task = _tasks.remove(model.id);
    _downloads.remove(model.id);
    notifyListeners();
    if (task != null) {
      await FileDownloader().cancel(task);
      await FileDownloader().database.deleteRecordWithId(task.taskId);
    }
  }

  Future<void> delete(AiModelInfo model) async {
    final File file = File(pathOf(model));
    if (await file.exists()) await file.delete();
    await _storage.deleteInstalled(model.id);
    if (_storage.activeModelId == model.id) await _storage.setActiveModelId(null);
    notifyListeners();
  }

  Future<void> setActive(AiModelInfo model) async {
    await _storage.setActiveModelId(model.id);
    notifyListeners();
  }

  Future<int> usedBytes() async {
    int total = 0;
    for (final AiModelInfo model in installed) {
      final File file = File(pathOf(model));
      if (await file.exists()) total += await file.length();
    }
    return total;
  }

  void _onUpdate(TaskUpdate update) {
    if (update.task.group != _group || update.task is! DownloadTask) return;
    final AiModelInfo model = AiModelInfo.fromJson(jsonDecode(update.task.metaData) as Map<String, dynamic>);
    final AiDownload? current = _downloads[model.id];
    switch (update) {
      case TaskProgressUpdate(:final progress) when progress >= 0:
        _downloads[model.id] = AiDownload(
          model: model,
          status: current?.status == AiDownloadStatus.paused ? AiDownloadStatus.paused : AiDownloadStatus.running,
          progress: progress.clamp(0, 1),
        );
        notifyListeners();
      case TaskStatusUpdate(:final status, :final exception):
        switch (status) {
          case TaskStatus.complete:
            unawaited(_finish(model, update.task.taskId));
          case TaskStatus.paused:
            _downloads[model.id] = AiDownload(
              model: model,
              status: AiDownloadStatus.paused,
              progress: current?.progress ?? 0,
            );
            notifyListeners();
          case TaskStatus.failed || TaskStatus.notFound:
            _fail(model, exception?.description ?? status.name);
          case TaskStatus.canceled:
            if (_downloads.containsKey(model.id)) _fail(model, status.name);
          case TaskStatus.enqueued || TaskStatus.running || TaskStatus.waitingToRetry:
            _downloads[model.id] = AiDownload(
              model: model,
              status: AiDownloadStatus.running,
              progress: current?.progress ?? 0,
            );
            notifyListeners();
        }
      default:
        break;
    }
  }

  void _fail(AiModelInfo model, String error) {
    _downloads[model.id] = AiDownload(
      model: model,
      status: AiDownloadStatus.failed,
      progress: _downloads[model.id]?.progress ?? 0,
      error: error,
    );
    notifyListeners();
  }

  Future<void> _finish(AiModelInfo model, String taskId) async {
    _downloads.remove(model.id);
    _tasks.remove(model.id);
    await FileDownloader().database.deleteRecordWithId(taskId);
    if (await File(pathOf(model)).exists()) {
      await _storage.putInstalled(model);
      if (_storage.activeModelId == null) await _storage.setActiveModelId(model.id);
    }
    notifyListeners();
  }

  static String _taskId(AiModelInfo model) => 'ai:${model.id}';

  static String _fileName(AiModelInfo model) =>
      '${model.repo.replaceAll('/', '__')}__${model.file.replaceAll('/', '__')}';

  @override
  void dispose() {
    _updates?.cancel();
    super.dispose();
  }
}
