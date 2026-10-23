import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:keklist/domain/services/ai/device_memory.dart';

/// Where models come from: Google's AI Edge Gallery list for LiteRT-LM and a Hugging Face search for GGUF.
/// Only open models are offered: gated repositories need a Hugging Face login.
final class AiCatalog {
  AiCatalog({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _galleryRepo = 'google-ai-edge/gallery';
  static const String _chatTask = 'llm_chat';

  /// A GGUF file needs about its own size in memory plus the context, so it gets at most this share of the RAM.
  static const double _ggufMemoryShare = 0.55;

  /// Gemma 4 E2B is open, writes good Russian and other languages, and fits phones with 6 GB.
  static const String recommendedRepo = 'unsloth/gemma-4-E2B-it-GGUF';
  static const String _recommendedQuant = 'Q4_K_M';

  /// Reasoning distills spend the reply on hidden thinking and write poorly outside English.
  static bool isReasoning(String name) => RegExp(r'\bR1\b|distill', caseSensitive: false).hasMatch(name);

  /// The newest Android and iOS lists of the Gallery app, merged; the current platform's entries win.
  Future<List<AiModelInfo>> galleryModels() async {
    final List<String> listFiles = await _latestGalleryLists();
    final Map<String, AiModelInfo> models = {};
    for (final String file in listFiles) {
      final Object? json = await _getJson(
        Uri.https('raw.githubusercontent.com', '/$_galleryRepo/main/model_allowlists/$file'),
      );
      for (final Object? entry in (json as Map<String, dynamic>)['models'] as List<dynamic>) {
        final AiModelInfo? model = _galleryModel(entry as Map<String, dynamic>);
        if (model != null) models.putIfAbsent(model.repo + model.file, () => model);
      }
    }
    final Set<String> openRepos = {
      for (final String repo in models.values.map((model) => model.repo).toSet())
        if (await _isOpen(repo)) repo,
    };
    final double? memoryGb = DeviceMemory.totalGb;
    return [
      ?await _recommended(),
      ...models.values
          .where((model) => openRepos.contains(model.repo) && !isReasoning(model.name))
          .where((model) => memoryGb == null || (model.minMemoryGb ?? 0) <= memoryGb + 0.5)
          .toList()
        ..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes)),
    ];
  }

  Future<AiModelInfo?> _recommended() async {
    try {
      return (await ggufFiles(recommendedRepo)).where((model) => model.file.contains(_recommendedQuant)).firstOrNull;
    } on Object {
      return null;
    }
  }

  Future<List<String>> _latestGalleryLists() async {
    final Object? listing = await _getJson(
      Uri.https('api.github.com', '/repos/$_galleryRepo/contents/model_allowlists'),
    );
    final List<String> names = [
      for (final Object? item in listing as List<dynamic>)
        if ((item as Map<String, dynamic>)['name'] case final String name when name.endsWith('.json')) name,
    ];
    String? newest(Iterable<String> files) =>
        files.isEmpty ? null : files.reduce((a, b) => _compareVersions(a, b) >= 0 ? a : b);
    final String? android = newest(names.where((name) => RegExp(r'^\d').hasMatch(name)));
    final String? ios = newest(names.where((name) => name.startsWith('ios_')));
    final bool isIos = defaultTargetPlatform == TargetPlatform.iOS;
    return [?(isIos ? ios : android), ?(isIos ? android : ios)];
  }

  static int _compareVersions(String a, String b) {
    List<int> parts(String name) => RegExp(r'\d+').allMatches(name).map((match) => int.parse(match[0]!)).toList();
    final List<int> left = parts(a), right = parts(b);
    for (int index = 0; index < left.length && index < right.length; index++) {
      if (left[index] != right[index]) return left[index].compareTo(right[index]);
    }
    return left.length.compareTo(right.length);
  }

  static AiModelInfo? _galleryModel(Map<String, dynamic> json) {
    final List<dynamic> tasks = json['taskTypes'] as List<dynamic>? ?? const [];
    final String? repo = json['modelId'] as String?;
    final String? file = json['modelFile'] as String?;
    if (!tasks.contains(_chatTask) || repo == null || file == null || !file.endsWith('.litertlm')) return null;
    final Map<String, dynamic> config = json['defaultConfig'] as Map<String, dynamic>? ?? const {};
    return AiModelInfo(
      name: json['name'] as String? ?? repo.split('/').last,
      repo: repo,
      file: file,
      revision: json['commitHash'] as String? ?? 'main',
      sizeBytes: (json['sizeInBytes'] as num?)?.toInt() ?? 0,
      format: AiModelFormat.liteRtLm,
      minMemoryGb: (json['minDeviceMemoryInGb'] as num?)?.toDouble(),
      description: json['description'] as String?,
      contextSize: ((config['maxTokens'] as num?)?.toInt() ?? 4096).clamp(1024, 4096),
    );
  }

  Future<bool> _isOpen(String repo) async {
    try {
      final Object? json = await _getJson(Uri.https('huggingface.co', '/api/models/$repo'));
      return (json as Map<String, dynamic>)['gated'] == false;
    } on Object {
      return false;
    }
  }

  /// Open GGUF repositories, most downloaded first.
  Future<List<HfRepoInfo>> searchGguf(String query) async {
    final Object? json = await _getJson(
      Uri.parse(
        'https://huggingface.co/api/models?filter=gguf&gated=false&sort=downloads&direction=-1&limit=40'
        '&expand[]=downloads&expand[]=likes${query.trim().isEmpty ? '' : '&search=${Uri.encodeQueryComponent(query.trim())}'}',
      ),
    );
    return [
      for (final Object? item in json as List<dynamic>)
        HfRepoInfo(
          id: (item as Map<String, dynamic>)['id'] as String,
          downloads: (item['downloads'] as num?)?.toInt() ?? 0,
          likes: (item['likes'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// The repository's chat GGUF files that fit this phone's memory, smallest first; projectors are left out.
  Future<List<AiModelInfo>> ggufFiles(String repo) async {
    final Map<String, dynamic> info =
        await _getJson(Uri.https('huggingface.co', '/api/models/$repo')) as Map<String, dynamic>;
    if (info['gated'] != false) return const [];
    final String revision = info['sha'] as String? ?? 'main';
    final Object? tree = await _getJson(Uri.https('huggingface.co', '/api/models/$repo/tree/$revision'));
    final int? memory = DeviceMemory.totalBytes;
    return [
      for (final Object? item in tree as List<dynamic>)
        if ((item as Map<String, dynamic>)['path'] case final String path
            when path.toLowerCase().endsWith('.gguf') && !path.toLowerCase().contains('mmproj'))
          if (((item['lfs'] as Map<String, dynamic>?)?['size'] ?? item['size']) case final num size
              when memory == null || size <= memory * _ggufMemoryShare)
            AiModelInfo(
              name: path.split('/').last.replaceAll(RegExp(r'\.gguf$', caseSensitive: false), ''),
              repo: repo,
              file: path,
              revision: revision,
              sizeBytes: size.toInt(),
              format: AiModelFormat.gguf,
            ),
    ]..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
  }

  Future<Object?> _getJson(Uri uri) async {
    final http.Response response = await _client.get(uri, headers: const {'Accept': 'application/json'});
    if (response.statusCode != 200) throw http.ClientException('${response.statusCode} for $uri', uri);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
