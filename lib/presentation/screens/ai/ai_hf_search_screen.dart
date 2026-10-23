import 'dart:async';

import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:keklist/domain/services/ai/ai_model_store.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/screens/ai/ai_format.dart';
import 'package:keklist/presentation/screens/ai/ai_models_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Open GGUF repositories on Hugging Face; a repository lists only the files that fit this phone's memory.
final class AiHfSearchScreen extends StatefulWidget {
  const AiHfSearchScreen({super.key});

  @override
  State<AiHfSearchScreen> createState() => _AiHfSearchScreenState();
}

final class _AiHfSearchScreenState extends State<AiHfSearchScreen> {
  /// With nothing typed, popular repositories of model sizes a phone can hold.
  static const List<String> _phoneSizes = ['0.5B', '1B', '1.5B', '2B', '3B', '4B'];
  static const double _maxWidth = 700.0;

  /// "35B-A3B" also matches "3B": the largest size named in the repository decides.
  static bool _fitsPhone(String repo) {
    final Iterable<double> sizes = RegExp(
      r'(?<![A-Za-z\d.])(\d+(?:\.\d+)?)[Bb](?![A-Za-z])',
    ).allMatches(repo).map((match) => double.parse(match[1]!));
    return sizes.isEmpty || sizes.reduce((a, b) => a > b ? a : b) <= 4;
  }

  final TextEditingController _query = TextEditingController();
  Timer? _debounce;
  List<HfRepoInfo> _repos = const [];
  bool _isLoading = false;
  Object? _error;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final int request = ++_request;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final AiModelStore store = context.read<AiModelStore>();
      final List<HfRepoInfo> repos = query.trim().isNotEmpty
          ? await store.catalog.searchGguf(query)
          : ({
              for (final List<HfRepoInfo> found in await Future.wait(_phoneSizes.map(store.catalog.searchGguf)))
                for (final HfRepoInfo repo in found.take(10))
                  if (_fitsPhone(repo.id)) repo.id: repo,
            }.values.toList()..sort((a, b) => b.downloads.compareTo(a.downloads)));
      if (!mounted || request != _request) return;
      setState(() => _repos = repos);
    } on Object catch (error) {
      if (mounted && request == _request) setState(() => _error = error);
    }
    if (mounted && request == _request) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: GlassAppBar(centerTitle: true, title: Text(context.l10n.aiHuggingFace)),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 64.0,
            bottom: MediaQuery.paddingOf(context).bottom + 16.0,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _query,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: context.l10n.aiSearchModels,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
                ),
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
                },
                onSubmitted: _search,
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(),
            if (_error != null) Padding(padding: const EdgeInsets.all(16.0), child: Text(context.l10n.aiCatalogFailed)),
            for (final HfRepoInfo repo in _repos)
              ListTile(
                title: Text(repo.id, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('↓ ${AiFormat.count(repo.downloads)} · ♥ ${AiFormat.count(repo.likes)}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _HfFilesSheet.show(context, repo: repo.id),
              ),
          ],
        ),
      ),
    ),
  );
}

final class _HfFilesSheet extends StatefulWidget {
  const _HfFilesSheet({required this.repo});

  final String repo;

  static Future<void> show(BuildContext context, {required String repo}) => KekSheet.show<void>(
    context: context,
    builder: (_) => _HfFilesSheet(repo: repo),
  );

  @override
  State<_HfFilesSheet> createState() => _HfFilesSheetState();
}

final class _HfFilesSheetState extends State<_HfFilesSheet> {
  late final Future<List<AiModelInfo>> _files = context.read<AiModelStore>().catalog.ggufFiles(widget.repo);

  @override
  Widget build(BuildContext context) {
    final AiModelStore store = context.watch<AiModelStore>();
    return KekSheetScaffold(
      title: widget.repo.split('/').last,
      child: FutureBuilder<List<AiModelInfo>>(
        future: _files,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(padding: const EdgeInsets.all(16.0), child: Text(context.l10n.aiCatalogFailed));
          }
          final List<AiModelInfo>? files = snapshot.data;
          if (files == null) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (files.isEmpty) {
            return Padding(padding: const EdgeInsets.all(16.0), child: Text(context.l10n.aiNoFilesFit));
          }
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16.0),
            children: [
              for (final AiModelInfo model in files)
                ListTile(
                  title: Text(model.file.split('/').last, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(AiFormat.size(model.sizeBytes)),
                  trailing: store.isInstalled(model)
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                      : store.downloads.containsKey(model.id)
                      ? const SizedBox.square(dimension: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0))
                      : IconButton(
                          tooltip: context.l10n.aiDownload,
                          icon: const Icon(Icons.download_rounded),
                          onPressed: () => startAiDownload(context, store, model),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
