import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_audio_circle.dart';

final class InsightsOnThisDayCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsOnThisDayCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<OnThisDayGroup> groups = data.report.onThisDay;
    return InsightsCard(
      category: InsightsCategory.memories,
      title: context.l10n.insightsOnThisDay,
      child: groups.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyOnThisDay)
          : Column(
              children: [
                for (final OnThisDayGroup group in groups)
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => data.openMinds(group.mindIds),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _row(context, group),
                    ),
                  ),
              ],
            ),
    );
  }

  static String _pointTitle(BuildContext context, MemoryPoint point) => switch (point) {
    MemoryPoint.weekAgo => context.l10n.insightsWeekAgo,
    MemoryPoint.monthAgo => context.l10n.insightsMonthAgo,
    MemoryPoint.halfYearAgo => context.l10n.insightsHalfYearAgo,
    MemoryPoint.yearAgo => context.l10n.insightsYearAgo,
    MemoryPoint.twoYearsAgo => context.l10n.insightsTwoYearsAgo,
  };

  Widget _row(BuildContext context, OnThisDayGroup group) {
    final List<Mind> minds = group.mindIds.map((id) => data.mindById[id]).whereType<Mind>().toList();
    final String emojis = minds.expand((mind) => mind.emotionIds).map(data.emojiOf).toSet().join(' ');
    final String preview = minds.map((mind) => mind.plainNote.trim()).firstWhere((text) => text.isNotEmpty, orElse: () => '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        SizedBox(
          width: 104.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_pointTitle(context, group.point), style: Theme.of(context).textTheme.labelLarge),
              Text(
                InsightsFormat.day(context, group.dayIndex),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (emojis.isNotEmpty) Text(emojis),
              if (preview.isNotEmpty) Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Text(
          InsightsFormat.number(context, minds.length),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

final class InsightsMediaCountersCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsMediaCountersCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final MediaInsight media = data.report.media;
    final List<(int, String)> values = [
      if (data.hasLibraryIndex) ...[
        (media.libraryPhotos, context.l10n.insightsPhotos),
        (media.libraryVideos, context.l10n.insightsVideos),
      ],
      (media.audioMinds, context.l10n.insightsVoiceNotes),
      (media.videoMinds, context.l10n.insightsRoundVideos),
    ];
    return InsightsCard(
      category: InsightsCategory.media,
      title: context.l10n.insightsMediaCounters,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          for (final (int value, String caption) in values)
            Expanded(child: InsightsValue(value: InsightsFormat.number(context, value), caption: caption)),
        ],
      ),
    );
  }
}

/// Voice notes and round videos of the period in one strip, newest first; a tap opens the mind.
final class InsightsRoundVideosCard extends StatelessWidget {
  static const double _size = 72.0;

  final InsightsCardContext data;

  const InsightsRoundVideosCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Mind> minds = data.report.media.voiceMindIds.map((id) => data.mindById[id]).whereType<Mind>().toList();
    final List<String> ids = [for (final Mind mind in minds) mind.id];
    return InsightsCard(
      category: InsightsCategory.media,
      title: context.l10n.insightsVoiceAndVideos,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: minds.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyRoundVideos)
          : SizedBox(
              height: _size,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: minds.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8.0),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => data.openMinds(ids, initialIndex: index),
                  child: switch (minds[index].noteContent) {
                    MindNoteContent(videoPieces: [final MindNoteVideo video, ...]) => RoundVideoThumbnail(
                      video: video,
                      size: _size,
                    ),
                    MindNoteContent(audioPieces: [final MindNoteAudio audio, ...]) => _AudioCircle(
                      audio: audio,
                      color: mindAccentColorOf(context, minds[index]),
                      size: _size,
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
            ),
    );
  }
}

final class _AudioCircle extends StatelessWidget {
  final MindNoteAudio audio;
  final Color color;
  final double size;

  const _AudioCircle({required this.audio, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final Duration? duration = audio.duration;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic_rounded, color: Colors.white),
          if (duration != null)
            Text(
              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
