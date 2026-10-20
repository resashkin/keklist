import 'package:auto_size_text/auto_size_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/widgets/gallery/cached_asset_thumbnail_provider.dart';
import 'package:keklist/presentation/core/widgets/mind_emotion_emojis.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_thumbnail.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';

const double _kTileRadius = 8.0;
const double _kMinTextSize = 7.0;
const double _kMaxTextSize = 14.0;

final class DayFeedMindTile extends StatelessWidget {
  final DayFeedMind item;
  final bool isTextVisible;
  final double size;

  const DayFeedMindTile({
    super.key,
    required this.item,
    required this.isTextVisible,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MindNoteContent content = item.mind.noteContent;
    final MindNoteVideo? video = content.videoPieces.firstOrNull;
    final double circleSize = size * 0.7;
    // Media minds show just their circle; text stays for the story view.
    final Widget? mediaCircle = video != null
        ? RoundVideoThumbnail(video: video, size: circleSize, showsPlayIcon: false)
        : content.hasAudio
        ? _AudioCircle(size: circleSize)
        : null;
    final Duration? mediaDuration = video?.duration ?? content.audioPieces.firstOrNull?.duration;
    final String text = item.mind.plainNote.trim();
    final bool showText = isTextVisible && text.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: ColoredBox(
        color: theme.cardColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: mediaCircle != null
                  ? Center(child: mediaCircle)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MindEmotionEmojis(
                          mind: item.mind,
                          fontSize: size * (showText ? 0.18 : 0.3),
                          maxCount: 3,
                          placeholder: showText
                              ? const SizedBox.shrink()
                              : Icon(Icons.notes, size: size * 0.3, color: theme.disabledColor),
                        ),
                        if (showText)
                          Expanded(
                            child: Center(
                              child: AutoSizeText(
                                text,
                                textAlign: TextAlign.center,
                                minFontSize: _kMinTextSize,
                                maxFontSize: _kMaxTextSize,
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: _kMaxTextSize, height: 1.2),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            if (mediaCircle != null)
              Positioned(top: 4, left: 4, child: MindEmotionEmojis(mind: item.mind, fontSize: size * 0.13, maxCount: 2)),
            if (mediaCircle != null && mediaDuration != null)
              Positioned(bottom: 4, right: 4, child: _VideoBadge(seconds: mediaDuration.inSeconds)),
          ],
        ),
      ),
    );
  }
}

/// Audio minds: just the waveform icon, sized like a video circle.
final class _AudioCircle extends StatelessWidget {
  final double size;

  const _AudioCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Icon(Icons.graphic_eq, size: size * 0.6, color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

final class DayFeedAssetTile extends StatelessWidget {
  final DayFeedAsset item;

  const DayFeedAssetTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: CachedAssetThumbnailProvider(item.asset),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, _, _) => ColoredBox(color: Theme.of(context).cardColor),
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
