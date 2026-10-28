import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/gallery/gallery_thumbnail_cache.dart';
import 'package:material_ui/material_ui.dart';

/// Settings row that shows how far the photo library index got; tap to rebuild it.
final class GalleryIndexTile extends StatefulWidget {
  const GalleryIndexTile({super.key});

  static bool isAvailable(BuildContext context) =>
      context.read<GalleryIndexer>().currentProgress.status != GalleryIndexStatus.unsupported;

  @override
  State<GalleryIndexTile> createState() => _GalleryIndexTileState();
}

final class _GalleryIndexTileState extends State<GalleryIndexTile> {
  @override
  void initState() {
    super.initState();
    GalleryThumbnailCache.refreshSize();
  }

  @override
  Widget build(BuildContext context) {
    final GalleryIndexer indexer = context.read<GalleryIndexer>();
    return StreamBuilder<GalleryIndexProgress>(
      stream: indexer.progress,
      initialData: indexer.currentProgress,
      builder: (context, snapshot) {
        final GalleryIndexProgress progress = snapshot.requireData;
        final bool isIndexing = progress.status == GalleryIndexStatus.indexing;
        return ListTile(
          leading: const Icon(Icons.photo_library_outlined, color: Colors.lightBlueAccent),
          title: Text(context.l10n.galleryIndex),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              Text(_statusText(context, progress)),
              if (isIndexing) LinearProgressIndicator(value: progress.fraction),
              ValueListenableBuilder<int?>(
                valueListenable: GalleryThumbnailCache.size,
                builder: (context, bytes, _) => bytes == null
                    ? const SizedBox.shrink()
                    : Text(context.l10n.galleryIndexThumbnails(_formatBytes(bytes))),
              ),
            ],
          ),
          onTap: isIndexing || progress.status == GalleryIndexStatus.noAccess ? null : () => _rebuild(indexer),
        );
      },
    );
  }

  String _statusText(BuildContext context, GalleryIndexProgress progress) {
    final NumberFormat numbers = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final DateTime? lastScan = progress.lastScanDate;
    return switch (progress.status) {
      GalleryIndexStatus.noAccess => context.l10n.galleryIndexNoAccess,
      GalleryIndexStatus.indexing => context.l10n.galleryIndexIndexing(
        numbers.format(progress.indexedCount),
        numbers.format(progress.libraryCount),
      ),
      _ when lastScan == null => context.l10n.galleryIndexNotIndexed,
      _ => context.l10n.galleryIndexReady(
        numbers.format(progress.libraryCount),
        DateFormat.MMMd(Localizations.localeOf(context).toString()).add_Hm().format(lastScan),
      ),
    };
  }

  Future<void> _rebuild(GalleryIndexer indexer) async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.galleryIndexRebuildTitle,
      message: context.l10n.galleryIndexRebuildMessage,
      okLabel: context.l10n.galleryIndexRebuild,
      cancelLabel: context.l10n.cancel,
    );
    if (result != OkCancelResult.ok) return;
    await GalleryThumbnailCache.clear();
    PaintingBinding.instance.imageCache.clear();
    await indexer.rebuild();
  }

  static String _formatBytes(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).toStringAsFixed(0)} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
