import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_thumbnail.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

const double _kTileRadius = 8.0;
const int _kThumbnailLogicalSize = 200;

final class DayFeedMindTile extends StatelessWidget {
  final DayFeedMind item;
  final bool isTextVisible;
  final bool isAudioBadgeVisible;
  final bool isWide;
  final double size;

  const DayFeedMindTile({
    super.key,
    required this.item,
    required this.isTextVisible,
    required this.isAudioBadgeVisible,
    required this.isWide,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MindNoteVideo? video = item.mind.noteContent.videoPieces.firstOrNull;
    if (video != null) return _buildVideoTile(video);
    final String text = item.mind.plainNote.trim();
    final bool showText = isTextVisible && text.isNotEmpty;
    final bool hasAudio = item.mind.audioNotes.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: ColoredBox(
        color: theme.cardColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.mind.emoji, style: TextStyle(fontSize: size * (showText ? 0.32 : 0.5))),
                  if (showText)
                    Flexible(
                      child: Text(
                        text,
                        maxLines: isWide ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.0, height: 1.2),
                      ),
                    ),
                ],
              ),
            ),
            if (isAudioBadgeVisible && hasAudio)
              Positioned(top: 4, right: 4, child: Icon(Icons.mic, size: 14, color: theme.colorScheme.primary)),
            if (item.reflectionCount > 0)
              Positioned(bottom: 4, right: 4, child: _CountBadge(count: item.reflectionCount)),
          ],
        ),
      ),
    );
  }
}

extension on DayFeedMindTile {
  Widget _buildVideoTile(MindNoteVideo video) {
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            Center(child: RoundVideoThumbnail(video: video, size: size * 0.92, showsPlayIcon: false)),
            Positioned(bottom: 2, right: 2, child: Text(item.mind.emoji, style: TextStyle(fontSize: size * 0.22))),
            if (item.reflectionCount > 0)
              Positioned(top: 4, right: 4, child: _CountBadge(count: item.reflectionCount)),
          ],
        ),
      ),
    );
  }
}

final class DayFeedAssetTile extends StatelessWidget {
  final DayFeedAsset item;

  const DayFeedAssetTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final int thumbnailSize = (_kThumbnailLogicalSize * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            item.asset,
            isOriginal: false,
            thumbnailSize: ThumbnailSize.square(thumbnailSize),
            fit: BoxFit.cover,
          ),
          if (item.isVideo) Positioned(bottom: 4, right: 4, child: _VideoBadge(seconds: item.asset.duration)),
        ],
      ),
    );
  }
}

final class DayFeedFolderMediaTile extends StatelessWidget {
  final DayFeedFolderMedia item;

  const DayFeedFolderMediaTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FolderMediaThumbnail(item: item.item),
          if (item.isVideo)
            const Positioned(bottom: 4, right: 4, child: Icon(Icons.play_arrow, color: Colors.white, size: 20)),
        ],
      ),
    );
  }
}

final class DayFeedSkeletonTile extends StatelessWidget {
  const DayFeedSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final Color placeholder = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: ColoredBox(color: placeholder),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: Colors.white24);
  }
}

final class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(8)),
      child: Text('$count', style: TextStyle(color: colors.onPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

final class _VideoBadge extends StatelessWidget {
  final int seconds;

  const _VideoBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final String formatted = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
      child: Text(formatted, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}
