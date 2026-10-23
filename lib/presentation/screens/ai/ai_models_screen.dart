import 'package:keklist/domain/services/ai/ai_model_info.dart';
import 'package:keklist/domain/services/ai/ai_model_store.dart';
import 'package:keklist/domain/services/ai/device_memory.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/settings/settings_section.dart';
import 'package:keklist/presentation/screens/ai/ai_format.dart';
import 'package:keklist/presentation/screens/ai/ai_hf_search_screen.dart';
import 'package:keklist/presentation/screens/ai/ai_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Downloaded models, running downloads and the catalogs to download from. The list refreshes on every visit.
final class AiModelsScreen extends StatefulWidget {
  const AiModelsScreen({super.key});

  static Future<void> open(BuildContext context) => pushAiRoute<void>(context, (_) => const AiModelsScreen());

  @override
  State<AiModelsScreen> createState() => _AiModelsScreenState();
}

final class _AiModelsScreenState extends State<AiModelsScreen> {
  int? _usedBytes;

  @override
  void initState() {
    super.initState();
    final AiModelStore store = context.read<AiModelStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => store.refreshGallery());
    _updateUsage(store);
  }

  Future<void> _updateUsage(AiModelStore store) async {
    final int used = await store.usedBytes();
    if (mounted) setState(() => _usedBytes = used);
  }

  @override
  Widget build(BuildContext context) {
    final AiModelStore store = context.watch<AiModelStore>();
    final List<AiModelInfo> installed = store.installed;
    final AiModelInfo? active = store.active;
    final List<AiDownload> downloads = store.downloads.values.toList();
    final List<AiModelInfo> gallery = store.gallery;
    final double? memoryGb = DeviceMemory.totalGb;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(centerTitle: true, title: Text(context.l10n.aiModels)),
      body: SettingsListView(
        children: [
          const SizedBox(height: 56.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              [
                context.l10n.aiPrivacyNote,
                if (memoryGb != null) context.l10n.aiDeviceMemory('${memoryGb.toStringAsFixed(1)} GB'),
                if (_usedBytes case final int used when used > 0) context.l10n.aiStorageUsed(AiFormat.size(used)),
              ].join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          if (installed.isNotEmpty) ...[
            SettingsSectionHeader(context.l10n.aiDownloaded.toUpperCase()),
            SettingsSectionCard(
              children: [
                for (final AiModelInfo model in installed)
                  ListTile(
                    leading: Icon(
                      model.id == active?.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: model.id == active?.id ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(model.name),
                    subtitle: Text(_details(context, model)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _delete(store, model),
                    ),
                    onTap: () => store.setActive(model),
                  ),
              ],
            ),
          ],
          if (downloads.isNotEmpty) ...[
            SettingsSectionHeader(context.l10n.aiDownloads.toUpperCase()),
            SettingsSectionCard(
              children: [for (final AiDownload download in downloads) _DownloadTile(download: download, store: store)],
            ),
          ],
          SettingsSectionHeader(context.l10n.aiGalleryCatalog.toUpperCase()),
          SettingsSectionCard(
            children: [
              if (store.isLoadingGallery && gallery.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (store.galleryError != null && gallery.isEmpty)
                ListTile(
                  title: Text(context.l10n.aiCatalogFailed),
                  trailing: IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: store.refreshGallery),
                ),
              for (final (int index, AiModelInfo model) in gallery.indexed)
                _CatalogTile(model: model, store: store, isFastest: index == 0),
            ],
          ),
          SettingsSectionHeader(context.l10n.aiHuggingFace.toUpperCase()),
          SettingsSectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.search_rounded),
                title: Text(context.l10n.aiSearchModels),
                trailing: settingsNavTrailing(context),
                onTap: () => pushAiRoute<void>(context, (_) => const AiHfSearchScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _details(BuildContext context, AiModelInfo model) => [
    AiFormat.size(model.sizeBytes),
    model.format == AiModelFormat.gguf ? 'GGUF' : 'LiteRT-LM',
    model.repo,
  ].join(' · ');

  Future<void> _delete(AiModelStore store, AiModelInfo model) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.aiDeleteModel),
        content: Text('${model.name} · ${AiFormat.size(model.sizeBytes)}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (confirmed ?? false) {
      await store.delete(model);
      await _updateUsage(store);
    }
  }
}

/// Starts a download, asking first when the phone is on mobile data.
Future<void> startAiDownload(BuildContext context, AiModelStore store, AiModelInfo model) async {
  if (await store.isOnCellular()) {
    if (!context.mounted) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.aiCellularTitle),
        content: Text(context.l10n.aiCellularMessage(AiFormat.size(model.sizeBytes))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.aiDownload)),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
  }
  await store.download(model);
}

final class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.model, required this.store, required this.isFastest});

  final AiModelInfo model;
  final AiModelStore store;
  final bool isFastest;

  @override
  Widget build(BuildContext context) {
    final bool isInstalled = store.isInstalled(model);
    final bool isDownloading = store.downloads.containsKey(model.id);
    return ListTile(
      title: Row(
        spacing: 8.0,
        children: [
          Flexible(child: Text(model.name, overflow: TextOverflow.ellipsis)),
          if (isFastest) _Badge(text: context.l10n.aiFastest),
        ],
      ),
      subtitle: Text(
        [
          AiFormat.size(model.sizeBytes),
          if (model.minMemoryGb case final double memory) '≥ ${memory.toStringAsFixed(0)} GB RAM',
        ].join(' · '),
      ),
      trailing: isInstalled
          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
          : isDownloading
          ? const SizedBox.square(dimension: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0))
          : IconButton(
              tooltip: context.l10n.aiDownload,
              icon: const Icon(Icons.download_rounded),
              onPressed: () => startAiDownload(context, store, model),
            ),
    );
  }
}

final class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(8.0)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onPrimaryContainer)),
    );
  }
}

final class _DownloadTile extends StatelessWidget {
  const _DownloadTile({required this.download, required this.store});

  final AiDownload download;
  final AiModelStore store;

  @override
  Widget build(BuildContext context) {
    final AiModelInfo model = download.model;
    final String percent = '${(download.progress * 100).toStringAsFixed(0)}%';
    return ListTile(
      title: Text(model.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: [
          const SizedBox(height: 4.0),
          LinearProgressIndicator(value: download.progress > 0 ? download.progress : null),
          Text(switch (download.status) {
            AiDownloadStatus.running => '$percent · ${AiFormat.size(model.sizeBytes)}',
            AiDownloadStatus.paused => '${context.l10n.aiPaused} · $percent',
            AiDownloadStatus.failed => context.l10n.aiDownloadFailed,
          }),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (download.status == AiDownloadStatus.running)
            IconButton(
              tooltip: context.l10n.aiPause,
              icon: const Icon(Icons.pause_rounded),
              onPressed: () => store.pause(model),
            )
          else
            IconButton(
              tooltip: context.l10n.aiResume,
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => store.resume(model),
            ),
          IconButton(
            tooltip: context.l10n.cancel,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => store.cancel(model),
          ),
        ],
      ),
    );
  }
}
