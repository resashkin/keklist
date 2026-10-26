import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/widgets/mind_emotion_emojis.dart';
import 'package:keklist/presentation/core/widgets/mind_emotion_texture.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_thumbnail.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/tile_text_fitting.dart';
import 'package:keklist/presentation/core/widgets/gallery/gallery_media.dart';

const double _kTileRadius = 8.0;
const double _kMinTextSize = 7.0;
const double _kMaxTextSize = 14.0;
const double _kTextLineHeight = 1.2;
const double _kTextPadding = 8.0;
const double _kReflectionsBadgeHeight = 14.0;
const double _kMinReflectionsTileSize = 48.0;

/// The tile of any feed item, shared by the day screen and the calendar.
final class DayFeedItemTile extends StatelessWidget {
  final DayFeedItem item;
  final bool isMindTextVisible;
  final double size;

  const DayFeedItemTile({super.key, required this.item, required this.isMindTextVisible, required this.size});

  @override
  Widget build(BuildContext context) => switch (item) {
    DayFeedMind mind => DayFeedMindTile(item: mind, isTextVisible: isMindTextVisible, size: size),
    DayFeedAsset asset => DayFeedAssetTile(item: asset),
    DayFeedFolderMedia media => DayFeedFolderMediaTile(item: media),
  };
}

final class DayFeedMindTile extends StatelessWidget {
  final DayFeedMind item;
  final bool isTextVisible;
  final double size;

  const DayFeedMindTile({super.key, required this.item, required this.isTextVisible, required this.size});

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
    final bool showsReflections = item.reflections.total > 0 && size >= _kMinReflectionsTileSize;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kTileRadius),
      child: ColoredBox(
        color: theme.cardColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (mediaCircle != null || showText) MindEmotionTexture(mind: item.mind, emojiSize: size * 0.2),
            Padding(
              padding: mediaCircle != null
                  ? const EdgeInsets.all(4.0)
                  : const EdgeInsets.all(_kTextPadding).copyWith(
                      bottom: showsReflections ? _kTextPadding + _kReflectionsBadgeHeight : _kTextPadding,
                    ),
              child: mediaCircle != null
                  ? Center(child: mediaCircle)
                  : showText
                  ? _FittedTileText(
                      text: text,
                      style: theme.brightness == Brightness.light
                          ? theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
                          : theme.textTheme.bodySmall,
                    )
                  : Center(
                      child: MindEmotionEmojis(
                        mind: item.mind,
                        fontSize: size * 0.3,
                        maxCount: 3,
                        placeholder: Icon(Icons.notes, size: size * 0.3, color: theme.disabledColor),
                      ),
                    ),
            ),
            if (showsReflections)
              Positioned(
                left: 4,
                bottom: 4,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size - 8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: _ReflectionsBadge(reflections: item.reflections),
                  ),
                ),
              ),
            if (mediaCircle != null && mediaDuration != null)
              Positioned(bottom: 4, right: 4, child: _VideoBadge(seconds: mediaDuration.inSeconds)),
            // Minds matter more than gallery media, so they are framed to stand out next to photos.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kTileRadius),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.25), width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shrinks the text until whole words fit, then ends the last line that fits with "…".
final class _FittedTileText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _FittedTileText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final TextStyle baseStyle = (style ?? const TextStyle()).copyWith(height: _kTextLineHeight);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitted = fitTileText(
          text: text,
          style: baseStyle,
          box: constraints.biggest,
          minFontSize: _kMinTextSize,
          maxFontSize: _kMaxTextSize,
          textScaler: textScaler,
        );
        final double lineHeight = textScaler.scale(fitted.fontSize) * _kTextLineHeight;
        return Center(
          child: Text(
            fitted.text,
            textAlign: TextAlign.center,
            maxLines: (constraints.maxHeight / lineHeight).floor().clamp(1, 1000),
            overflow: TextOverflow.ellipsis,
            style: baseStyle.copyWith(fontSize: fitted.fontSize),
          ),
        );
      },
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
            image: GalleryMedia.thumbnail(item.asset),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // The tile keeps its place while the thumbnail loads, then fades it in.
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => wasSynchronouslyLoaded
                ? child
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
                      AnimatedOpacity(
                        opacity: frame == null ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: child,
                      ),
                    ],
                  ),
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

/// "💬 1 🎥 1 🎙 1": a mind's comments, round videos and audio notes, as icons with counts.
final class _ReflectionsBadge extends StatelessWidget {
  final MindReflections reflections;

  const _ReflectionsBadge({required this.reflections});

  @override
  Widget build(BuildContext context) {
    final List<(IconData, int)> counters = [
      (Icons.chat_bubble_outline_rounded, reflections.comments),
      (Icons.videocam_outlined, reflections.videos),
      (Icons.mic_none_rounded, reflections.audios),
    ].where((counter) => counter.$2 > 0).toList();
    return Container(
      height: _kReflectionsBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5.0,
        children: [
          for (final (IconData icon, int count) in counters)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 2.0,
              children: [
                Icon(icon, size: 10.0, color: Colors.white),
                Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9.5, height: 1.0)),
              ],
            ),
        ],
      ),
    );
  }
}
